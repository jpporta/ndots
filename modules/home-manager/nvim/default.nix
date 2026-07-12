{ lib, config, pkgs, ... }:
{

  options.custom = {
    nvim.enable = lib.mkEnableOption "enable nvim - symlink config files";
  };

  config = lib.mkIf config.custom.nvim.enable {
	  home.packages = with pkgs; [
	    neovim
      fzf
	  ];

  	xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/home-manager/nvim/nvim";
  };
}
