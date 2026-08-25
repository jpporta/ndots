# Plan — Install Ryubing (Nicholas Switch Emulator)

Date: 2026-08-24
Status: awaiting human approval

## Target
- Host: `jpporta-nixos` user environment (Home Manager embedded in NixOS configuration).
- Scope: `modules/home-manager/arch-packages/default.nix`.
- Shared module impact: `arch-packages` is imported only by `jpporta-nixos` (`writter-deck` has its own module set), so this change does not affect the deck.

## Requested source vs. what exists
The request named Ryujinx (https://ryujinx.io). Findings from nixpkgs:

- The upstream Ryujinx project was abandoned/removed from nixpkgs; the **`ryujinx` package no longer exists** on the pinned branch `nixos-26.05` (404, confirmed) or on `nixos-unstable` (404, confirmed). It survives only on the legacy `release-25.05` branch.
- The maintained package in the user's pinned `nixos-26.05` and `nixos-unstable` branches is **`ryubing`** — a community fork of Ryujinx (the `ryubing` package.nix is present: 200 on both branches, imports `git.ryujinx.app/projects/Ryubing`, executables `Ryujinx` / `ryujinx`).

So on NixOS the current, correct way to install the Ryujinx Nintendo Switch emulator is the `ryubing` package in nixpkgs, not the archived `ryujinx` package.

## Current behavior
- `ryubing` (Ryujinx Switch emulator) is not installed on `jpporta-nixos`.

## Desired behavior
1. Install the `ryubing` package (Ryujinx switch emulator, community fork) as a user Home Manager package on `jpporta-nixos` so the `ryujinx` executable is available.

## Affected files
- `modules/home-manager/arch-packages/default.nix`: add `ryubing` to the GUI-apps `pkgs` list, with a brief comment.

## Notes
- Ryubing's first run requires `prod.keys` and Switch firmware/game dumps; those are runtime data, not part of this config change, and go under the emulator's user-data dir (~/.config/Ryubing etc.), not the repo.

## Validation
- Evaluate that the package resolves: `nix eval .#nixosConfigurations.jpporta-nixos.config.home-manager.users.jpporta.packages.ryubing.version`
- Dry build the system to verify nix syntax: `nixos-rebuild dry-build --flake ~/ndots#jpporta-nixos`

## Deployment
After plan approval, implementation, and validation:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback
- Risk: `ryubing`'s DotnetPackages/deps fetch or Avalonia renderer may introduce a large build; the associated fetch is to `git.ryubing.app`. Dry-build first catches fetch errors without switching.
- Rollback: remove the `ryubing` entry from `arch-packages/default.nix`, then rerun `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.

## Human gate
Approve this plan before configuration files are edited.