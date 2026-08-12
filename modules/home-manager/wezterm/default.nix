{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.custom.wezterm.enable = lib.mkEnableOption "enable WezTerm terminal emulator";

  config = lib.mkIf config.custom.wezterm.enable {
    home.packages = [ pkgs.mdcat ];

    programs.wezterm = {
      enable = true;
      colorSchemes = {
        "Gruvbox Dark" = {
          ansi = [
            "#282828"
            "#cc241d"
            "#98971a"
            "#d79921"
            "#458588"
            "#b16286"
            "#689d6a"
            "#a89984"
          ];
          brights = [
            "#928374"
            "#fb4934"
            "#b8bb26"
            "#fabd2f"
            "#83a598"
            "#d3869b"
            "#8ec07c"
            "#ebdbb2"
          ];
          background = "#282828";
          foreground = "#ebdbb2";
          cursor_bg = "#ebdbb2";
          cursor_fg = "#282828";
          cursor_border = "#ebdbb2";
          selection_bg = "#504945";
          selection_fg = "#ebdbb2";
        };
      };
      settings = {
        color_scheme = "Gruvbox Dark";
        font = lib.generators.mkLuaInline "wezterm.font('BerkeleyMono Nerd Font Mono')";
        font_size = 11;
        window_decorations = "NONE";
        window_background_opacity = 0.8;
        window_padding = {
          left = 10;
          right = 10;
          top = 16;
          bottom = 16;
        };
        enable_tab_bar = false;
      };
    };
  };
}
