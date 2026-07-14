{
  lib,
  config,
  pkgs,
  ...
}:
{

  options.custom = {
    eza.enable = lib.mkEnableOption "enable eza - a modern replacement for ls";
  };

  config = lib.mkIf config.custom.eza.enable {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      colors = "auto";
      icons = "auto";
    };
  };
}
