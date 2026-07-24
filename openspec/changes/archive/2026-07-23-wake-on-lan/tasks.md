## 1. Create the WOL NixOS module

- [x] 1.1 Create `modules/nixos/wake-on-lan/default.nix` with a `custom.wake-on-lan.enable` option.
- [x] 1.2 Define a systemd `oneshot` service `wol-enp14s0.service` that runs `ethtool -s enp14s0 wol g`.
- [x] 1.3 Wire the unit's `after`/`wants` to `network-online.target` and `NetworkManager.service` so it runs after the link is up.
- [x] 1.4 Add the unit to the resume path so `wol g` is re-applied after suspend/resume (use `systemd-suspend.service` or a `path` unit hook).

## 2. Add packages and the convenience wrapper

- [x] 2.1 Add `pkgs.ethtool` and `pkgs.wakeonlan` to `environment.systemPackages` when the module is enabled. *(Note: `pkgs.iputils` does not provide `wakeonlan` in nixpkgs — see implementation note.)*
- [x] 2.2 Create a `wake-jpporta-nixos` shell script via `pkgs.writeShellScriptBin` that invokes `wakeonlan -i ${1:-255.255.255.255} d8:43:ae:5a:ae:12`.
- [x] 2.3 Add the wrapper to `environment.systemPackages`.

## 3. Wire the module into the host

- [x] 3.1 Add `../../modules/nixos/wake-on-lan` to `imports` in `hosts/jpporta-nixos/configuration.nix`.
- [x] 3.2 Add `custom.wake-on-lan.enable = true;` under the existing `custom = { ... };` block in the host config.

## 4. Verify and document

- [x] 4.1 Rebuild the system with `sudo nixos-rebuild switch --flake .#jpporta-nixos`.
- [x] 4.2 Run `ethtool enp14s0` and confirm `Supports Wake-on:` lists `g` and `Wake-on: g`.
- [x] 4.3 Run `systemctl status wol-enp14s0.service` and confirm the unit is `active (exited)`.
- [x] 4.4 Run `wake-jpporta-nixos` once while the machine is up to confirm the script runs without error (it will be a no-op when the host is already up).
- [x] 4.5 Shut the machine down, then run `wake-jpporta-nixos` from another machine on the same LAN and confirm `jpporta-nixos` powers on.
- [x] 4.6 Document the BIOS-level prerequisite ("Wake on LAN" enabled, "After Power Loss" → Power Off / Stay Off) in the change notes or a README so it's not lost.