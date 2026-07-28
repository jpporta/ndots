{
  lib,
  config,
  pkgs,
  ...
}:
{

  options.custom = {
    bitwarden.enable = lib.mkEnableOption "enable bitwarden - CLI password manager";
  };

  config = lib.mkIf config.custom.bitwarden.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = "me@joaoporta.com";
        lock_timeout = 7200;
        pinentry = pkgs.pinentry-gnome3;
        base_url = "https://pass.joaoporta.com";
      };
    };
  };
}
