{ lib, config, ... }:
{
  options.custom = {
    swaync.enable = lib.mkEnableOption "enable swaync - color cat alternative";
  };

  config = lib.mkIf config.custom.swaync.enable {
    # Use theme seed directly instead of .active symlink
    # The .active symlink is created during activation, but we need
    # the file to exist during the build phase
    xdg.configFile."swaync/style.css".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ndots/modules/home-manager/theme/seeds/gruvbox-dark/swaync/colors.css";

    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        cssPriority = "user";

        control-center-width = 380;
        control-center-height = 860;
        control-center-margin-top = 2;
        control-center-margin-bottom = 2;
        control-center-margin-right = 1;
        control-center-margin-left = 0;

        notification-window-width = 400;
        notification-icon-size = 48;
        notification-body-image-height = 160;
        notification-body-image-width = 200;

        timeout = 4;
        timeout-low = 2;
        timeout-critical = 6;

        fit-to-screen = false;
        keyboard-shortcuts = true;
        image-visibility = "when-available";
        transition-time = 200;
        hide-on-clear = true;
        hide-on-action = false;
        script-fail-notify = true;
        scripts = {
          example-script = {
            exec = "echo 'Do something...'";
            urgency = "Normal";
          };
        };
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
                label = " ";
                command = "amixer set Master toggle";
              }
              {
                label = "";
                command = "amixer set Capture toggle";
              }
              {
                label = " ";
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
  };
}