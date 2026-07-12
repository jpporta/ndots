{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{

  imports = [
    ./accounts.nix
  ];

  options.custom = {
    jpporta-calendars.enable = lib.mkEnableOption "enable personal jpporta calendars";
  };

  config = lib.mkIf config.custom.jpporta-calendars.enable {
    programs = {
      vdirsyncer.enable = true;

      khal = {
        enable = true;
        locale = {
          timeformat = "%H:%M";
          dateformat = "%Y-%m-%d";
          longdateformat = "%Y-%m-%d";
          datetimeformat = "%Y-%m-%d %H:%M";
          longdatetimeformat = "%Y-%m-%d %H:%M";
        };
      };
    };

    services.vdirsyncer = {
      enable = true;
      frequency = "*:0/15"; # every 15 minutes; systemd OnCalendar format
    };

  };
}
