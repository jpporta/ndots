# Implementation — install-wezterm-mdcat

Date: 2026-08-12

## Changes made

- Added the opt-in `modules/home-manager/wezterm/default.nix` module.
  - Defines `custom.wezterm.enable`.
  - Enables Home Manager's `programs.wezterm` integration.
  - Configures BerkeleyMono Nerd Font Mono at 11pt, no window decorations, 0.8 background opacity, and 10x16 horizontal/vertical window padding.
  - Installs `pkgs.mdcat` in the user's Home Manager package set.
- Imported and enabled the new module in `hosts/jpporta-nixos/home.nix`.
- Changed the Hyprland terminal launcher from `alacritty` to `wezterm`; Alacritty remains imported and enabled as the fallback terminal.

## Validation

- `nix flake check` passed. The check emitted only the repository's existing xorg deprecation warning and omitted incompatible `aarch64-linux` checks.
- `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link` passed. The build evaluated and built the Home Manager WezTerm configuration and fetched/build-used nixpkgs `mdcat-2.7.1`.
- `git diff --check` passed after implementation.

## Deviations

None. No deployment was performed.

## Residual risks

The configuration/build validates package installation and generated configuration but does not verify interactive WezTerm rendering or mdcat image support. The terminal shortcut now launches WezTerm while Alacritty remains available as fallback, as planned.
