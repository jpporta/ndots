
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.custom = {
    obs.enable = lib.mkEnableOption "enable obs - capture, record and stream software";
  };

  config = lib.mkIf config.custom.obs.enable {
  };

}
