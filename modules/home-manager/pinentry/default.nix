{
  lib,
  config,
  pkgs,
  ...
}:

let
  pinentry-wrapper = pkgs.writeShellScriptBin "pinentry-wrapper" ''
    # ponytail: gpg-agent's env is captured at boot (often on tty1), so SSH_* checks
    # from the agent miss SSH sessions. Fall back to curses when no usable display
    # is available, since rofi needs WAYLAND_DISPLAY/DISPLAY the agent may not have.
    if [ -n "''${SSH_CONNECTION:-}" ] \
       || [ -n "''${SSH_TTY:-}" ] \
       || [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
    else
      exec ${pkgs.pinentry-rofi}/bin/pinentry-rofi "$@"
    fi
  '';
in {
  options.custom.pinentry = {
    enable = lib.mkEnableOption "adaptive pinentry: rofi on TTY, curses on SSH";
  };

  config = lib.mkIf config.custom.pinentry.enable {
    home.packages = [ pinentry-wrapper ];

    services.gpg-agent = {
      enable = true;
      pinentry.package = pinentry-wrapper;
      enableSshSupport = true;
      defaultCacheTtl = 3600;
      maxCacheTtl = 86400;
    };
  };
}
