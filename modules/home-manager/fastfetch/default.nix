{ lib, config, ... }:
{
  options.custom = {
    fastfetch.enable = lib.mkEnableOption "enable fastfetch - system prompt decoration";
  };
  config = lib.mkIf config.custom.fastfetch.enable {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "nixos_small";
          padding = {
            top = 4;
            left = 0;
            right = 2;
          };
          position = "right";
        };
        display = {
          stat = false;
          pipe = false;
          showErrors = false;
          disableLinewrap = true;
          hideCursor = false;
          separator = ": ";
          color = {
            keys = "";
            title = "";
            output = "";
            separator = "";
          };
          brightColor = true;
          duration = {
            abbreviation = false;
            spaceBeforeUnit = "default";
          };
          size = {
            maxPrefix = "YB";
            binaryPrefix = "iec";
            ndigits = 2;
            spaceBeforeUnit = "default";
          };
          temp = {
            unit = "D";
            ndigits = 1;
            color = {
              green = 32;
              yellow = 93;
              red = 91;
            };
            spaceBeforeUnit = "default";
          };
          percent = {
            type = [
              "num"
              "num-color"
            ];
            ndigits = 0;
            color = {
              green = 32;
              yellow = 93;
              red = 91;
            };
            spaceBeforeUnit = "default";
            width = 0;
          };
          bar = {
            char = {
              elapsed = "■";
              total = "-";
            };
            border = {
              left = "[ ";
              right = " ]";
              leftElapsed = "";
              rightElapsed = "";
            };
            color = {
              elapsed = "auto";
              total = 97;
              border = 97;
            };
            width = 10;
          };
          fraction = {
            ndigits = 2;
          };
          noBuffer = false;
          key = {
            width = 0;
            type = "string";
            paddingLeft = 0;
          };
          freq = {
            ndigits = 2;
            spaceBeforeUnit = "default";
          };
          constants = [ ];
        };
        general = {
          thread = true;
          processingTimeout = 5000;
          detectVersion = true;
          playerName = "";
          dsForceDrm = false;
        };
        modules = [
          {
            type = "title";
            key = "";
            keyIcon = "";
            fqdn = false;
            color = {
              user = "";
              at = "";
              host = "";
            };
          }
          {
            type = "separator";
            string = "-";
            outputColor = "";
            times = 0;
          }
          {
            type = "os";
            keyIcon = "";
          }
          {
            type = "uptime";
            keyIcon = "";
          }
          {
            type = "shell";
            keyIcon = "";
          }
          {
            type = "display";
            keyIcon = "󰍹";
            compactType = "none";
            preciseRefreshRate = false;
            order = null;
          }
          {
            type = "wm";
            keyIcon = "";
            detectPlugin = false;
          }
          {
            type = "terminal";
            keyIcon = "";
          }
          {
            type = "terminalfont";
            keyIcon = "";
          }
          {
            type = "cpu";
            keyIcon = "";
            temp = false;
            showPeCoreCount = false;
          }
          {
            type = "gpu";
            keyIcon = "󰾲";
            driverSpecific = false;
            detectionMethod = "pci";
            temp = true;
            hideType = "none";
            percent = {
              green = 50;
              yellow = 80;
              type = 0;
            };
          }
          {
            type = "memory";
            keyIcon = "";
            percent = {
              green = 50;
              yellow = 80;
              type = 0;
            };
          }
          {
            type = "disk";
            keyIcon = "";
            showRegular = true;
            showExternal = true;
            showHidden = false;
            showSubvolumes = false;
            showReadOnly = true;
            showUnknown = false;
            folders = "";
            hideFolders = [
              "/efi"
              "/boot"
              "/boot/*"
            ];
            hideFS = "";
            useAvailable = false;
            percent = {
              green = 50;
              yellow = 80;
              type = 0;
            };
          }
          { }
          {
            type = "colors";
            key = "";
            keyIcon = "";
            symbol = "block";
            paddingLeft = 0;
            block = {
              width = 3;
              range = "[0, 15]";
            };
          }
        ];
      };
    };
  };
}
