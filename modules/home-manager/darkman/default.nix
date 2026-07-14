{
  lib,
  config,
  pkgs,
  ...
}:
let
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  ensureHis = ''
    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
      export HYPRLAND_INSTANCE_SIGNATURE="$(${pkgs.coreutils}/bin/ls -t "$XDG_RUNTIME_DIR/hypr" | ${pkgs.coreutils}/bin/head -n1)"
    fi
  '';

  hyprsunsetEnabled = config.custom.hyprsunset.enable or false;
in
{

  options.custom = {
    darkman.enable = lib.mkEnableOption "enable darkman - auto dark/light switch";
  };

  config = lib.mkIf config.custom.darkman.enable {

    home.packages = with pkgs; [
      glib
      gsettings-desktop-schemas
    ];

    services.darkman = {
      enable = true;
      settings = {
        lat = -22.48;
        lng = -47.08;
        usegeoclue = false;
      };
      # gsettings color-scheme is owned by theme-switch; darkman only drives
      # hyprsunset for time-of-day temperature.
      darkModeScripts = lib.optionalAttrs hyprsunsetEnabled {
        hyprsunset = ''
          ${ensureHis}
          ${hyprctl} hyprsunset temperature 4000
          ${hyprctl} hyprsunset gamma 85
        '';
      };
      lightModeScripts = lib.optionalAttrs hyprsunsetEnabled {
        hyprsunset = ''
          ${ensureHis}
          ${hyprctl} hyprsunset identity
          ${hyprctl} hyprsunset gamma 100
        '';
      };
    };
  };
}