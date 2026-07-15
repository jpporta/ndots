{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.power-profiles;

  # ----- Hypridle configurations per profile ----------------------------------
  # Each profile is a separate hypridle config file. The script swaps which one
  # is active via a symlink and restarts the user service.

  caffeinatedConfig = pkgs.writeText "hypridle-caffeinated.conf" ''
    general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
    }
    # No listeners: screen never blanks, never locks, never suspends.
  '';

  headlessConfig = pkgs.writeText "hypridle-headless.conf" ''
    general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
      timeout = 4
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 5
      on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'
      on-resume = hyprctl dispatch 'hl.dsp.dpms({ action = "on" })'
    }
    # No suspend listener.
  '';

  normalConfig = pkgs.writeText "hypridle-normal.conf" ''
    general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch 'hl.dsp.dpms({ action = "on" })'
    }

    listener {
      timeout = 600
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 660
      on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'
      on-resume = hyprctl dispatch 'hl.dsp.dpms({ action = "on" })'
    }

    listener {
      timeout = 1800
      on-timeout = systemctl suspend
    }
  '';

  # ----- The control script ----------------------------------------------------
  # Implements `next`, `prev`, `<profile>`, and `status` subcommands.
  # Reads/writes the state file, swaps the hypridle config symlink, restarts
  # the systemd service, and signals waybar to refresh its module.

  powerProfileScript = pkgs.writeShellScriptBin "power-profile" ''
    set -euo pipefail

    STATE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/power-profile"
    ACTIVE_LINK="''${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hypridle-active.conf"

    PROFILES_NORMAL="normal"
    PROFILES_CAFFE="caffeinated"
    PROFILES_HEAD="headless"

    CAFFE_PATH=${caffeinatedConfig}
    HEAD_PATH=${headlessConfig}
    NORMAL_PATH=${normalConfig}

    # Read current profile (default to normal).
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
      normal|caffeinated|headless)
        new="$cmd"
        ;;
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
      status)
        echo "$current"
        exit 0
        ;;
      *)
        echo "Usage: power-profile {next|prev|normal|caffeinated|headless|status}" >&2
        exit 1
        ;;
    esac

    # Persist new state.
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$new" > "$STATE_FILE"

    # Swap the active hypridle config symlink.
    mkdir -p "$(dirname "$ACTIVE_LINK")"
    case "$new" in
      caffeinated) target="$CAFFE_PATH" ;;
      headless)    target="$HEAD_PATH" ;;
      *)           target="$NORMAL_PATH" ;;
    esac
    ln -sfn "$target" "$ACTIVE_LINK"

    # Restart hypridle (best-effort; may not be running on first invocation).
    if command -v systemctl >/dev/null 2>&1; then
      systemctl --user restart power-profile-hypridle.service 2>/dev/null \
        || echo "power-profile: warning, could not restart hypridle service" >&2
    fi

    # Refresh the waybar module (signal 8).
    pkill -RTMIN+8 waybar 2>/dev/null || true

    echo "$new"
  '';

  # ----- Waybar exec script ----------------------------------------------------
  # Reads the state file and emits the JSON consumed by the custom waybar module.

  waybarScript = pkgs.writeShellScriptBin "power-profile-waybar" ''
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

in
{
  options.custom.power-profiles = {
    enable = lib.mkEnableOption "power profile management (normal / caffeinated / headless) via hypridle";
  };

  config = lib.mkIf cfg.enable {
    # The script and the waybar helper are both installed on the user's PATH.
    home.packages = [
      powerProfileScript
      waybarScript
      pkgs.hypridle
    ];

    # We replace the default hypridle.service with our own service that is
    # driven by the active-profile symlink. Disable the standalone module
    # to avoid two hypridle processes fighting over the IPC socket.
    custom.hypridle.enable = lib.mkForce false;

    # The systemd user service that runs hypridle with the active config.
    # Started on graphical-session.target so it follows Hyprland's lifecycle.
    systemd.user.services.power-profile-hypridle = {
      Unit = {
        Description = "Hypridle using the active power-profile config";
        PartOf = [ config.wayland.systemd.target ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.hypridle}/bin/hypridle -c %h/.config/hypr/hypridle-active.conf";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };

    # Activation: create the XDG state dir, seed the state file, and set the
    # initial active-config symlink to whichever profile is in the state file
    # (defaulting to "normal"). Idempotent so it's safe on every rebuild.
    home.activation.powerProfileSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p $HOME/.local/state
      run mkdir -p $HOME/.config/hypr

      if [ ! -s $HOME/.local/state/power-profile ]; then
        run ${pkgs.coreutils}/bin/install -D -m 644 /dev/null $HOME/.local/state/power-profile
        run echo normal > $HOME/.local/state/power-profile
      fi

      current=$(${pkgs.coreutils}/bin/cat $HOME/.local/state/power-profile 2>/dev/null || echo normal)
      case "$current" in
        caffeinated) target=${caffeinatedConfig} ;;
        headless)    target=${headlessConfig} ;;
        *)           target=${normalConfig} ;;
      esac
      run ${pkgs.coreutils}/bin/ln -sfn "$target" $HOME/.config/hypr/hypridle-active.conf
    '';
  };
}
