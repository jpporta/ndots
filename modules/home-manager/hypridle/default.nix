{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.custom = {
    hypridle.enable = lib.mkEnableOption "enable hypridle - screen lock";
  };

  config = lib.mkIf config.custom.hypridle.enable {
    services.hypridle = {
      enable = true;
    };
  };
}
