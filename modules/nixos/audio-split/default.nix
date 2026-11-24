{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.audio-split;

  audioSplitScript = pkgs.writeShellApplication {
    name = "audio-split";
    runtimeInputs = with pkgs; [ coreutils gawk gnugrep pulseaudio ];
    text = ''
      sink_name=split_combined
      # Pulse node names of the two hardware sinks (from `wpctl status` / `pw-cli ls Node`).
      hw_sink_1="alsa_output.usb-Topping_DX1-00.HiFi__Headphones__sink"    # DX1 Headphones
      hw_sink_2="alsa_output.usb-Generic_USB_Audio-00.HiFi__Headphones__sink" # USB Audio Speakers

      loopback_for_sink_id() {
        pactl list short modules | awk -v t="$1" \
          '$2 == "module-loopback" && index($0, t) { print $1 }'
      }

      sink_module_ids() {
        pactl list short modules | awk -v s="$sink_name" \
          '$2 == "module-null-sink" && index($0, s) { print $1 }'
      }

      combined_sink_exists() {
        pactl list short sinks | awk -v s="$sink_name" '$2 == s { found=1 } END { exit !found }'
      }

      hw_sink_exists() {
        pactl list short sinks | awk -v n="$1" '$2 == n { found=1 } END { exit !found }'
      }

      start() {
        for hw in "$hw_sink_1" "$hw_sink_2"; do
          if ! hw_sink_exists "$hw"; then
            echo "Error: hardware sink '$hw' not found." >&2
            exit 1
          fi
        done

        if ! combined_sink_exists; then
          pactl load-module module-null-sink \
            "sink_name=$sink_name" \
            "sink_properties=device.description=Combined_Output" >/dev/null
        fi

        if ! loopback_for_sink_id "$hw_sink_1" | grep -q .; then
          pactl load-module module-loopback \
            "source=$sink_name.monitor" "sink=$hw_sink_1" latency_msec=20 >/dev/null
        fi

        if ! loopback_for_sink_id "$hw_sink_2" | grep -q .; then
          pactl load-module module-loopback \
            "source=$sink_name.monitor" "sink=$hw_sink_2" latency_msec=20 >/dev/null
        fi

        echo "Combined output ready (DX1 Headphones + USB Audio Speakers)."
        echo "Select it as the output: wpctl set-default <id-of-Combined_Output>"
      }

      stop() {
        for hw in "$hw_sink_1" "$hw_sink_2"; do
          while IFS= read -r id; do
            [ -n "$id" ] && pactl unload-module "$id"
          done < <(loopback_for_sink_id "$hw")
        done
        while IFS= read -r id; do
          [ -n "$id" ] && pactl unload-module "$id"
        done < <(sink_module_ids)
        echo "Combined output stopped."
      }

      status() {
        if combined_sink_exists; then
          echo "Combined output is running: Combined_Output"
        else
          echo "Combined output is stopped."
        fi
      }

      case "''${1:-toggle}" in
        start) start ;;
        stop) stop ;;
        status) status ;;
        toggle) if combined_sink_exists; then stop; else start; fi ;;
        *) echo "Usage: audio-split [start|stop|status|toggle]" >&2; exit 2 ;;
      esac
    '';
  };
in
{
  options.custom.audio-split = {
    enable = lib.mkEnableOption "audio-split split output for PipeWire";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ audioSplitScript ];
  };
}
