{ lib, config, ... }:
{

  options.custom = {
    bat.enable = lib.mkEnableOption "enable bat - color cat alternative";
  };

  config = lib.mkIf config.custom.bat.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = "ansi";
        style = "numbers,changes";
      };
    };
  };
}
