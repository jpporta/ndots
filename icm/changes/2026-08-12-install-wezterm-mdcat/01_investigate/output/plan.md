# Plan — install-wezterm-mdcat

Date: 2026-08-12
Status: awaiting human approval

## Target
- Host: jpporta-nixos user environment
- Build/switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
- Shared module impact: The new `wezterm` module will be opt-in and initially enabled only by `hosts/jpporta-nixos/home.nix`. `modules/home-manager/hyprland/default.nix` is shared in principle, but its only current importer is that host, so the terminal-launcher change affects no other configured host.

## Current behavior
`hosts/jpporta-nixos/home.nix` imports and enables `modules/home-manager/alacritty`. That module configures Alacritty with BerkeleyMono Nerd Font Mono at 11pt, no window decorations, 0.8 opacity, dynamic padding, and 10 horizontal by 16 vertical padding. No WezTerm or mdcat configuration/package is currently present.

The shared Hyprland module sets its terminal command to `alacritty`, so `SUPER+Return` launches Alacritty. The writer-deck target does not import the Alacritty or Hyprland modules; it runs Foot under Cage and is outside this change.

## Desired behavior
Add a shared, opt-in Home Manager WezTerm module for `jpporta-nixos` that mirrors the applicable existing Alacritty presentation: BerkeleyMono Nerd Font Mono at 11pt, no decorations, 0.8 window background opacity, and equivalent window padding. Keep Alacritty installed and configured as a fallback.

Install the `mdcat` package from nixpkgs in the same Home Manager module so the `mdcat` executable is available in the user's environment. Configure Hyprland's terminal command so `SUPER+Return` launches WezTerm, allowing mdcat to use WezTerm's terminal rendering capabilities where supported.

## Affected files
- `modules/home-manager/wezterm/default.nix` — new opt-in Home Manager module that enables/configures WezTerm and installs the nixpkgs `mdcat` package.
- `hosts/jpporta-nixos/home.nix` — import the new module and enable it for the selected user's Home Manager configuration.
- `modules/home-manager/hyprland/default.nix` — change the configured terminal command from `alacritty` to `wezterm`, affecting the existing `SUPER+Return` launcher.

## Validation
- Command: `nix flake check`
- Expected outcome: The flake evaluates successfully, including the new Home Manager module and the nixpkgs `mdcat` package.
- Command: `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`
- Expected outcome: The selected host's system configuration builds without creating a result symlink; its Home Manager profile contains runnable `wezterm` and `mdcat` binaries.

## Deployment
- Command: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks
- The nixpkgs `mdcat` package may change behavior with the flake's pinned nixpkgs revision; successful installation alone does not prove every Markdown or image will render as intended.
- Changing the Hyprland terminal command changes `SUPER+Return` behavior. Alacritty remains installed/configured as a fallback if WezTerm is unsuitable.
- Image rendering depends on WezTerm graphics support and mdcat's runtime rendering prerequisites; successful installation alone does not prove every image will render in the terminal.
- Do not import external dotfiles or store secrets while implementing this change.

## Rollback
- Command: `git revert <implementation-commit> && sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
