{
  config,
  lib,
  pkgs,
  ...
}:
let
  icons = "${config.programs.wlogout.package}/share/wlogout/icons";
in
{
  options.custom = {
    wlogout.enable = lib.mkEnableOption "enable wlogout - logout menu";
  };

  config = lib.mkIf config.custom.wlogout.enable {
    # Style comes from ~/.config/themes/.active/wlogout/style.css via symlink.
    # No inline `programs.wlogout.style` so it doesn't fight the symlink.

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
    };

    # Replace the auto-generated style.css from programs.wlogout.style with
    # a symlink into the curated themes tree.
    xdg.configFile."wlogout/style.css".source = lib.mkForce (
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/themes/.active/wlogout/style.css"
    );
  };
}