{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.tailscale;
in
{
  options.custom.tailscale = {
    enable = lib.mkEnableOption "Tailscale private mesh VPN";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    # Let services bound to this host, like OpenSSH and mosh, be reachable from
    # trusted devices in the tailnet without exposing them on public interfaces.
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = "loose";
    };

    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}
