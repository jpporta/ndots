#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export XDG_STATE_HOME="$tmp/state"
runtime=${1:?pass path to alarm-runtime}

test "$("$runtime" timer 2s)" = 1
test "$("$runtime" alarm "$(date +%H:%M)" Rolled Over)" = 2
test "$("$runtime" alarm "$(date -d tomorrow +%F)" 10:20 Important Meeting)" = 3
! "$runtime" timer 0m >/dev/null 2>&1
! "$runtime" alarm "$(date -d yesterday +%F)" 10:20 >/dev/null 2>&1
! "$runtime" alarm "$(date -d tomorrow +%F)" 10:20 >/dev/null 2>&1
test "$("$runtime" timer list | wc -l)" = 1
"$runtime" timer cancel 1 >/dev/null
! "$runtime" timer cancel 1 >/dev/null 2>&1
test "$("$runtime" timer list)" = "No timer events scheduled."

mkdir -p "$tmp/bin"
printf '#!/bin/sh\nprintf notify >> "$LOG"\n' > "$tmp/bin/notify-send"
printf '#!/bin/sh\nprintf sound >> "$LOG"\n' > "$tmp/bin/pw-play"
chmod +x "$tmp/bin/notify-send" "$tmp/bin/pw-play"
export PATH="$tmp/bin:$PATH" LOG="$tmp/effects"
test "$("$runtime" timer 1s)" = 4
sleep 2
set +e
timeout 2 "$runtime" scheduler
status=$?
set -e
test "$status" = 124
test ! -s "$LOG"
test "$("$runtime" timer 1s)" = 5
set +e
timeout 3 "$runtime" scheduler
status=$?
set -e
test "$status" = 124
test "$(wc -c < "$LOG")" = 11
test "$(jq '.events | length' "$XDG_STATE_HOME/alarm/events.json")" = 2
printf 'alarm/timer checks passed\n'
