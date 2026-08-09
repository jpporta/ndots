## Why

The user wants to power on `jpporta-nixos` remotely via Wake-on-LAN (WOL). This is useful when the machine is shut down but the user wants to access it from another device (e.g., over Tailscale + SSH) without manually pressing the power button. Currently the machine has no WOL configuration: nothing keeps the NIC in a low-power listening state, and no tooling exists on the host to inspect or send WOL packets.

## What Changes

- Enable Wake-on-LAN on the wired Ethernet interface (`enp14s0`) so the NIC keeps listening for magic packets while the system is powered off.
- Add `ethtool` so the user can inspect the current WOL settings and supported modes on the NIC.
- Add `wol` (the `iputils`-style `wakeonlan` command) so WOL packets can be sent from this host to other machines, and from other machines back to this one (using its MAC `d8:43:ae:5a:ae:12`).
- Add a small helper script (`wake-jpporta-nixos`) that sends a WOL magic packet to this machine's MAC address, so it can be invoked by name.
- Document the manual BIOS-level steps that are required for WOL to work (these cannot be set from NixOS).

## Capabilities

### New Capabilities
- `wake-on-lan`: Configures Wake-on-LAN on the host's wired NIC and provides tooling/scripts to inspect and send magic packets.

### Modified Capabilities
- None

## Impact

- **Code:** A new optional module `modules/nixos/wake-on-lan/` will be added and imported into `hosts/jpporta-nixos/configuration.nix`. The module will expose a `custom.wake-on-lan.enable` toggle consistent with the project's existing module pattern (see `modules/nixos/tailscale/`).
- **System:** A systemd unit will be installed that runs `ethtool -s enp14s0 wol g` on boot and on resume, persisting the WOL setting across reboots and sleep states.
- **User:** Two new commands will be on `$PATH`: `ethtool` and `wakeonlan`, plus a convenience wrapper `wake-jpporta-nixos`.
- **Hardware:** Requires BIOS-level "Wake on LAN" to be enabled on the motherboard and a stable AC power source. The user must configure these out-of-band.
- **Network:** To wake the machine from outside the LAN, the router must forward UDP port 9 (or 7) to the broadcast address. This is a router-side concern, not configurable from NixOS.