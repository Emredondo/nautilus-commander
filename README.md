# Nautilus Commander 0.1.0 — candidato de desarrollo

Fork de GNOME Files 48.3, basado en el código fuente Debian 48.3-2. GPL-3.0-or-later; se conservan los avisos y licencias originales. El icono SVG de submarino se creó para este proyecto y se distribuye con la misma licencia.

## Descargar e instalar

Esta es una **versión candidata de prueba** para Debian 13 AMD64.

- [Descargar el instalador DEB](https://github.com/Emredondo/nautilus-commander/releases/download/v0.1.0-rc2/nautilus-commander_0.1.0.rc2_amd64.deb)
- [Descargar el código fuente completo](https://github.com/Emredondo/nautilus-commander/releases/download/v0.1.0-rc2/nautilus-commander-source-rc2.tar.gz)
- [Consultar la versión y sus archivos](https://github.com/Emredondo/nautilus-commander/releases/tag/v0.1.0-rc2)
- [Explorar el código fuente en GitHub](https://github.com/Emredondo/nautilus-commander/tree/main/src)

Los archivos DEB y de fuentes también están en la lista de archivos de este repositorio. El DEB descargado de la versión se instala desde la carpeta de descargas con:

```sh
sudo apt install ./nautilus-commander_0.1.0.rc2_amd64.deb
```

El paquete aún requiere pruebas adicionales; consultar [el informe](commander/TEST-REPORT.md).

## Uso

El menú contextual de una carpeta o del fondo ofrece «Abrir una terminal aquí». En carpetas locales utiliza la terminal predeterminada de Debian; también conserva la integración con GNOME Console para ubicaciones compatibles.

Ejecutar `nautilus-commander`. Se inicia con un panel. F3 muestra el segundo panel en la misma ubicación; F3 otra vez oculta el panel inactivo y conserva sus pestañas y navegación. La barra de ubicación, búsqueda y acciones sigue al panel activo. Hacer clic para cambiar de panel. Tab alterna cuando el foco está en una lista de archivos; las entradas de texto y controles conservan su navegación habitual. Las pestañas pertenecen a cada panel. Copiar/cortar/pegar utiliza las acciones originales de Nautilus.

## Compilación en Debian 13 AMD64

Se necesitan las dependencias de compilación de Nautilus 48.3-2 indicadas en `debian/control`, Meson 1.7 y Ninja. LocalSearch/Tracker y `tracker-test-utils` se necesitan para las pruebas de búsqueda; Xvfb y D-Bus para pruebas de ventana. No se necesitan versiones de GTK ni libadwaita posteriores a Debian 13.

Desde la raíz del código fuente:

```sh
meson setup _build --prefix=/usr/lib/nautilus-commander -Dprofile= -Ddocs=false -Dintrospection=false -Dtests=headless -Dbuildtype=debugoptimized
meson compile -C _build
meson test -C _build --print-errorlogs
./commander/package.sh _build ../dist
```

El directorio de compilación debe estar fuera de `/tmp`: LocalSearch excluye ese árbol de la indexación. Las pruebas se deben ejecutar con HOME y directorios XDG descartables, una sesión D-Bus privada y una pantalla Xvfb; nunca sobre archivos personales. La prueba adicional `test/automated/test-commander-window` necesita las variables `COMMANDER_TEST_FIRST` y `COMMANDER_TEST_SECOND`, apuntando a dos directorios descartables existentes. Comprueba las ubicaciones de los paneles, transferencias con el motor original, F3 y cierre de pestañas.

## Instalación y desinstalación

El paquete instala los componentes privados en `/usr/lib/nautilus-commander` y su lanzador en `/usr/bin/nautilus-commander`. Sus esquemas, servicio de activación e icono tienen nombres propios. No registra asociaciones MIME ni reclama `org.freedesktop.FileManager1`.

```sh
sudo apt install ./nautilus-commander_0.1.0~rc2_amd64.deb
sudo apt remove nautilus-commander
```

`remove` conserva las preferencias del usuario. Los datos propios se guardan en `~/.config/nautilus-commander` y `~/.local/share/nautilus-commander`, y los ajustes en `/org/nautiluscommander/`. No se borran automáticamente. La instalación original de GNOME Files permanece independiente.

## Alcance de la verificación

Consultar el informe de pruebas entregado con el paquete. Un paquete construido y una prueba virtual no prueban por sí solos todos los criterios de estabilidad en XFCE, Wayland, dispositivos extraíbles o transferencias entre dispositivos. No se debe llamar versión estable a este candidato hasta completar esos ensayos.

## Cambios

- 0.1.0~rc2: identidad y configuración separadas; icono de submarino; contenedor doble con vistas originales; F3 y panel activo; pestañas por panel; ajuste del cierre del panel; pruebas de integración de estado y transferencias. Se mantiene el motor de búsqueda y de operaciones de Nautilus.
