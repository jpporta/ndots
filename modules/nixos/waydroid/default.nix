{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.waydroid;
in
{
  options.custom.waydroid = {
    enable = lib.mkEnableOption "Waydroid (container-based Android runtime)";
  };

  config = lib.mkIf cfg.enable {
    # waydroid-nftables: newer-kernel variant per NixOS Wiki (nftables backend)
    virtualisation.waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };
  };
}
