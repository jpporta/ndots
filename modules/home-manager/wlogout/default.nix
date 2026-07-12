{
  config,
  lib,
  pkgs,
  ...
}:
let
  font = "BerkeleyMono Nerd Font Mono";

  bg1 = "#3c3836"; # button fill
  bg2 = "#504945"; # button border / hover fill
  fg = "#ebdbb2"; # icon + text
  orange = "#fe8019"; # accent — matches hyprlock/rofi

  icons = "${config.programs.wlogout.package}/share/wlogout/icons";
in
{
  options.custom = {
    wlogout.enable = lib.mkEnableOption "enable wlogout - logout menu";
  };

  config = lib.mkIf config.custom.wlogout.enable {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "loginctl lock-session";
          text = "Lock [l]";
          keybind = "l";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Logout [e]";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'";
          text = "Shutdown [s]";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend [u]";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "hyprshutdown -t 'Restarting...' --post-cmd 'reboot'";
          text = "Reboot [r]";
          keybind = "r";
        }
      ];
      style = ''
        * {
          font-family: "${font}";
          background-image: none;
          box-shadow: none;
        }

        window {
          background-color: rgba(29, 32, 33, 0.6);   /* gruvbox bg0_hard @ 60% */
        }

        button {
          color: ${fg};
          background-color: ${bg1};
          border: 2px solid ${bg2};
          border-radius: 16px;
          margin: 1rem;
          font-size: 1.1rem;

          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;

          transition: all 0.2s ease-in-out;
        }

        button:focus,
        button:active,
        button:hover {
          color: ${orange};
          background-color: ${bg2};
          border-color: ${orange};
          background-size: 30%;
          box-shadow: inset 0 0 0 2px ${orange};   /* clean inner ring, no bleed */
          outline: none;
        }

        #lock     { background-image: url("${icons}/lock.png"); }
        #logout   { background-image: url("${icons}/logout.png"); }
        #shutdown { background-image: url("${icons}/shutdown.png"); }
        #suspend  { background-image: url("${icons}/suspend.png"); }
        #reboot   { background-image: url("${icons}/reboot.png"); }
      '';
    };
  };
}
