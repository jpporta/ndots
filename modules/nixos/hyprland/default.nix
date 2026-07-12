{
  config,
  lib,
  pkgs,
  ...
}:

{

  options.custom = {
    hyprland.enable = lib.mkEnableOption "enable hyprland - system window manger and compositor";
  };

  config = lib.mkIf config.custom.hyprland.enable {

    programs.dconf.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    security.polkit.enable = true;
  };
}
