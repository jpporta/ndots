## Context

`jpporta-nixos` is a desktop machine with a wired Ethernet interface (`enp14s0`, MAC `d8:43:ae:5a:ae:12`) managed by NetworkManager. The user wants to power the machine on remotely via Wake-on-LAN so it can be reached over Tailscale + SSH without manual intervention.

WOL requires three layers of configuration:

1. **Firmware (BIOS/UEFI):** "Wake on LAN" must be enabled on the NIC, and the machine must remain in a low-power state after shutdown (most desktop boards default to this; some servers default to "power on after AC loss" which would defeat the purpose).
2. **Kernel/driver (NixOS):** The NIC driver must be told to keep listening for magic packets while the system is off. For most Intel NICs this means `ethtool -s <iface> wol g` (magic packet mode).
3. **Network:** Magic packets are sent to the layer-2 broadcast address (`ff:ff:ff:ff:ff:ff`) and rely on the NIC matching its own MAC. The host cannot route or filter them above the NIC, so no userspace daemon is required to *receive* a packet. A userspace tool (`wakeonlan`) is required to *send* one.

NixOS already provides `networking.wakeOnLan.enable`, but that option is hard-coded to `eth0` and is incompatible with predictable interface names (`enp14s0`). The NixOS-supported path for a named, predictable interface is a custom systemd unit that invokes `ethtool` against the specific interface. This is the approach used here because it survives reboots, resumes, and NetworkManager reconnects.

## Goals / Non-Goals

**Goals:**
- Persist `wol g` on `enp14s0` across reboots and resume-from-suspend.
- Provide `ethtool` and `wakeonlan` on `$PATH` so the user can inspect and send magic packets.
- Provide a convenience script `wake-jpporta-nixos` that sends a WOL packet to this machine's MAC.
- Wrap the configuration in a reusable module (`custom.wake-on-lan.enable`) consistent with existing patterns.
- Document the out-of-band BIOS / router configuration steps.

**Non-Goals:**
- Setting BIOS options (firmware is out of reach from NixOS).
- Configuring router port-forwarding for WOL-over-internet (router is out of scope).
- Listening for / relaying WOL packets on this host — that is the NIC's job once `wol g` is set.
- Changing the network interface naming scheme or replacing NetworkManager.

## Decisions

1. **Per-interface systemd unit over `networking.wakeOnLan.enable`.**
   - The top-level `networking.wakeOnLan.enable` is hard-coded to `eth0`, which doesn't match the predictable interface name `enp14s0` used here.
   - Alternative considered: `networking.interfaces.enp14s0.wakeOnLan.enable = true`. This option does exist in modern NixOS, but on this machine it interacts awkwardly with NetworkManager (which re-loads NIC settings on reconnect) and the underlying implementation still relies on an ethtool invocation that may be racy with NetworkManager bringing the link up.
   - **Decision:** Use a dedicated systemd `oneshot` service with a `network-online.target` dependency. This makes the WOL setting idempotent, runs after NetworkManager is up, and can also be triggered on resume-from-suspend by adding it to the `suspend.target` resume path. Concretely we ship a unit `wol-enp14s0.service` that runs `ethtool -s enp14s0 wol g`.

2. **Package set: `ethtool` + `iputils` (which provides `wakeonlan`).**
   - `pkgs.ethtool` is the standard tool for inspecting and setting NIC driver options, including WOL modes.
   - `pkgs.iputils` provides `wakeonlan`, the simplest CLI for sending a magic packet to a target MAC.
   - Alternative considered: `pkgs.wol` (the separate, older `wol` program). `wakeonlan` from iputils is more widely used, has a simpler interface (`wakeonlan <mac>`), and is what most WOL guides assume.

3. **Convenience wrapper script `wake-jpporta-nixos`.**
   - Hard-codes the MAC of this machine's wired NIC (`d8:43:ae:5a:ae:12`) into a small `writeShellScriptBin`-packaged script.
   - Rationale: avoids having to remember or look up the MAC every time. The wrapper accepts an optional broadcast IP argument so the user can target `192.168.0.255` from off-LAN once the router is configured to forward UDP 9 to that broadcast.

4. **Module pattern: `modules/nixos/wake-on-lan/default.nix` with `custom.wake-on-lan.enable`.**
   - Mirrors the existing pattern used by `modules/nixos/tailscale/` and `modules/nixos/hyprland/`.
   - Defaults to disabled. Host (`jpporta-nixos`) opts in via `custom.wake-on-lan.enable = true`.

## Risks / Trade-offs

- **[Risk]** `ethtool -s ... wol g` only takes effect while the kernel NIC driver is loaded. Some BIOS/firmware combinations fully power down the NIC on shutdown, making WOL impossible regardless of the OS setting.
  - **Mitigation:** Document this clearly in the change notes. The user must verify with `ethtool enp14s0` after a `systemctl poweroff` that `Supports Wake-on: pumbg` and `Wake-on: g` are still present.

- **[Risk]** Some desktop boards default to "Power on after AC loss = Power on" which would make the machine boot after any power outage regardless of WOL — undermining the use case.
  - **Mitigation:** Document the BIOS setting ("After Power Loss" → "Power Off" or "Stay Off") in the change notes.

- **[Risk]** NetworkManager may re-apply link settings on resume, overwriting `wol g`.
  - **Mitigation:** The systemd unit is wired to run on resume via a `path`/`service` pair (or a manual `systemctl restart wol-enp14s0.service` hook). For the initial implementation we trigger it on boot and rely on the user to re-run if it ever drifts; the follow-up task in `tasks.md` adds the resume hook.

- **[Trade-off]** Hard-coding the MAC and interface name in the Nix module means the module is specific to `jpporta-nixos`. We accept this trade-off because the module is only enabled on this host and the alternative (parameterizing) would add ceremony for a single user.