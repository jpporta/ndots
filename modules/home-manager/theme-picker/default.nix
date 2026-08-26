{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.theme-picker;
in
{
  options.custom.theme-picker.enable = lib.mkEnableOption "Quickshell theme picker (grid overlay) for the theme-switcher";

  config = lib.mkIf cfg.enable {
    # Writes the one-shot Quickshell shell. Launched by the Hyprland keybind
    # (SUPER + ALT + T) via `qs -p ~/.config/quickshell/theme-picker`. HM owns
    # the static QML; the picker is stateless at runtime and quits itself on
    # ESC / selection.
    # NOTE: this must use `-p <path>`, NOT `-c theme-picker`. `~/.config/quickshell/shell.qml`
    # exists, so Quickshell registers it as the default config and ignores all
    # subdirectories (which shadows the theme-picker dir under `-c`).
    # `quickshell` itself is installed by modules/home-manager/arch-packages.
    xdg.configFile."quickshell/theme-picker/shell.qml".source = ./shell.qml;
  };
}
