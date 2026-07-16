{ lib, config, ... }:
{
  options.custom.cedilla = {
    enable = lib.mkEnableOption "enable cedilla - apply Compose configuration for cedilla";

    startFcitx5 = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start the NixOS fcitx5 user service. Disable this when only the Compose
        rules are needed, for example on a non-NixOS Wayland host.
      '';
    };
  };

  config = lib.mkIf config.custom.cedilla.enable {
    home.file.".XCompose".text = ''
      include "%L"

      <dead_acute> <c> : "ç"  ccedilla
      <dead_acute> <C> : "Ç"  Ccedilla
    '';

    systemd.user.services.fcitx5 = lib.mkIf config.custom.cedilla.startFcitx5 {
      Unit = {
        Description = "Fcitx5 input method";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "/run/current-system/sw/bin/fcitx5";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
