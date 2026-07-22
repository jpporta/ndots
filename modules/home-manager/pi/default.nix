{ lib, config, pkgs, ... }:
{

  options.custom = {
    pi.enable = lib.mkEnableOption "enable pi - pi.dev coding agent";
  };

  config = lib.mkIf config.custom.pi.enable {
	  home.packages = with pkgs; [
      pi-coding-agent
      worktrunk
      sesh
      sl
      signal-cli
	  ];
  };
}
