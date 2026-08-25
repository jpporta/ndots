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
        # Color keys are NOT inline here anymore. The runtime theme fragment
        # (written by tooling/theme-switcher) is included LAST so its values
        # override any baseline. Home Manager still owns fonts/layout/habits.
        include = "${config.home.homeDirectory}/.config/kitty/theme-current.conf";

        font_family = "BerkeleyMono Nerd Font Mono";
        font_size = 11;
        disable_ligatures = "always";
        background_opacity = 0.8;
        hide_window_decorations = true;
        window_padding_width = "10 10 16 16";
        confirm_os_window_close = 0;
        close_on_child_death = true;
        tab_bar_style = "hidden";
      };
    };
  };
}
