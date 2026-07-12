{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.awww;

  # Picks a random image from the (mutable) wallpaper dir at runtime and hands
  # it to the running daemon. Only this script lives in the nix store — the
  # images are read live on every cycle, so they are never copied into the store.
  cycleScript = pkgs.writeShellScript "awww-cycle" ''
    set -euo pipefail
    dir="${cfg.wallpaperDir}"

    if [ ! -d "$dir" ]; then
      echo "awww-cycle: wallpaper dir '$dir' does not exist" >&2
      exit 0
    fi

    # -L follows symlinks, so $dir (or files inside it) may be symlinks.
    img="$(${pkgs.findutils}/bin/find -L "$dir" -type f \
      \( -iname '*.jpg'  -o -iname '*.jpeg' -o -iname '*.png' \
      -o -iname '*.webp' -o -iname '*.bmp'  -o -iname '*.gif' \) \
      | ${pkgs.coreutils}/bin/shuf -n1)"

    if [ -z "''${img:-}" ]; then
      echo "awww-cycle: no images found in '$dir'" >&2
      exit 0
    fi

    exec ${lib.getExe cfg.package} img "$img" \
      --transition-type "${cfg.transition.type}" \
      --transition-fps ${toString cfg.transition.fps} \
      --transition-step ${toString cfg.transition.step} \
      --transition-duration ${cfg.transition.duration}
  '';
in
{
  options.custom.awww = {
    enable = lib.mkEnableOption "awww (ex-swww) animated wallpaper daemon with timed random cycling";

    package = lib.mkPackageOption pkgs "awww" { };

    wallpaperDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Wallpapers";
      description = ''
        Directory scanned at runtime for wallpapers. Its contents are read live on
        every cycle and are never copied into the nix store, so you can add, remove
        or edit images freely without a rebuild. Symlinks are followed.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "15min";
      example = "1h";
      description = "How often to switch wallpaper, as a systemd time span.";
    };

    transition = {
      type = lib.mkOption {
        type = lib.types.str;
        default = "random";
        example = "grow";
        description = "awww --transition-type (random, grow, wipe, fade, simple, outer, center, any, ...).";
      };
      fps = lib.mkOption {
        type = lib.types.int;
        default = 60;
        description = "awww --transition-fps.";
      };
      step = lib.mkOption {
        type = lib.types.int;
        default = 90;
        description = "awww --transition-step (how abruptly the transition advances).";
      };
      duration = lib.mkOption {
        type = lib.types.str;
        default = "1.5";
        description = "awww --transition-duration, in seconds.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Runs awww-daemon as a systemd user service, bound to graphical-session.target
    # and gated on WAYLAND_DISPLAY. Also installs the awww package.
    services.awww = {
      enable = true;
      inherit (cfg) package;
    };

    # Ensure the wallpaper directory exists (left empty and mutable — you own it).
    home.activation.createWallpaperDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.escapeShellArg cfg.wallpaperDir}
    '';

    # Oneshot that sets a single random wallpaper. Waits for the daemon to be up.
    systemd.user.services.awww-cycle = {
      Unit = {
        Description = "Set a random wallpaper via awww";
        After = [ "awww.service" ];
        Requires = [ "awww.service" ];
        PartOf = [ config.wayland.systemd.target ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${cycleScript}";
      };
    };

    # Timer that fires the oneshot shortly after login and then every ${interval}.
    # Tied to the graphical session, so it starts/stops with Hyprland.
    systemd.user.timers.awww-cycle = {
      Unit = {
        Description = "Cycle wallpaper every ${cfg.interval} via awww";
        PartOf = [ config.wayland.systemd.target ];
      };
      Timer = {
        OnActiveSec = "3s";
        OnUnitActiveSec = cfg.interval;
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
  };
}
