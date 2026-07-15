{ lib, config, pkgs, ... }:
let
  # Get the theme from config or use a default
  currentTheme = config.custom.theme.current or "gruvbox-dark";
  themeSeedsDir = "${config.home.homeDirectory}/ndots/modules/home-manager/theme/seeds";
in
{

  options.custom = {
    nvim.enable = lib.mkEnableOption "enable nvim - symlink config files";
  };

  config = lib.mkIf config.custom.nvim.enable {
	  home.packages = with pkgs; [
	    neovim
      fzf
	  ];

	  xdg.configFile = {
      "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ndots/modules/home-manager/nvim/nvim";
    };

    # Create theme color scheme symlinks using activation script
    # This avoids the path validation issues with xdg.configFile/home.file
    # when dealing with paths starting with .config
    home.activation = {
      linkThemeColors = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        target_dir="$HOME/.config/nvim/lua/colors"
        mkdir -p "$target_dir"
        ln -sf "${themeSeedsDir}/${currentTheme}/nvim/colors.lua" "$target_dir/${currentTheme}.lua"
      '';
    };
  };
}
