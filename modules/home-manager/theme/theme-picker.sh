#!/usr/bin/env sh
# theme-picker — rofi-driven theme picker. Thin wrapper over theme-switch.
set -u

DIR=$(dirname "$(readlink -f "$0")")

selected=$("$DIR/theme-switch" list | rofi -dmenu -p "Theme")
[ -n "$selected" ] || exit 0

name=$(printf '%s' "$selected" | awk -F'\t' '{print $1}')
exec "$DIR/theme-switch" "$name"