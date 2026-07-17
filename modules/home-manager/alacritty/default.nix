{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{

  options.custom = {
    alacritty.enable = lib.mkEnableOption "enable alacritty terminal emulator";
  };

  config = lib.mkIf config.custom.alacritty.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 10.3;
          normal = {
            family = "BerkeleyMono Nerd Font Mono";
            style = "Regular";
          };
          bold = {
            family = "BerkeleyMono Nerd Font Mono";
            style = "ExtraBold";
          };
          italic = {
            family = "BerkeleyMono Nerd Font Mono";
            style = "Oblique";
          };
          bold_italic = {
            family = "BerkeleyMono Nerd Font Mono";
            style = "ExtraBold Oblique";
          };
        };
        window = {
          decorations = "None";
          opacity = 0.8;
          blur = false;
          dynamic_padding = true;
          padding = {
            x = 10;
            y = 16;
          };
        };
      };
    };
  };
}
