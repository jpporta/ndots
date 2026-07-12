{ config, lib, pkgs, ... }:

let
  cfg = config.custom.dictation;

  # AMD GPU: Vulkan backend (works on any RADV-capable Radeon, no ROCm stack).
  # Swap to { rocmSupport = true; } if you'd rather use ROCm (see notes).
  whisper = pkgs.whisper-cpp.override { vulkanSupport = true; };

  # Declaratively pinned GGML model. Build once with the default fakeHash and
  # paste back the sha256 Nix reports.
  model = pkgs.fetchurl {
    url  = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${cfg.model}.bin";
    hash = cfg.modelHash;
  };

  port = toString cfg.port;

  histRel = "dictation/history.jsonl";

  dictate = pkgs.writeShellApplication {
    name = "dictate-toggle";
    runtimeInputs = with pkgs; [ pipewire curl jq wtype wl-clipboard libnotify coreutils ];
    text = ''
      # -c / --clipboard: put the transcript on the clipboard instead of typing it.
      clipboard=0
      case "''${1:-}" in
        -c|--clipboard) clipboard=1 ;;
      esac

      run="''${XDG_RUNTIME_DIR:-/tmp}"
      pid="$run/dictate.pid"
      wav="$run/dictate.wav"
      hist="''${XDG_STATE_HOME:-$HOME/.local/state}/${histRel}"

      if [ -f "$pid" ] && kill -0 "$(cat "$pid")" 2>/dev/null; then
        # ---- second press: stop, transcribe, type ----
        kill "$(cat "$pid")" 2>/dev/null || true
        rm -f "$pid"
        sleep 0.2

        # ignore fat-finger taps (<~0.5s @ 16kHz*2B mono = 16000 bytes)
        bytes="$(stat -c%s "$wav" 2>/dev/null || echo 0)"
        if [ "$bytes" -lt 16000 ]; then
          notify-send -t 1000 -a dictation "🎤 too short"
          rm -f "$wav"; exit 0
        fi

        notify-send -t 1200 -a dictation "🧠 transcribing…"
        args=(-sS "http://127.0.0.1:${port}/inference"
              -F file=@"$wav" -F temperature=0 -F response_format=json
              -F language=${cfg.language})

        result="$(curl "''${args[@]}" | jq -r '.text' \
                  | tr '\n' ' ' \
                  | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')"

        if [ -n "$result" ]; then
          # log it (newest last), then keep only the most recent N entries
          mkdir -p "$(dirname "$hist")"
          jq -cn --arg ts "$(date -Is)" --arg text "$result" \
            '{ts: $ts, text: $text}' >> "$hist"
          tmp="$(mktemp -p "$(dirname "$hist")")"
          tail -n ${toString cfg.historyMax} "$hist" > "$tmp" && mv -f "$tmp" "$hist"

          if [ "$clipboard" -eq 1 ]; then
            printf '%s' "$result" | wl-copy
            notify-send -t 1500 -a dictation "📋 copied to clipboard"
          else
            wtype -- "$result"
          fi
        fi
        rm -f "$wav"
      else
        # ---- first press: start recording ----
        rm -f "$wav"
        pw-record --rate 16000 --channels 1 --format s16 "$wav" &
        echo "$!" > "$pid"
        notify-send -t 1200 -a dictation "🎤 recording — F5 to stop"
      fi
    '';
  };

  history = pkgs.writeShellApplication {
    name = "dictate-history";
    runtimeInputs = with pkgs; [ jq rofi wl-clipboard libnotify coreutils ];
    text = ''
      hist="''${XDG_STATE_HOME:-$HOME/.local/state}/${histRel}"

      if [ ! -s "$hist" ]; then
        notify-send -t 1500 -a dictation "📋 no dictation history yet"
        exit 0
      fi

      # newest first; keep full texts and menu rows index-aligned
      mapfile -t texts < <(tac "$hist" | jq -r '.text')
      mapfile -t menu  < <(tac "$hist" | jq -r '
        (.ts[5:16] | sub("T"; " ")) as $t
        | (if (.text | length) > 60 then .text[0:60] + "…" else .text end) as $p
        | "\($t)  \($p)"')

      idx="$(printf '%s\n' "''${menu[@]}" \
             | rofi -dmenu -i -format i -p "dictation" || true)"
      [[ "$idx" =~ ^[0-9]+$ ]] || exit 0

      printf '%s' "''${texts[$idx]}" | wl-copy
      notify-send -t 1500 -a dictation "📋 copied to clipboard"
    '';
  };
in
{
  options.custom.dictation = {
    enable = lib.mkEnableOption "local F5 push-to-talk dictation (whisper.cpp + wtype)";

    model = lib.mkOption {
      type = lib.types.str;
      default = "large-v3";
      description = ''GGML model stem, e.g. "large-v3" or "large-v3-turbo".'';
    };

    modelHash = lib.mkOption {
      type = lib.types.str;
      default = lib.fakeHash;
      description = "sha256 of the model. Build once with the default, paste the reported hash.";
    };

    language = lib.mkOption {
      type = lib.types.str;
      default = "auto";
      description = ''Pin a language ("en", "pt") or "auto" to detect per utterance.'';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8117;
    };

    historyMax = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "Keep only the most recent N transcriptions in the history log.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ dictate history whisper ]; # whisper-cli also available for testing

    systemd.user.services.whisper-server = {
      Unit = {
        Description = "whisper.cpp server (keeps the model warm in VRAM)";
        After = [ "graphical-session.target" ];
      };
      Service = {
        # If your build names it 'whisper-whisper-server', adjust the path below
        # (nixpkgs has occasionally double-prefixed it). `ls ${whisper}/bin`.
        ExecStart = lib.escapeShellArgs [
          "${whisper}/bin/whisper-server"
          "--model" "${model}"
          "--host"  "127.0.0.1"
          "--port"  port
          "--max-len" "100000"  # default 0 is silently coerced to 60; large = don't chop
        ];
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
