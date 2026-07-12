{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  accounts = {
    calendar = {
      basePath = "${config.home.homeDirectory}/.calendars";
      accounts = {
        inbox = {
          remote = {
            type = "caldav";
            url = "https://cal.joaoporta.com/jpporta/3a35411d-3b32-854e-9a57-1cca5510fd8e/";
            userName = "jpporta";
            passwordCommand = [
              "pass"
              "show"
              "personal/caldav"
            ];
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
            metadata = [
              "color"
              "displayname"
            ];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "light blue";
          };
        };

        avodah = {
          remote = {
            type = "caldav";
            url = "https://cal.joaoporta.com/jpporta/f3901be0-8dca-7856-d1cb-fe7869e92c1e/";
            userName = "jpporta";
            passwordCommand = [
              "pass"
              "show"
              "personal/caldav"
            ];
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
            metadata = [
              "color"
              "displayname"
            ];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "light red";
          };
        };

        casa = {
          remote = {
            type = "caldav";
            url = "https://cal.joaoporta.com/jpporta/4f26caba-3134-4253-cdb6-16d34df2a109/";
            userName = "jpporta";
            passwordCommand = [
              "pass"
              "show"
              "personal/caldav"
            ];
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
            metadata = [
              "color"
              "displayname"
            ];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "dark red";
          };
        };

        exercicio = {
          remote = {
            type = "caldav";
            url = "https://cal.joaoporta.com/jpporta/773de611-4f21-053f-e916-f48f1b3f0e24/";
            userName = "jpporta";
            passwordCommand = [
              "pass"
              "show"
              "personal/caldav"
            ];
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
            metadata = [
              "color"
              "displayname"
            ];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "dark green";
          };
        };

        familia = {
          remote = {
            type = "caldav";
            url = "https://cal.joaoporta.com/jpporta/4fb446ab-33a1-1a91-c009-5b69316c8cea/";
            userName = "jpporta";
            passwordCommand = [
              "pass"
              "show"
              "personal/caldav"
            ];
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
            metadata = [
              "color"
              "displayname"
            ];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "dark blue";
          };
        };

        saude = {
          remote = {
            type = "caldav";
            url = "https://cal.joaoporta.com/jpporta/4b455515-de59-2bdb-9e51-aee5a1a2d960/";
            userName = "jpporta";
            passwordCommand = [
              "pass"
              "show"
              "personal/caldav"
            ];
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
            metadata = [
              "color"
              "displayname"
            ];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "light magenta";
          };
        };

        teleo = {
          remote = {
            type = "caldav";
            url = "https://cal.joaoporta.com/jpporta/dd52bfd0-c8c4-2d7b-6469-25244f69fe3a/";
            userName = "jpporta";
            passwordCommand = [
              "pass"
              "show"
              "personal/caldav"
            ];
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
            metadata = [
              "color"
              "displayname"
            ];
          };

          khal = {
            enable = true;
            type = "calendar";
            color = "yellow";
          };
        };
      };
    };
  };

}
