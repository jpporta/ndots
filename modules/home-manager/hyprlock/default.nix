{
  config,
  lib,
  pkgs,
  ...
}:
let
  font = "BerkeleyMono Nerd Font Mono";
  monitor = "DP-1";
  bg = "rgba(1d202144)"; # hard dark background
  bg1 = "rgb(3c3836)"; # input fill
  fg = "rgb(ebdbb2)"; # main text
  muted = "rgb(928374)"; # dim text
  orange = "rgb(fe8019)"; # accent — echoes your rofi orange
  yellow = "rgb(fabd2f)"; # caps-lock
  green = "rgb(b8bb26)"; # correct password
  red = "rgb(fb4934)"; # wrong password
in
{
  options.custom = {
    hyprlock.enable = lib.mkEnableOption "enable hyprlock - lock splash screen";
  };

  config = lib.mkIf config.custom.hyprlock.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
          # grace = 2   # seconds to dismiss with mouse before a password is required
        };

        # ---------- Background ----------
        background = {
          monitor = "${monitor}";
          color = "${bg}";
          # Prefer a wallpaper? drop `color` above and use:
          # path        = ~/nixos-config/wallpapers/lock.png
          # blur_passes = 3
          # blur_size   = 6
        };

        # ---------- Clock ----------
        label = [
          {
            monitor = "${monitor}";
            text = "$TIME";
            color = "${fg}";
            font_size = 96;
            font_family = "${font}";
            position = "0, 120";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "${monitor}";
            text = "cmd[update:60000] date +\"%A, %d %B\"";
            color = "${muted}";
            font_size = 18;
            font_family = "${font}";
            position = "0, 48";
            halign = "center";
            valign = "center";
          }
          {
            monitor = "${monitor}";
            text = "Hey, $USER";
            color = "${orange}";
            font_size = 16;
            font_family = "${font}";
            position = "0, -20";
            halign = "center";
            valign = "center";
          }
        ];
        # ---------- Input field ----------
        input-field = {
          monitor = "${monitor}";
          size = "300, 54";
          rounding = 14;
          outline_thickness = 2;
          dots_size = 0.25;
          dots_spacing = 0.3;
          dots_center = true;

          outer_color = "${orange}";
          inner_color = "${bg1}";
          font_color = "${fg}";
          check_color = "${green}";
          fail_color = "${red}";
          capslock_color = "${yellow}";

          fade_on_empty = false;
          placeholder_text = "<span foreground=\"##928374\"><i>󰌾  Enter password</i></span>";
          fail_text = "<span foreground=\"##fb4934\"><i>$FAIL ($ATTEMPTS)</i></span>";

          position = "0, -95";
          halign = "center";
          valign = "center";
        };
      };
    };
  };
}
