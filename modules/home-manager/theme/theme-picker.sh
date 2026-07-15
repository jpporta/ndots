#!/usr/bin/env sh
# theme-picker — rofi-driven theme picker. Thin wrapper over theme-switch.
set -u

DIR=$(dirname "$(readlink -f "$0")")

selected=$("$DIR/theme-switch" list | rofi -dmenu -p "Theme" -format f)
[ -n "$selected" ] || exit 0

# Extract theme name (format: "Display Name (mode)")
name=$(printf '%s' "$selected" | sed 's/ (.*//')
exec "$DIR/theme-switch" "$name"