{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.custom = {
    steam.enable = lib.mkEnableOption "enable steam - game library and store";
  };

  config = lib.mkIf config.custom.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    programs.gamemode.enable = true;
  };

}
