#!/bin/sh
# Build a private-prefix package; never install to the host.
set -eu
build=$(realpath "${1:?Usage: package.sh BUILD_DIR OUTPUT_DIR}")
out=$(realpath -m "${2:?Output directory required}")
prefix=/usr/lib/nautilus-commander
mkdir -p "$out"
stage=$(mktemp -d "$out/stage.XXXXXX")
trap 'rm -rf "$stage"' EXIT
meson install -C "$build" --no-rebuild --destdir "$stage" > "$out/install.log"
mkdir -p "$stage/usr/bin" "$stage/usr/share/applications" "$stage/usr/share/dbus-1/services" "$stage/usr/share/icons/hicolor/scalable/apps" "$stage/usr/share/glib-2.0/schemas" "$stage/usr/share/doc/nautilus-commander" "$stage/DEBIAN"
cat > "$stage/usr/bin/nautilus-commander" <<'WRAPPER'
#!/bin/sh
prefix=/usr/lib/nautilus-commander
export GSETTINGS_SCHEMA_DIR="$prefix/share/glib-2.0/schemas"
export LD_LIBRARY_PATH="$prefix/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="$prefix/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
exec "$prefix/bin/nautilus-commander" "$@"
WRAPPER
chmod 755 "$stage/usr/bin/nautilus-commander"
id=org.nautiluscommander.NautilusCommander
cp "$stage$prefix/share/applications/$id.desktop" "$stage/usr/share/applications/"
sed "s|$prefix/bin/nautilus-commander|/usr/bin/nautilus-commander|" "$stage$prefix/share/dbus-1/services/$id.service" > "$stage/usr/share/dbus-1/services/$id.service"
cp "$stage$prefix/share/icons/hicolor/scalable/apps/$id.svg" "$stage/usr/share/icons/hicolor/scalable/apps/"
cp "$stage$prefix/share/glib-2.0/schemas/org.nautiluscommander.gschema.xml" "$stage/usr/share/glib-2.0/schemas/"
glib-compile-schemas "$stage$prefix/share/glib-2.0/schemas"
# Do not expose upstream autorun launchers or a competing global service.
rm -f "$stage$prefix/share/applications/nautilus-autorun-software.desktop"
rm -f "$stage$prefix/share/dbus-1/services/org.freedesktop.FileManager1.service"
source_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cp "$source_dir/LICENSE" "$stage/usr/share/doc/nautilus-commander/copyright"
cp "$source_dir/commander/README.md" "$stage/usr/share/doc/nautilus-commander/README.md"
cp "$source_dir/commander/TEST-REPORT.md" "$stage/usr/share/doc/nautilus-commander/TEST-REPORT.md"
cat > "$stage/DEBIAN/control" <<'CONTROL'
Package: nautilus-commander
Version: 0.1.0~rc2
Architecture: amd64
Maintainer: Nautilus Commander contributors <nautilus-commander@localhost>
Section: utils
Priority: optional
Depends: libadwaita-1-0 (>= 1.6), libgtk-4-1 (>= 4.17.5), libglib2.0-0t64 (>= 2.80), libgnome-autoar-0-0, libgnome-desktop-4-2t64, libgexiv2-2, libgstreamer1.0-0, libgstreamer-plugins-base1.0-0, libportal-gtk4-1, libportal1, libtinysparql-3.0-0, libcloudproviders0, libpango-1.0-0, libcairo2, libgdk-pixbuf-2.0-0, libfontconfig1, libwayland-client0, libx11-6, libc6 (>= 2.38), gvfs, gvfs-backends, tracker-extract, gsettings-desktop-schemas
Description: GNOME Files fork with independent dual-pane navigation
 Nautilus Commander keeps the GNOME Files views and operations and adds
 a second pane. This release candidate requires desktop validation.
CONTROL
printf 'activate-noawait /usr/share/glib-2.0/schemas\nactivate-noawait /usr/share/icons/hicolor\n' > "$stage/DEBIAN/triggers"
dpkg-deb --root-owner-group --build "$stage" "$out/nautilus-commander_0.1.0~rc2_amd64.deb"
