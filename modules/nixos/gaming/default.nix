{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.custom.gaming = {
    enable = lib.mkEnableOption "comprehensive gaming setup";
  };

  config = lib.mkIf config.custom.gaming.enable {
    # System-wide utilities
    programs.gamemode.enable = true;

    # Hardware/Graphics Optimization
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Critical for Windows games and Steam
    };

    # System-level tools that benefit from being in the environment path
    environment.systemPackages = with pkgs; [
      gamescope # Micro-compositor for Wayland/Hyprland gaming
      mangohud # Performance overlay
      goverlay # GUI to configure MangoHud
      bottles # repacked/standalone Windows games (wraps Wine/Proton)
      lutris # game library manager
    ];
  };
}
