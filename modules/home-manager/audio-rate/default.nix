{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.audio-rate;

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
            notify-send -a "Audio Rate" "🎵 Audio Sample Rate" "Reset to Dynamic / Auto"
            echo "Audio rate set to Dynamic / Auto"
            ;;
          normal|48k|48000|48)
            pw-metadata -n settings 0 clock.force-rate 48000 >/dev/null
            notify-send -a "Audio Rate" "🎵 Audio Sample Rate" "Locked to 48 kHz (Normal)"
            echo "Audio rate locked to 48000 Hz"
            ;;
          hires|hi-res|384k|384000|384)
            pw-metadata -n settings 0 clock.force-rate 384000 >/dev/null
            notify-send -a "Audio Rate" "🎵 Audio Sample Rate" "Locked to 384 kHz (Hi-Res)"
            echo "Audio rate locked to 384000 Hz"
            ;;
          96k|96000|96)
            pw-metadata -n settings 0 clock.force-rate 96000 >/dev/null
            notify-send -a "Audio Rate" "🎵 Audio Sample Rate" "Locked to 96 kHz"
            echo "Audio rate locked to 96000 Hz"
            ;;
          192k|192000|192)
            pw-metadata -n settings 0 clock.force-rate 192000 >/dev/null
            notify-send -a "Audio Rate" "🎵 Audio Sample Rate" "Locked to 192 kHz"
            echo "Audio rate locked to 192000 Hz"
            ;;
          44.1k|44100|44)
            pw-metadata -n settings 0 clock.force-rate 44100 >/dev/null
            notify-send -a "Audio Rate" "🎵 Audio Sample Rate" "Locked to 44.1 kHz"
            echo "Audio rate locked to 44100 Hz"
            ;;
          [0-9]*)
            pw-metadata -n settings 0 clock.force-rate "$target" >/dev/null
            notify-send -a "Audio Rate" "🎵 Audio Sample Rate" "Locked to ''${target} Hz"
            echo "Audio rate locked to ''${target} Hz"
            ;;
          *)
            echo "Usage: audio-rate [status|auto|48k|384k|96k|192k|<rate>]"
            echo ""
            echo "Commands:"
            echo "  audio-rate                  Show current clock rate and mode"
            echo "  audio-rate auto             Reset to dynamic auto rate matching"
            echo "  audio-rate 48k (or normal)  Lock to 48 kHz (everyday / recording mode)"
            echo "  audio-rate 384k (or hires)  Lock to 384 kHz (hi-res music mode)"
            echo "  audio-rate <Hz>             Lock to custom sample rate"
            exit 1
            ;;
        esac
      }

      if [ $# -eq 0 ] || [ "''${1:-}" = "status" ] || [ "''${1:-}" = "-s" ]; then
        show_status
      else
        set_rate "$1"
      fi
    '';
  };

  virtualMicScript = pkgs.writeShellApplication {
    name = "virtual-mic";
    runtimeInputs = with pkgs; [ coreutils gawk gnugrep pulseaudio ];
    text = ''
      sink_name=virtual_mic
      source_name=virtual_mic_source

      loopback_module_ids() {
        pactl list short modules | awk -v sink="$sink_name" \
          '$2 == "module-loopback" && $0 ~ "sink=" sink "([[:space:]]|$)" { print $1 }'
      }

      source_module_ids() {
        pactl list short modules | awk -v source="$source_name" \
          '$2 == "module-remap-source" && $0 ~ "source_name=" source "([[:space:]]|$)" { print $1 }'
      }

      sink_module_ids() {
        pactl list short modules | awk -v sink="$sink_name" \
          '$2 == "module-null-sink" && $0 ~ "sink_name=" sink "([[:space:]]|$)" { print $1 }'
      }

      sink_exists() {
        pactl list short sinks | awk -v sink="$sink_name" '$2 == sink { found=1 } END { exit !found }'
      }

      source_exists() {
        pactl list short sources | awk -v source="$source_name" '$2 == source { found=1 } END { exit !found }'
      }

      start() {
        if ! sink_exists; then
          default_sink="$(pactl get-default-sink)"
          [ -n "$default_sink" ] || { echo "No default audio output found." >&2; exit 1; }
          pactl load-module module-null-sink \
            "sink_name=$sink_name" \
            "sink_properties=device.description=Virtual_Microphone" >/dev/null
        fi

        if ! loopback_module_ids | grep -q .; then
          default_sink="''${default_sink:-$(pactl get-default-sink)}"
          pactl load-module module-loopback \
            "source=$default_sink.monitor" \
            "sink=$sink_name" latency_msec=20 >/dev/null
        fi

        if ! source_exists; then
          pactl load-module module-remap-source \
            "master=$sink_name.monitor" \
            "source_name=$source_name" \
            "source_properties=device.description=Virtual_Microphone" >/dev/null
        fi

        echo "Virtual microphone ready: Virtual_Microphone"
      }

      stop() {
        while IFS= read -r id; do
          [ -n "$id" ] && pactl unload-module "$id"
        done < <(source_module_ids)
        while IFS= read -r id; do
          [ -n "$id" ] && pactl unload-module "$id"
        done < <(loopback_module_ids)
        while IFS= read -r id; do
          [ -n "$id" ] && pactl unload-module "$id"
        done < <(sink_module_ids)
        echo "Virtual microphone stopped."
      }

      status() {
        if sink_exists && source_exists; then
          echo "Virtual microphone is running: Virtual_Microphone"
        else
          echo "Virtual microphone is stopped."
        fi
      }

      case "''${1:-toggle}" in
        start) start ;;
        stop) stop ;;
        status) status ;;
        toggle) if sink_exists; then stop; else start; fi ;;
        *) echo "Usage: virtual-mic [start|stop|status|toggle]" >&2; exit 2 ;;
      esac
    '';
  };
in
{
  options.custom.audio-rate = {
    enable = lib.mkEnableOption "audio-rate sample rate switcher for PipeWire";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ audioRateScript virtualMicScript ];
  };
}
