# Plan — Install Waydroid (Android container) on jpporta-nixos

Date: 2026-08-31
Status: awaiting human approval

## Target
- Host: `jpporta-nixos` system configuration.
- Scope: new module `modules/nixos/waydroid/default.nix` + import/enable in `hosts/jpporta-nixos/configuration.nix`.
- Shared module impact: `modules/nixos/` is only imported by `jpporta-nixos`; the `writter-deck` host has its own Home Manager module set, so it is unaffected.

## Requested source vs. what exists
The request is to install Waydroid, the container-based Android runtime (Android 13 / LineageOS in an LXC container, near-native performance on Wayland).

Findings from nixpkgs (pinned `nixos-26.05`, verified with `nix eval`):

- `waydroid` 1.6.3 and `waydroid-nftables` 1.6.3 both exist on the pinned branch.
- Per the official NixOS Wiki, newer kernels should use `pkgs.waydroid-nftables` as the package (nftables firewall backend), so the plan pins that variant.

Host compatibility notes:
- The host runs Hyprland (Wayland session) — Waydroid's hard requirement is satisfied.
- The host uses an AMD GPU (`boot.initrd.kernelModules = [ "amdgpu" ]`) — GBM/Mesa hardware acceleration works out of the box; no NVIDIA swiftshader fallback tweaks expected.
- `wl-clipboard` (needed for host clipboard sharing) is already installed via the user environment (`modules/home-manager/arch-packages/default.nix`), so no extra package is added.

## Current behavior
- Waydroid is not installed; `virtualisation.waydroid` is unset and there is no Android runtime on the host.

## Desired behavior
1. A `custom.waydroid.enable` NixOS option (same pattern as `custom.steam.enable`, `custom.ollama.enable`) that, when enabled:
   - sets `virtualisation.waydroid.enable = true;`
   - sets `virtualisation.waydroid.package = pkgs.waydroid-nftables;` (newer-kernel variant per NixOS Wiki)
2. The module is imported and enabled in `hosts/jpporta-nixos/configuration.nix`.

## Affected files
- `modules/nixos/waydroid/default.nix` — new module (options + config, ~15 lines).
- `hosts/jpporta-nixos/configuration.nix` — add `../../modules/nixos/waydroid` to `imports` and `waydroid.enable = true;` to the `custom` block.

## Runtime steps outside this change (not configuration)
After deploy, Waydroid still needs one-time runtime init by the user:
- `sudo waydroid init -s GAPPS -f` (fetches LineageOS images; GAPPS adds Play Store)
- `sudo systemctl start waydroid-container && waydroid session start && waydroid show-full-ui`
- Play Store may require device certification (register Android ID with Google) — documented in the NixOS Wiki; runtime-only, no repo change.

## Validation
- `nixos-rebuild dry-build --flake ~/ndots#jpporta-nixos` — proves the evaluation and build of the new module without switching.

## Deployment
After plan approval, implementation review, and validation approval:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback
- Risk: the module adds a systemd container service and LXC/nftables glue at boot; a misconfigured nftables backend could affect the firewall. Mitigated by using the nixpkgs-supported `waydroid-nftables` variant and dry-building before switch.
- Risk: GAPPS images are a separate ~1 GB download at first `waydroid init`; failure there is runtime-only and does not affect the NixOS generation.
- Rollback: set `custom.waydroid.enable = false;` (or remove the import), then `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`. Residual state lives in `/var/lib/waydroid` and `~/.local/share/waydroid` and can be deleted independently.

## Human gate
Approve this plan before any configuration file is edited.
