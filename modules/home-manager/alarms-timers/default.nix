{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.alarms-timers;
  runtime = pkgs.writeShellScriptBin "alarm-runtime" ''
    set -efu

    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/alarm"
    state_file="$state_dir/events.json"
    lock_file="$state_dir/events.lock"
    mkdir -p "$state_dir"

    init_state() {
      if [ ! -s "$state_file" ] || ! jq -e '(.nextId | numbers) and (.events | arrays)' "$state_file" >/dev/null 2>&1; then
        printf '%s\n' '{"nextId":1,"events":[]}' > "$state_file"
      fi
    }

    write_state() {
      tmp=$(mktemp "$state_dir/events.XXXXXX")
      jq -c . > "$tmp"
      mv -f "$tmp" "$state_file"
    }

    usage() {
      printf '%s\n' "usage: timer DURATION|list|cancel ID" "       alarm [YYYY-MM-DD] HH:MM [DESCRIPTION...]" >&2
      exit 2
    }

    die() {
      printf 'alarm: %s\n' "$1" >&2
      exit 2
    }

    parse_duration() {
      [ -n "$1" ] && [[ "$1" != *[!0-9smh]* ]] || return 1
      value=''${1%[smh]}
      unit=''${1#''${value}}
      [ -n "$value" ] && [ "$value" -gt 0 ] || return 1
      case "$unit" in s) printf '%s\n' "$value" ;; m) printf '%s\n' "$((value * 60))" ;; h) printf '%s\n' "$((value * 3600))" ;; *) return 1 ;; esac
    }

    valid_time() { [[ "$1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; }
    valid_date() { [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; }

    create_timer() {
      seconds=$(parse_duration "$1") || die "duration must be a positive number followed by s, m, or h"
      now=$(date +%s)
      (
        flock -x 9
        init_state
        id=$(jq -r '.nextId' "$state_file")
        jq --argjson id "$id" --argjson due "$((now + seconds))" \
          '.nextId = ($id + 1) | .events += [{id:$id,kind:"timer",due:$due,description:null}]' \
          "$state_file" | write_state
        printf '%s\n' "$id"
      ) 9>"$lock_file"
    }

    create_alarm() {
      if valid_date "$1"; then
        [ "$#" -ge 2 ] || usage
        alarm_date=$1; alarm_time=$2; shift 2
        valid_time "$alarm_time" || die "time must use HH:MM"
      else
        alarm_date=$(date +%F); alarm_time=$1; shift
        valid_time "$alarm_time" || die "time must use HH:MM"
        candidate=$(date -d "$alarm_date $alarm_time" +%s) || die "invalid local time"
        [ "$candidate" -gt "$(date +%s)" ] || alarm_date=$(date -d tomorrow +%F)
      fi
      candidate=$(date -d "$alarm_date $alarm_time" +%s) || die "invalid date or time"
      [ "$(date -d "@$candidate" +%F\ %H:%M)" = "$alarm_date $alarm_time" ] || die "invalid date or time"
      [ "$candidate" -gt "$(date +%s)" ] || die "explicit alarm date is in the past"
      description="$*"
      (
        flock -x 9
        init_state
        if jq -e --argjson due "$candidate" '.events[] | select(.kind == "alarm" and .due == $due)' "$state_file" >/dev/null; then
          die "an alarm already exists at that time"
        fi
        id=$(jq -r '.nextId' "$state_file")
        jq --argjson id "$id" --argjson due "$candidate" --arg description "$description" \
          '.nextId = ($id + 1) | .events += [{id:$id,kind:"alarm",due:$due,description:(if $description == "" then null else $description end)}]' \
          "$state_file" | write_state
        printf '%s\n' "$id"
      ) 9>"$lock_file"
    }

    list_events() {
      kind=$1
      (
        flock -s 9
        init_state
        if ! jq -e --arg kind "$kind" '.events | map(select(.kind == $kind)) | length > 0' "$state_file" >/dev/null; then
          printf 'No %s events scheduled.\n' "$kind"
          exit 0
        fi
        jq -r --arg kind "$kind" '
          .events | map(select(.kind == $kind)) | sort_by(.due)[] |
          "\(.id) \(if .kind == "timer" then ("due " + ( .due | todateiso8601)) else ("at " + (.due | strftime("%Y-%m-%d %H:%M"))) end)\(if .description then " - " + .description else "" end)"
        ' "$state_file"
      ) 9>"$lock_file"
    }

    cancel_event() {
      kind=$1; id=$2
      [[ "$id" =~ ^[0-9]+$ ]] || die "ID must be numeric"
      (
        flock -x 9
        init_state
        if ! jq -e --arg kind "$kind" --argjson id "$id" '.events[] | select(.id == $id and .kind == $kind)' "$state_file" >/dev/null; then
          die "no $kind with ID $id"
        fi
        jq --arg kind "$kind" --argjson id "$id" '.events |= map(select(.id != $id or .kind != $kind))' "$state_file" | write_state
        printf 'Cancelled %s %s.\n' "$kind" "$id"
      ) 9>"$lock_file"
    }

    notify_event() {
      kind=$1; due=$2; description=$3
      title=$(printf '%s' "$kind" | tr '[:lower:]' '[:upper:]')
      body="Due $(date -d "@$due" '+%Y-%m-%d %H:%M')"
      [ -n "$description" ] && body="$body - $description"
      notify-send -u critical "$title" "$body" || true
      timeout 1 pw-play "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga" >/dev/null 2>&1 || true
    }

    scheduler() {
      started=$(date +%s)
      while :; do
        now=$(date +%s)
        event=$(mktemp)
        (
          flock -x 9
          init_state
          jq --argjson started "$started" --argjson now "$now" \
            ' .events |= map(select(.due >= $started or .due > $now))' "$state_file" | write_state
          jq -c --argjson started "$started" --argjson now "$now" \
            '[.events[] | select(.due >= $started and .due <= $now)] | sort_by(.due) | .[0] // empty' "$state_file" > "$event"
          if [ -s "$event" ]; then
            jq --argjson id "$(jq -r .id "$event")" '.events |= map(select(.id != $id))' "$state_file" | write_state
          fi
        ) 9>"$lock_file"
        if [ -s "$event" ]; then
          kind=$(jq -r .kind "$event"); due=$(jq -r .due "$event"); description=$(jq -r '.description // empty' "$event")
          rm -f "$event"
          notify_event "$kind" "$due" "$description"
        else
          rm -f "$event"
        fi
        sleep 1
      done
    }

    waybar() {
      now=$(date +%s)
      init_state
      jq -cn --argjson now "$now" --slurpfile state "$state_file" '
        ($state[0].events | map(select((.id|numbers) and (.kind == "timer" or .kind == "alarm") and (.due|numbers) and .due >= $now)) | sort_by(.due) | .[0:3]) as $events |
        {text: ($events | map(if .kind == "timer" then "󰔛 " + (if (.due - $now) < 60 then ((.due - $now)|tostring) else (((.due - $now) / 3600)|floor|tostring|if length < 2 then "0" + . else . end) + ":" + ((((.due - $now) % 3600) / 60)|floor|tostring|if length < 2 then "0" + . else . end) end) else "󰥔 " + (.due | strftime("%H:%M")) end) | join("  ")), tooltip: ($events | map((.kind + " " + (.due | strftime("%Y-%m-%d %H:%M")) + (if .description then " - " + .description else "" end))) | join("\n"))}
      '
    }

    command=''${1:-}
    case "$command" in
      timer) [ "$#" -ge 2 ] || usage; case "$2" in list) list_events timer ;; cancel) [ "$#" = 3 ] || usage; cancel_event timer "$3" ;; *) [ "$#" = 2 ] || usage; create_timer "$2" ;; esac ;;
      alarm) [ "$#" -ge 2 ] || usage; case "$2" in list) list_events alarm ;; cancel) [ "$#" = 3 ] || usage; cancel_event alarm "$3" ;; *) create_alarm ''${@:2} ;; esac ;;
      scheduler) scheduler ;;
      waybar) waybar ;;
      *) usage ;;
    esac
  '';
  timer = pkgs.writeShellScriptBin "timer" ''exec ${runtime}/bin/alarm-runtime timer "$@"'';
  alarm = pkgs.writeShellScriptBin "alarm" ''exec ${runtime}/bin/alarm-runtime alarm "$@"'';
  scheduler = pkgs.writeShellScriptBin "alarm-scheduler" ''exec ${runtime}/bin/alarm-runtime scheduler'';
  waybar = pkgs.writeShellScriptBin "alarm-waybar" ''exec ${runtime}/bin/alarm-runtime waybar'';
in
{
  options.custom.alarms-timers.enable = lib.mkEnableOption "terminal alarms and timers";

  config = lib.mkIf cfg.enable {
    home.packages = [ timer alarm scheduler waybar pkgs.jq pkgs.libnotify pkgs.pipewire pkgs.sound-theme-freedesktop ];

    home.activation.alarmsTimersState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/.local/state/alarm"
      if [ ! -s "$HOME/.local/state/alarm/events.json" ]; then
        run printf '%s\n' '{"nextId":1,"events":[]}' > "$HOME/.local/state/alarm/events.json"
      fi
    '';

    systemd.user.services.alarm-scheduler = {
      Unit = {
        Description = "Terminal alarm and timer scheduler";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${scheduler}/bin/alarm-scheduler";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
