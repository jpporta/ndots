{ lib, config, pkgs, ... }:
{

  options.custom = {
    openspec.enable = lib.mkEnableOption "enable openspec";
  };

  config = lib.mkIf config.custom.openspec.enable {
    home.packages = with pkgs; [
      openspec
    ];
  };
}
