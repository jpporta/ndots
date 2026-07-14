{ lib, config, pkgs, ... }:
let
  themes = config.custom.theme.available or [ ];
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
    }
    // (lib.listToAttrs (map (theme: {
      name = "nvim/lua/colors/${theme}.lua";
      value.source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/themes/${theme}/nvim/colors.lua";
    }) themes));
  };
}