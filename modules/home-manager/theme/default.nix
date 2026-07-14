{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.theme;

  themeSwitch = pkgs.writeShellScriptBin "theme-switch" (lib.readFile ./theme-switch.sh);
  themePicker = pkgs.writeShellScriptBin "theme-picker" (lib.readFile ./theme-picker.sh);

  activeLink = "${config.home.homeDirectory}/.config/themes/.active";
  themesDir = "${config.home.homeDirectory}/.config/themes";
  seed = name: "${./seeds}/${name}";
in
{
  options.custom.theme = {
    enable = lib.mkEnableOption "theme switching via ~/.config/themes/";
    current = lib.mkOption {
      type = lib.types.str;
      default = "gruvbox-dark";
      description = "theme applied on first install via ~/.config/themes/.active";
    };
    available = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "gruvbox-dark" ];
      description = "themes to seed and expose as nvim colorschemes on this host";
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ themeSwitch themePicker ];

    home.activation = {
      ensureThemesDir = {
        after = [ "writeBoundary" ];
        before = [ "linkGeneration" ];
        data = ''
          mkdir -p ${themesDir}
        '';
      };

      # Seed built-in themes on first install. Skips themes that already
      # exist on disk so the user's edits survive re-installs.
      #
      # ponytail: themes without a matching seed in ./seeds/ fall through
      # silently; user must `mkdir ~/.config/themes/<name>/` and drop files.
      seedThemes = {
        after = [ "ensureThemesDir" ];
        before = [ "ensureActiveLink" ];
        data = ''
          for theme in ${lib.concatStringsSep " " cfg.available}; do
            target=${themesDir}/$theme
            [ -e "$target" ] && continue
            src=${./seeds}/$theme
            if [ -d "$src" ]; then
              cp -r --no-preserve=mode,ownership "$src" "$target"
              chmod -R u+rwX "$target"
            fi
          done
        '';
      };

      ensureActiveLink = {
        after = [ "seedThemes" ];
        before = [ "linkGeneration" ];
        data = ''
          target=${themesDir}/${cfg.current}
          link=${activeLink}
          if [ ! -e "$link" ] && [ ! -L "$link" ]; then
            ln -s ${cfg.current} "$link"
          fi
        '';
      };
    };
  };
}