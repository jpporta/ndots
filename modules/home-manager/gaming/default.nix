{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.custom.gaming_hm = {
    enable = lib.mkEnableOption "gaming home manager configuration";
  };

  config = lib.mkIf config.custom.gaming_hm.enable {
    home.packages = with pkgs; [
      bottles     # THE tool for repacked/standalone Windows games (wraps Wine/Proton)
      lutris      # Excellent game library manager
    ];
  };
}
