
{ lib, config, pkgs, ... }:
{

  options.custom = {
    tmux.enable = lib.mkEnableOption "enable tmux - terminal multiplexer";
  };

  config = lib.mkIf config.custom.tmux.enable {
	  home.packages = with pkgs; [
	    tmux
	  ];

  	xdg.configFile."tmux/tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/modules/home-manager/tmux/tmux.conf";
  };
}
