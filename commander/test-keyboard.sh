#!/bin/sh
set -eu
build=$(realpath "${COMMANDER_BUILD_DIR:?Set the build directory}")
[ "${COMMANDER_TEST_HOME:?Use a disposable HOME in a private session}" = "$HOME" ] || exit 2
export GSETTINGS_SCHEMA_DIR="$build/data" GSETTINGS_BACKEND=memory G_DEBUG=fatal-criticals G_MESSAGES_DEBUG=nautilus-window
export XDG_CONFIG_HOME="$HOME/config" XDG_DATA_HOME="$HOME/data" XDG_CACHE_HOME="$HOME/cache"
mkdir -p "$HOME/test-folder/first" "$HOME/test-folder/second" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME"
touch "$HOME/test-folder/first/first-only" "$HOME/test-folder/second/second-only"
"$build/src/nautilus-commander" "$HOME/test-folder/first" > "$build/pane-check.log" 2>&1 &
p=$!
trap 'kill "$p" 2>/dev/null || true' EXIT
sleep 5
wid=$(xdotool search --onlyvisible --name '^first$' | head -1)
xdotool windowfocus "$wid"
xdotool key F3
sleep 2
xdotool mousemove --window "$wid" 700 300 click 1
xdotool windowfocus "$wid"
sleep 1
xdotool key ctrl+l
sleep 1
xdotool key ctrl+a
xdotool type --clearmodifiers --delay 30 "$HOME/test-folder/second"
sleep 1
xdotool key Return
sleep 3
kill -0 "$p"
title=$(xdotool getwindowname "$wid")
printf 'Navigated active pane: %s\n' "$title"
[ "$title" = second ]
xwd -root -silent -out "$build/check-dual.xwd"
xdotool key F3
sleep 2
[ "$(xdotool getwindowname "$wid")" = second ]
xwd -root -silent -out "$build/check-single.xwd"
xdotool key F3
sleep 2
[ "$(xdotool getwindowname "$wid")" = second ]
xwd -root -silent -out "$build/check-restored.xwd"
xdotool key Tab
sleep 1
[ "$(xdotool getwindowname "$wid")" = first ]
xdotool key shift+Tab
sleep 1
[ "$(xdotool getwindowname "$wid")" = second ]
printf 'Tab and Shift+Tab passed\n'
xdotool mousemove --window "$wid" 350 300 click 1
sleep 1
xdotool key ctrl+a
xdotool key ctrl+c
sleep 1
xdotool mousemove --window "$wid" 700 300 click 1
sleep 1
xdotool key ctrl+v
sleep 5
test -f "$HOME/test-folder/second/first-only"
printf 'Clipboard copy across panes passed\n'
rm "$HOME/test-folder/second/first-only"
xdotool key ctrl+t
sleep 2
kill -0 "$p"
xwd -root -silent -out "$build/check-tabs.xwd"
xdotool key ctrl+w
sleep 2
kill -0 "$p"
xdotool key ctrl+w
sleep 2
kill -0 "$p"
printf 'After closing right pane: %s\n' "$(xdotool getwindowname "$wid")"
[ "$(xdotool getwindowname "$wid")" = first ]
