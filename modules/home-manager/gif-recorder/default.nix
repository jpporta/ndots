{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.gif-recorder;

  gif-recorder = pkgs.writeShellApplication {
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
      wl-copy --foreground --type image/gif < "$output" &
    '';
  };
in
{
  options.custom.gif-recorder.enable = lib.mkEnableOption "Wayland region GIF recorder";

  config = lib.mkIf cfg.enable {
    home.packages = [ gif-recorder ];
  };
}
