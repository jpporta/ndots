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
    xdg.configFile."alacritty/colors.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/themes/.active/alacritty/colors.toml";

    programs.alacritty = {
      enable = true;
      settings = {
        import = [
          "~/.config/alacritty/colors.toml"
        ];
        font = {
          size = 10.3;
          normal = {
            family = "BerkeleyMono Nerd Font Mono";
          };
          bold = {
            family = "BerkeleyMono Nerd Font Mono";
          };
          italic = {
            family = "BerkeleyMono Nerd Font Mono";
          };
          bold_italic = {
            family = "BerkeleyMono Nerd Font Mono";
          };
        };
        window = {
          decorations = "None";
          opacity = 0.8;
          blur = true;
          dynamic_padding = true;
          padding = {
            x = 10;
            y = 16;
          };
        };
        keyboard = {
          bindings = [
            {
              key = "Return";
              mods = "Shift";
              chars = "\u001B\r";
            }
          ];
        };
      };
    };
  };
}