#!/usr/bin/env bash
# theme-switch — atomic theme swap.
#
# theme-switch <name>   switch to theme <name>
# theme-switch list     print "<name>\t<mode>\t<display_name>" per theme
set -o pipefail
# ponytail: set -u dropped, leaves guards relying on unset vars; safer for user-supplied paths.

THEMES_DIR="${HOME}/.config/themes"
ACTIVE_LINK="${THEMES_DIR}/.active"
HOOK="${THEMES_DIR}/.hook"

die() { printf '%s\n' "$*" >&2; exit "${2:-1}"; }

list_themes() {
  [ -d "$THEMES_DIR" ] || return 0
  local d mode display
  for d in "$THEMES_DIR"/*/; do
    # Skip symlinks to avoid duplicates (follows the real path, basename gives the same name)
    [ -L "$d" ] && continue
    [ -d "$d" ] || continue
    local name
    name=$(basename "$d")
    [ "$name" = ".active" ] && continue
    mode=$(detect_mode "$d" "$name")
    display=$(read_meta_field "$d" "display_name")
    printf '%s (%s)\n' "${display:-$name}" "$mode"
  done | sort -u
}

# ponytail: global scan over a few dirs; per-theme lookup if dir count grows.
read_meta_field() {
  local dir="$1" key="$2" meta="$dir/meta"
  [ -f "$meta" ] || return 0
  awk -F= -v k="$key" '$1==k {sub(/^[^=]*=/,""); print; exit}' "$meta"
}

detect_mode() {
  local dir="$1" name="$2"
  case "$name" in
    *-dark)  printf 'dark\n';  return ;;
    *-light) printf 'light\n'; return ;;
  esac
  local meta_mode
  meta_mode=$(read_meta_field "$dir" "mode")
  if [ -n "$meta_mode" ]; then printf '%s\n' "$meta_mode"; return; fi
  printf 'dark\n'
}

guard_active() {
  if [ -e "$ACTIVE_LINK" ] && [ ! -L "$ACTIVE_LINK" ]; then
    die "refusing to clobber non-symlink ${ACTIVE_LINK}" 1
  fi
}

apply_gsettings() {
  local mode="$1"
  command -v gsettings >/dev/null 2>&1 || return 0
  local schema="prefer-${mode}"
  gsettings set org.gnome.desktop.interface color-scheme "$schema" 2>/dev/null || true
}

reload_apps() {
  # Apps that auto-reload on file change need nothing from us.
  # Live-reload-capable apps get an explicit nudge here.
  pgrep -x waybar >/dev/null && pkill -SIGUSR2 waybar 2>/dev/null || true
  command -v swaync-client >/dev/null 2>&1 && swaync-client --reload-css 2>/dev/null || true
  command -v kitty >/dev/null 2>&1 && kitty @ set-colors --all 2>/dev/null || true
  pkill -SIGHUP ghostty 2>/dev/null || true
  if [ -n "${NVIM:-}" ] && command -v nvim >/dev/null 2>&1; then
    local name="$1"
    nvim --remote-expr "lua vim.cmd('colorscheme ${name}')" 2>/dev/null || true
  fi
  # Deck-only: try SIGHUP on foot; fall back to TERM if the running footserver is too old.
  if command -v foot >/dev/null 2>&1; then
    pkill -SIGHUP foot 2>/dev/null || pkill -TERM foot 2>/dev/null || true
  fi
}

notify_user() {
  local name="$1"
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send "Theme switched" "$name" 2>/dev/null || true
}

run_hook() {
  local name="$1"
  [ -x "$HOOK" ] || return 0
  "$HOOK" "$name" 2>&1 || printf 'theme-switch: hook exited %d\n' "$?" >&2
}

do_switch() {
  local name="$1"
  local dir="${THEMES_DIR}/${name}"

  if [ ! -d "$dir" ]; then
    printf 'unknown theme: %s\navailable:\n' "$name" >&2
    list_themes >&2
    exit 2
  fi

  guard_active

  local current
  current=$(readlink "$ACTIVE_LINK" 2>/dev/null || true)
  current=${current##*/}
  if [ "$current" = "$name" ]; then
    exit 0
  fi

  mkdir -p "$THEMES_DIR"
  ln -sfn "$name" "$ACTIVE_LINK"

  local mode
  mode=$(detect_mode "$dir" "$name")
  apply_gsettings "$mode"
  reload_apps "$name"
  run_hook "$name"
  notify_user "$name"
}

case "${1:-}" in
  list) list_themes ;;
  '')   die "usage: theme-switch <name> | theme-switch list" 2 ;;
  *)    do_switch "$1" ;;
esac