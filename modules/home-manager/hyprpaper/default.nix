
{
  config,
  lib,
  pkgs,
  ...
}:
let
    font = "BerkeleyMono Nerd Font Mono";
    monitor = "DP-1";
in{
  options.custom = {
    hyprpaper.enable = lib.mkEnableOption "enable hyprpaper - wallpaper manager";
  };

  config = lib.mkIf config.custom.hyprpaper.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        wallpaper = [
          {
            fit_mode = "cover";
            monitor = "DP-1";
            path = "/home/jpporta/dotfiles/colorschemes/.config/colorschemes/gruvbox-dark/wallpapers/wallhaven-9oxg98.jpg";
          }
        ];
      };
    };
  };
}
