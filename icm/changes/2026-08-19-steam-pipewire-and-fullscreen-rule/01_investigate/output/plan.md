# Plan — Steam Pipewire Desktop Entry and Fullscreen Window Rule

Date: 2026-08-19
Status: awaiting human approval

## Target
- Host: `jpporta-nixos` user environment (Home Manager embedded in NixOS configuration).
- Scope: `hosts/jpporta-nixos/home.nix` and `modules/home-manager/hyprland/default.nix`.
- Shared module impact: `modules/home-manager/hyprland/default.nix` is currently imported only by `jpporta-nixos` (`writter-deck` uses `cage`/`foot`).

## Current behavior
- Steam uses system desktop entries without `-pipewire` flag.
- Hyprland does not have a window rule enforcing fullscreen on Steam.

## Desired behavior
1. Create a custom Home Manager desktop entry for Steam with `-pipewire` flag in `hosts/jpporta-nixos/home.nix` under `xdg.desktopEntries.steam-pipewire` so it is picked up by application launchers like Rofi.
2. Add a window rule in `modules/home-manager/hyprland/default.nix` to start Steam windows in fullscreen mode.

## Affected files
- `hosts/jpporta-nixos/home.nix`: add `xdg.desktopEntries.steam-pipewire` definition.
- `modules/home-manager/hyprland/default.nix`: add `hl.window_rule` for Steam (`match = { class = "^[sS]team$" }`, `fullscreen = true`).

## Validation
- Evaluate Home Manager configuration: `nix eval .#nixosConfigurations.jpporta-nixos.config.home-manager.users.jpporta.xdg.desktopEntries.steam-pipewire.name`
- Dry build system to verify nix syntax and hyprland config generation: `nixos-rebuild dry-build --flake ~/ndots#jpporta-nixos`

## Deployment
After plan approval, implementation, and validation:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback
- Risk: Applying `fullscreen = true` to all Steam window classes could affect secondary popups/dialogs. If desired later, match can be refined to main window title or specific classes.
- Rollback: Revert edits to `hosts/jpporta-nixos/home.nix` and `modules/home-manager/hyprland/default.nix`, then rerun `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.

## Human gate
Approve this plan before configuration files are edited.
