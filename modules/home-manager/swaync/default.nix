{ lib, config, ... }:
{
  options.custom = {
    swaync.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable swaync - notification";
    };
  };

  config = lib.mkIf config.custom.swaync.enable {
    services.swaync = {
      enable = true;
      settings = {
        positionX = "center";
        positionY = "top";
        cssPriority = "user";

        control-center-width = 360;
        control-center-height = 760;
        control-center-margin-top = 2;
        control-center-margin-bottom = 2;
        control-center-margin-right = 1;
        control-center-margin-left = 0;

        notification-window-width = 380;
        notification-icon-size = 40;
        notification-body-image-height = 120;
        notification-body-image-width = 160;

        timeout = 6;
        timeout-low = 4;
        timeout-critical = 8;

        fit-to-screen = false;
        keyboard-shortcuts = true;
        image-visibility = "when-available";
        transition-time = 250;
        hide-on-clear = true;
        hide-on-action = false;
        script-fail-notify = true;
        notification-visibility = {
          example-name = {
            state = "muted";
            urgency = "Low";
            app-name = "Spotify";
          };
        };
        widgets = [
          "mpris"
          "title"
          "dnd"
          "notifications"
        ];

        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = " 󰎟   Clear";
          };
          dnd = {
            text = "Do not disturb";
          };
          label = {
            max-lines = 1;
            text = " ";
          };
          mpris = {
            image-size = 96;
            image-radius = 12;
          };
          volume = {
            label = "󰕾";
            show-per-app = true;
          };
          buttons-grid = {
            actions = [
              {
                label = " ";
                command = "amixer set Master toggle";
              }
              {
                label = "";
                command = "amixer set Capture toggle";
              }
              {
                label = " ";
                command = "nm-connection-editor";
              }
              {
                label = "󰂯";
                command = "blueman-manager";
              }
              {
                label = "󰏘";
                command = "nwg-look";
              }

            ];
          };
        };
      };
    };

    xdg.configFile."swaync/style.css".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/colorschemes/.active/swaync/style.css";
    xdg.configFile."swaync/colors.css".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/colorschemes/.active/swaync/colors.css";
  };
}
