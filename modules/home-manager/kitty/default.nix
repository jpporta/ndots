{
  config,
  lib,
  pkgs,
  ...
}:

let
  tikiVersion = "0.6.1";
  tiki = pkgs.buildGoModule {
    pname = "tiki";
    version = tikiVersion;

    src = pkgs.fetchFromGitHub {
      owner = "boolean-maybe";
      repo = "tiki";
      tag = "v${tikiVersion}";
      hash = "sha256-uxdgB13rHwWperjuFMznUyP/70r4h2drVxSGSGFzYyM=";
    };

    vendorHash = "sha256-vV8iBVdurcMUC7kwkAlnSt6cI4gNFRg721rkSuuOC2g=";
    nativeCheckInputs = [ pkgs.git ];
    ldflags = [
      "-s"
      "-w"
      "-X github.com/boolean-maybe/tiki/config.Version=${tikiVersion}"
    ];
  };
in
{
  options.custom.kitty.enable = lib.mkEnableOption "enable Kitty terminal emulator";

  config = lib.mkIf config.custom.kitty.enable {
    home.packages = [
      tiki
      pkgs.mermaid-cli
    ];

    programs.kitty = {
      enable = true;
      settings = {
        # Gruvbox Dark
        background = "#282828";
        foreground = "#ebdbb2";
        cursor = "#ebdbb2";
        cursor_text_color = "#282828";
        selection_background = "#504945";
        selection_foreground = "#ebdbb2";
        color0 = "#282828";
        color1 = "#cc241d";
        color2 = "#98971a";
        color3 = "#d79921";
        color4 = "#458588";
        color5 = "#b16286";
        color6 = "#689d6a";
        color7 = "#a89984";
        color8 = "#928374";
        color9 = "#fb4934";
        color10 = "#b8bb26";
        color11 = "#fabd2f";
        color12 = "#83a598";
        color13 = "#d3869b";
        color14 = "#8ec07c";
        color15 = "#ebdbb2";

        font_family = "BerkeleyMono Nerd Font Mono";
        font_size = 11;
        disable_ligatures = "always";
        background_opacity = 0.8;
        hide_window_decorations = true;
        window_padding_width = "10 10 16 16";
        tab_bar_style = "hidden";
      };
    };
  };
}
