# Plan — install claude-code from unstable with unfree allowed

## Target
- Host: `jpporta-nixos` (NixOS system configuration and Home Manager user environment).
- Sources:
  - `hosts/jpporta-nixos/configuration.nix`
  - `hosts/jpporta-nixos/home.nix`

## Problem Statement & Diagnosis
1. When attempting to install `claude-code` via `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.claude-code`, Nix throws an unfree license error because `legacyPackages` is evaluated unconfigured (`config.allowUnfree = false`).
2. Setting `nixpkgs-unstable.config.allowUnfree = true;` in `configuration.nix` fails with `The option nixpkgs-unstable does not exist` because NixOS only defines module options under `nixpkgs.*`.
3. Setting `nixpkgs.config.allowUnfree = true;` only applies to the main `nixos-26.05` package set, not to raw flake input `legacyPackages`.

## Scope & Impact
- Target: `jpporta-nixos` system and user environment.
- Impact on other hosts: None. `hosts/jpporta-nixos/configuration.nix` and `hosts/jpporta-nixos/home.nix` are specific to `jpporta-nixos`. `jpporta-deck` is unaffected.
- Pre-existing working tree state: The user had previously staged edits in `hosts/jpporta-nixos/home.nix` (including `gnome-bluetooth` and systemd `lan-mouse` formatting) prior to this change.

## Proposed Change (Option 1)
1. In `hosts/jpporta-nixos/configuration.nix`:
   - Remove the invalid option `nixpkgs-unstable.config.allowUnfree = true;`.
   - Add a Nixpkgs overlay defining `unstable`:
     ```nix
     nixpkgs.overlays = [
       (final: prev: {
         unstable = import inputs.nixpkgs-unstable {
           system = prev.stdenv.hostPlatform.system;
           config.allowUnfree = true;
         };
       })
     ];
     ```
2. In `hosts/jpporta-nixos/home.nix`:
   - Update the unstable package list to reference `pkgs.unstable`:
     ```nix
     ++ [
       pkgs.unstable.lan-mouse
       pkgs.unstable.superfile
       pkgs.unstable.tuxedo
       pkgs.unstable.claude-code
     ];
     ```

## Validation Approach
1. Build the system configuration toplevel derivation without linking:
   `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`
2. Verify that the derivation succeeds, ensuring `claude-code` from `nixpkgs-unstable` resolves with `allowUnfree = true` and builds cleanly without collisions.
3. Test executing `claude --version` directly from the built store path.

## Deployment Command
Executed only upon explicit human approval:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
(or via user alias `nixs`)

## Rollback Path
Revert the edits in `hosts/jpporta-nixos/configuration.nix` and `hosts/jpporta-nixos/home.nix`. If deployed, use `sudo nixos-rebuild switch --rollback`.

## Approval — Plan
- **Approved by:** jpporta
- **Granted:** "please implement optionplease implement option 1"
- **Date:** 2026-10-01 12:00
- **Scope:** Option 1 — Nixpkgs overlay in configuration.nix and pkgs.unstable references in home.nix.
