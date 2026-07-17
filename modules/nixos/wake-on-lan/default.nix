{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.wake-on-lan;

  iface = "enp14s0";

  mac = "d8:43:ae:5a:ae:12";

  wake-jpporta-nixos = pkgs.writeShellScriptBin "wake-jpporta-nixos" ''
    exec ${pkgs.wakeonlan}/bin/wakeonlan -i "''${1:-255.255.255.255}" ${mac}
  '';
in
{
  options.custom.wake-on-lan = {
    enable = lib.mkEnableOption "Wake-on-LAN on the wired NIC (magic-packet mode)";
  };

  config = lib.mkIf cfg.enable {
    # Keep `wol g` applied on the NIC after the link is up (boot path).
    systemd.services."wol-${iface}" = {
      description = "Enable Wake-on-LAN (magic packet) on ${iface}";
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "NetworkManager.service"
      ];
      after = [
        "network-online.target"
        "NetworkManager.service"
        "NetworkManager-wait-online.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.ethtool}/bin/ethtool -s ${iface} wol g";
      };
    };

    # Re-apply `wol g` after resume from suspend / hibernate so NetworkManager
    # cannot silently drop the WOL flag on link renegotiation.
    systemd.services."wol-${iface}-resume" = {
      description = "Re-apply Wake-on-LAN (magic packet) on ${iface} after resume";
      wantedBy = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
      ];
      after = [
        "systemd-suspend.service"
        "systemd-hibernate.service"
        "systemd-hybrid-sleep.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.ethtool}/bin/ethtool -s ${iface} wol g";
      };
    };

    environment.systemPackages = [
      pkgs.ethtool
      pkgs.wakeonlan
      wake-jpporta-nixos
    ];
  };
}
