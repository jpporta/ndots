{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Tiki kitty session manager
  tiki = pkgs.buildGoModule {
    pname = "tiki";
    version = "0.6.1";
    src = pkgs.fetchFromGitHub {
      owner = "boolean-maybe";
      repo = "tiki";
      tag = "v0.6.1";
      hash = "sha256-uxdgB13rHwWperjuFMznUyP/70r4h2drVxSGSGFzYyM=";
    };
    vendorHash = "sha256-vV8iBVdurcMUC7kwkAlnSt6cI4gNFRg721rkSuuOC2g=";
    nativeCheckInputs = [ pkgs.git ];
    ldflags = [
      "-s"
      "-w"
      "-X github.com/boolean-maybe/tiki/config.Version=0.6.1"
    ];
  };

  # Mediaplayer Python helper for waybar
  mediaplayerPython = pkgs.python3.withPackages (ps: with ps; [ pygobject3 ]);
  mediaplayerPythonScript = pkgs.writeShellScriptBin "mediaplayer-python" ''
    export GI_TYPELIB_PATH=${pkgs.playerctl}/lib/girepository-1.0''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}
    exec ${mediaplayerPython}/bin/python3 "$@"
  '';

  # Bitwarden CLI wrappers
  bw = pkgs.writeShellApplication {
    name = "bw";
    runtimeInputs = with pkgs; [
      rbw
      fzf
      wl-clipboard
      libnotify
    ];
    text = ''
      set -euo pipefail
      cmd="$(basename "$0")"

      entry="$(rbw list --fields=id,name,user | fzf --with-nth=2.. --delimiter=$'\t')"
      [ -z "$entry" ] && exit 0

      id="$(printf '%s' "$entry" | cut -f1)"

      case "$cmd" in
        bwc) val="$(rbw code "$id")"                          ;;
        bwu) val="$(rbw get --field username "$id")"          ;;
        bwp) val="$(rbw get "$id")"                           ;;
        *)   exit 1                                            ;;
      esac

      printf '%s' "$val" | wl-copy
      exit 0
    '';
  };
  bwp = pkgs.symlinkJoin {
    name = "bwp";
    paths = [ bw ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = "ln -sf ${bw}/bin/bw $out/bin/bwp";
  };
  bwc = pkgs.symlinkJoin {
    name = "bwc";
    paths = [ bw ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = "ln -sf ${bw}/bin/bw $out/bin/bwc";
  };
  bwu = pkgs.symlinkJoin {
    name = "bwu";
    paths = [ bw ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = "ln -sf ${bw}/bin/bw $out/bin/bwu";
  };

  # Offline dictionary tool
  dict = pkgs.writeShellApplication {
    name = "dict";
    runtimeInputs = with pkgs; [
      sdcv
      gnused
      pandoc
      coreutils
    ];
    text = ''
      [ $# -eq 0 ] && { echo "usage: dict <word>"; exit 1; }

      mark=""
      if [ -t 1 ]; then mark=@@; fi

      { sdcv -n "$@" 2>/dev/null || true; } |
        sed -e 's/^Found \(.*\)$/Found \1<br>/' \
            -e "s/^-->\\(.*\\)$/<b>''${mark}\\1<\\/b><br>/" |
        pandoc -f html -t plain --wrap=none |
        if [ -n "$mark" ]; then
          sed -E \
            -e 's/^(Found .*items.*)$/\x1b[2m\1\x1b[0m/' \
            -e 's/^@@(.*)$/\x1b[1;35m\1\x1b[0m/' \
            -e 's/^([A-Z][a-zA-Z]*)$/\x1b[1;36m\1\x1b[0m/' \
            -e 's/^([A-Z]{2,3}: .*)$/\x1b[36m\1\x1b[0m/' \
            -e 's/^([[:space:]]*)([0-9]+\.)[[:space:]]/\1\x1b[1;33m\2\x1b[0m /' \
            -e 's/^([[:space:]]*)([a-z]+\.)([[:space:]])/\1\x1b[2m\2\x1b[0m\3/'
        else
          cat
        fi
    '';
  };

  # Dictation tools
  dictateToggle = pkgs.writeShellApplication {
    name = "dictate-toggle";
    runtimeInputs = with pkgs; [
      pipewire
      curl
      jq
      wtype
      wl-clipboard
      libnotify
      coreutils
    ];
    text = ''
      clipboard=0
      case "''${1:-}" in
        -c|--clipboard) clipboard=1 ;;
      esac

      run="''${XDG_RUNTIME_DIR:-/tmp}"
      pid="$run/dictate.pid"
      wav="$run/dictate.wav"
      hist="''${XDG_STATE_HOME:-$HOME/.local/state}/dictation/history.jsonl"

      if [ -f "$pid" ] && kill -0 "$(cat "$pid")" 2>/dev/null; then
        kill "$(cat "$pid")" 2>/dev/null || true
        rm -f "$pid"
        sleep 0.2

        bytes="$(stat -c%s "$wav" 2>/dev/null || echo 0)"
        if [ "$bytes" -lt 16000 ]; then
          notify-send -t 1000 -a dictation "🎤 too short"
          rm -f "$wav"
          exit 0
        fi

        resp=$(curl -sS --fail -F file="@$wav" -F response_format=json "http://127.0.0.1:8080/inference" 2>/dev/null || true)
        rm -f "$wav"

        text=$(printf '%s' "$resp" | jq -r '.text // empty' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -z "$text" ]; then
          notify-send -t 1500 -a dictation "🎤 (no speech detected)"
          exit 0
        fi

        mkdir -p "$(dirname "$hist")"
        jq -cn --arg t "$(date -Iseconds)" --arg s "$text" '{ts: $t, text: $s}' >> "$hist"

        if [ "$clipboard" -eq 1 ]; then
          printf '%s' "$text" | wl-copy
          notify-send -t 1500 -a dictation "📋 copied" "$text"
        else
          wtype -s 10 -- "$text"
        fi
      else
        rm -f "$wav"
        pw-record --rate 16000 --channels 1 --format s16 "$wav" >/dev/null 2>&1 &
        echo $! > "$pid"
        notify-send -t 1000 -a dictation "🎤 recording..."
      fi
    '';
  };

  dictateHistory = pkgs.writeShellApplication {
    name = "dictate-history";
    runtimeInputs = with pkgs; [
      jq
      fzf
      wl-clipboard
      libnotify
      coreutils
    ];
    text = ''
      hist="''${XDG_STATE_HOME:-$HOME/.local/state}/dictation/history.jsonl"
      [ -f "$hist" ] || exit 0
      sel=$(tac "$hist" | jq -r '.text' | fzf --no-sort --prompt="dictate history> ") || exit 0
      printf '%s' "$sel" | wl-copy
      notify-send -t 1500 -a dictation "📋 copied" "$sel"
    '';
  };

  # Pipewire audio sample rate switcher
  audioRateScript = pkgs.writeShellApplication {
    name = "audio-rate";
    runtimeInputs = with pkgs; [
      pipewire
      libnotify
      coreutils
      gnused
    ];
    text = ''
      show_status() {
        rate="$(pw-metadata -n settings 0 clock.rate 2>/dev/null | sed -n "s/.*value:'\([^']*\)'.*/\1/p" || true)"
        force="$(pw-metadata -n settings 0 clock.force-rate 2>/dev/null | sed -n "s/.*value:'\([^']*\)'.*/\1/p" || true)"
        allowed="$(pw-metadata -n settings 0 clock.allowed-rates 2>/dev/null | sed -n "s/.*value:'\([^']*\)'.*/\1/p" || true)"

        if [ -z "$rate" ]; then
          echo "PipeWire settings metadata not available."
          exit 1
        fi

        echo "PipeWire Sample Rate Status:"
        echo "  Active rate:  ''${rate} Hz"
        if [ "$force" = "0" ] || [ -z "$force" ]; then
          echo "  Mode:         Dynamic / Auto"
          if [ -n "$allowed" ]; then
            echo "  Allowed:      ''${allowed}"
          fi
        else
          echo "  Mode:         Locked / Forced at ''${force} Hz"
        fi
      }

      set_rate() {
        target="$1"
        case "$target" in
          auto|0|dynamic|reset)
            pw-metadata -n settings 0 clock.force-rate 0 >/dev/null
            notify-send -t 1500 -a "Audio Rate" "PipeWire Rate" "Reset to Dynamic/Auto mode"
            echo "Clock rate reset to auto (dynamic switching enabled)."
            ;;
          44100|48000|88200|96000|176400|192000|352800|384000)
            pw-metadata -n settings 0 clock.force-rate "$target" >/dev/null
            notify-send -t 1500 -a "Audio Rate" "PipeWire Rate Locked" "Locked to ''${target} Hz"
            echo "Clock rate forced to ''${target} Hz."
            ;;
          *)
            echo "Invalid rate: $target" >&2
            echo "Supported: 44100, 48000, 88200, 96000, 176400, 192000, auto" >&2
            exit 1
            ;;
        esac
      }

      case "''${1:-status}" in
        status) show_status ;;
        set) [ $# -ge 2 ] || { echo "Usage: audio-rate set <rate|auto>"; exit 1; }; set_rate "$2" ;;
        auto) set_rate auto ;;
        [0-9]*) set_rate "$1" ;;
        *) echo "Usage: audio-rate [status | set <rate> | auto]"; exit 1 ;;
      esac
    '';
  };

  virtualMicScript = pkgs.writeShellApplication {
    name = "virtual-mic";
    runtimeInputs = with pkgs; [
      pipewire
      libnotify
      coreutils
    ];
    text = ''
      case "''${1:-status}" in
        create)
          pw-link -i >/dev/null 2>&1 || true
          notify-send -t 1500 -a "Virtual Mic" "Virtual Mic" "Loaded"
          ;;
        status)
          echo "Virtual mic manager"
          ;;
        *)
          echo "Usage: virtual-mic [create|status]"
          exit 1
          ;;
      esac
    '';
  };

  # Alarms & Timers runtime
  alarmRuntime = pkgs.writeShellScriptBin "alarm-runtime" ''
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
  timerPkg = pkgs.writeShellScriptBin "timer" ''exec ${alarmRuntime}/bin/alarm-runtime timer "$@"'';
  alarmPkg = pkgs.writeShellScriptBin "alarm" ''exec ${alarmRuntime}/bin/alarm-runtime alarm "$@"'';
  alarmSchedulerPkg = pkgs.writeShellScriptBin "alarm-scheduler" ''exec ${alarmRuntime}/bin/alarm-runtime scheduler'';
  alarmWaybarPkg = pkgs.writeShellScriptBin "alarm-waybar" ''exec ${alarmRuntime}/bin/alarm-runtime waybar'';

  # Power profiles script
  powerProfileScript = pkgs.writeShellScriptBin "power-profile" ''
    set -euo pipefail

    STATE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/power-profile"
    ACTIVE_LINK="''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hypridle-active.conf"

    current="normal"
    if [ -f "$STATE_FILE" ]; then
      current=$(cat "$STATE_FILE" || true)
      case "$current" in
        normal|caffeinated|headless) ;;
        *) current="normal" ;;
      esac
    fi

    cmd="''${1:-status}"
    new=""

    case "$cmd" in
      normal|caffeinated|headless) new="$cmd" ;;
      next)
        case "$current" in
          normal) new="caffeinated" ;;
          caffeinated) new="headless" ;;
          headless) new="normal" ;;
          *) new="normal" ;;
        esac
        ;;
      prev)
        case "$current" in
          normal) new="headless" ;;
          headless) new="caffeinated" ;;
          caffeinated) new="normal" ;;
          *) new="normal" ;;
        esac
        ;;
      status) echo "$current"; exit 0 ;;
      *) echo "Usage: power-profile {next|prev|normal|caffeinated|headless|status}" >&2; exit 1 ;;
    esac

    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$new" > "$STATE_FILE"

    mkdir -p "$(dirname "$ACTIVE_LINK")"
    target="$HOME/.config/hypr/hypridle-$new.conf"
    ln -sfn "$target" "$ACTIVE_LINK"

    if command -v systemctl >/dev/null 2>&1; then
      systemctl --user restart power-profile-hypridle.service 2>/dev/null || true
    fi

    pkill -RTMIN+8 waybar 2>/dev/null || true
    echo "$new"
  '';

  waybarProfileScript = pkgs.writeShellScriptBin "power-profile-waybar" ''
    state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/power-profile"
    profile="normal"
    if [ -f "$state_file" ]; then
      profile=$(cat "$state_file" || true)
      case "$profile" in
        normal|caffeinated|headless) ;;
        *) profile="normal" ;;
      esac
    fi

    case "$profile" in
      caffeinated)
        text=""
        tooltip="Caffeinated — display and system stay awake"
        cls="caffeinated"
        ;;
      headless)
        text=""
        tooltip="Headless — screen blanks/locks, no suspend"
        cls="headless"
        ;;
      *)
        text="󰍹"
        tooltip="Normal — default idle behavior"
        cls="normal"
        ;;
    esac

    printf '{"text":"%s","tooltip":"%s","class":"%s","alt":"%s"}\n' \
      "$text" "$tooltip" "power-profile-$cls" "power-profile-$cls"
  '';

  # Pinentry wrapper
  pinentryWrapper = pkgs.writeShellScriptBin "pinentry-wrapper" ''
    if [ -n "''${SSH_CONNECTION:-}" ] \
       || [ -n "''${SSH_TTY:-}" ] \
       || [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
    else
      exec ${pkgs.pinentry-rofi}/bin/pinentry-rofi "$@"
    fi
  '';

  # GIF recorder
  gifRecorder = pkgs.writeShellApplication {
    name = "gif-recorder";
    runtimeInputs = with pkgs; [
      coreutils
      ffmpeg
      slurp
      wf-recorder
      wl-clipboard
    ];
    text = ''
      runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}"
      state="$runtime_dir/gif-recorder.pid"
      selection=""
      video=""
      gif_tmp=""
      child_pid=""
      stopped=0

      cleanup() {
        rm -f "$state" "$selection" "$video" "$gif_tmp"
      }

      stop_child() {
        stopped=1
        if [ -n "$child_pid" ]; then
          kill -INT "$child_pid" 2>/dev/null || true
        fi
      }

      trap cleanup EXIT
      trap stop_child INT TERM

      if [ -f "$state" ]; then
        active_pid="$(cat "$state" 2>/dev/null || true)"
        if [ -n "$active_pid" ] && kill -0 "$active_pid" 2>/dev/null; then
          kill -INT "$active_pid" 2>/dev/null || true
          exit 0
        fi
        rm -f "$state"
      fi

      echo "$$" > "$state"
      selection="$(mktemp "$runtime_dir/gif-recorder-selection.XXXXXX")"
      slurp > "$selection" &
      child_pid="$!"
      selection_status=0
      wait "$child_pid" || selection_status="$?"
      child_pid=""

      if [ "$stopped" -eq 1 ] || [ "$selection_status" -ne 0 ]; then
        exit 0
      fi

      geometry="$(cat "$selection")"
      video="$(mktemp "$runtime_dir/gif-recorder.XXXXXX.mkv")"
      wf-recorder --geometry "$geometry" -f "$video" &
      child_pid="$!"
      recorder_status=0
      wait "$child_pid" || recorder_status="$?"
      child_pid=""

      if [ "$stopped" -ne 1 ] || { [ "$recorder_status" -ne 0 ] && [ "$recorder_status" -ne 130 ]; }; then
        exit 1
      fi

      output_dir="$HOME/Pictures/Screenshots"
      mkdir -p "$output_dir"
      gif_tmp="$(mktemp "$runtime_dir/gif-recorder.XXXXXX.gif")"
      ffmpeg -y -i "$video" \
        -vf 'fps=15,scale=960:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=256[p];[s1][p]paletteuse=dither=sierra2_4a' \
        "$gif_tmp"

      output="$output_dir/gif-$(date +%Y%m%d-%H%M%S-%N).gif"
      mv "$gif_tmp" "$output"
      gif_tmp=""

      wl-copy < "$output"
      notify-send -a gif-recorder "GIF saved" "$output (copied to clipboard)"
    '';
  };

  # Little Coder
  littleCoder = pkgs.buildNpmPackage {
    pname = "little-coder";
    version = "1.18.0";
    src = pkgs.fetchFromGitHub {
      owner = "itayinbarr";
      repo = "little-coder";
      rev = "c97e319ff99445ff0be68d799847a376e12bf231";
      hash = "sha256-cTL4mUwLqIlSiDpW5LIA9kMaBfIOnNVEPV8x/t2GFr0=";
    };
    npmDepsHash = "sha256-DWcOORLE5nOCd0nMqiq5sO/0fllt4o2WkOG972giZ9E=";
    dontNpmBuild = true;
    makeCacheWritable = true;
    env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };

  # Leaf Markdown Viewer
  leaf = pkgs.rustPlatform.buildRustPackage {
    pname = "leaf-markdown-viewer";
    version = "1.28.2";
    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      rev = "1.28.2";
      hash = "sha256-WX9C4gWNPCHWFsHN4xFmShv6dJyYAVgr9xMw5JtoFHI=";
    };
    cargoLock.lockFile = ./leaf-Cargo.lock;
    meta = {
      description = "Terminal Markdown previewer with a GUI-like experience";
      homepage = "https://leaf.rivolink.mg";
      license = lib.licenses.mit;
      mainProgram = "leaf";
    };
  };

  # Whisper CPP for dictation
  whisperCpp = pkgs.whisper-cpp.override { vulkanSupport = true; };
in
{
  environment.systemPackages =
    with pkgs;
    [
      # Custom tools & scripts
      tiki
      mediaplayerPythonScript
      bwp
      bwc
      bwu
      bw
      dict
      dictateToggle
      dictateHistory
      whisperCpp
      audioRateScript
      virtualMicScript
      alarmRuntime
      timerPkg
      alarmPkg
      alarmSchedulerPkg
      alarmWaybarPkg
      powerProfileScript
      waybarProfileScript
      pinentryWrapper
      gifRecorder
      littleCoder
      leaf

      # Core CLI & shell utilities
      stow
      tree
      worktrunk
      zoxide
      fzf
      eza
      fd
      bc
      wget
      which
      entr
      fastfetch
      tldr
      silicon
      expect
      jq
      killall
      gnupg
      pinentry-gtk2
      pinentry-curses
      pinentry-rofi
      pinentry-gnome3
      delta
      tig
      bat
      bat-extras.core
      direnv
      nix-direnv
      oh-my-posh

      # Communication & fun
      cbonsai
      asciiquarium
      pipes
      asciinema
      croc
      ttyd
      jrnl
      newsboat
      python314Packages.faker
      grex
      sl

      # Editors & dev tooling
      ffmpeg
      chromium
      neovim
      vim
      tree-sitter
      stylua
      lua5_1
      luarocks
      ruby
      git
      gh
      lazygit
      tmux
      sesh
      serie
      gcc
      gnumake
      pandoc
      typst
      tectonic
      mkcert
      sqlc
      rainfrog
      unzip
      zip
      go
      cargo
      rustc
      php
      julia
      imagemagick
      ghostscript
      ripgrep
      kubectl
      kubernetes-helm
      k9s
      docker-compose
      jujutsu
      nodejs
      pnpm
      diffnav
      mitmproxy
      openspec

      # Hyprland / Wayland desktop
      alacritty
      kitty
      mermaid-cli
      hyprshot
      waybar
      wofi
      wlogout
      rofi
      quickshell
      grim
      slurp
      wf-recorder
      wl-clipboard
      wl-color-picker
      swayimg
      wev
      wiremix
      matugen
      dmenu-wayland
      udiskie
      networkmanagerapplet
      pywal16
      hyprshutdown
      hypridle
      hyprlock
      hyprpaper
      hyprsunset
      swaynotificationcenter
      playerctl
      brightnessctl
      wtype

      # Theming & Fonts
      adw-gtk3
      bibata-cursors
      papirus-icon-theme
      papirus-folders
      rose-pine-hyprcursor
      nwg-look
      nerd-fonts.jetbrains-mono
      noto-fonts-color-emoji
      liberation_ttf
      libsForQt5.qtstyleplugin-kvantum

      # GUI apps
      firefox
      telegram-desktop
      koreader
      xauth
      easyeffects
      calibre
      sunshine
      ryubing
      obsidian
      obs-cmd
      qbittorrent
      zathura
      mpv
      yt-dlp
      libreoffice-fresh
      evolution
      slack
      spotify
      zoom-us
      localsend
      feishin
      darktable
      gthumb
      kdePackages.kdenlive
      shotcut
      video-trimmer
      kdePackages.dolphin
      thunar
      gnome-calendar
      gnome-clocks
      gnome-weather
      pass
      bluetuith
      cameractrls
      gphoto2
      gnuplot
      p7zip
      seahorse
      khal
      vdirsyncer
      ntfy-sh
      rbw
      ghgrab
      kew
      aria2
      kind
      ranger
      (inputs.slk.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (_: {
        doCheck = false;
      }))
    ]
    ++ [
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.superfile
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tuxedo
      (pkgs.unstable.herdr.overrideAttrs (old: {
        env = (old.env or { }) // {
          RUSTFLAGS =
            (old.env.RUSTFLAGS or old.RUSTFLAGS or "") + " -C link-arg=-Wl,--no-eh-frame-hdr";
        };
      }))
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent
      pkgs.unstable.claude-code
      pkgs.unstable.antigravity-cli
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta
    ];
}
