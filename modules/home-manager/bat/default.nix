{
  lib,
  config,
  pkgs,
  ...
}:
{

  options.custom = {
    bat.enable = lib.mkEnableOption "enable bat - color cat alternative";
  };

  config = lib.mkIf config.custom.bat.enable {
    home.packages = with pkgs; [
      bat-extras.core
    ];
    programs.bat = {
      enable = true;
      config = {
        theme = "ansi";
        style = "numbers,changes";
      };
    };
  };
}
