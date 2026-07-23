{
  lib,
  config,
  pkgs,
  ...
}:

let
  pinentry-wrapper = pkgs.writeShellScriptBin "pinentry-wrapper" ''
    if [ -n "''${SSH_CONNECTION:-}" ] || [ -n "''${SSH_TTY:-}" ]; then
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
