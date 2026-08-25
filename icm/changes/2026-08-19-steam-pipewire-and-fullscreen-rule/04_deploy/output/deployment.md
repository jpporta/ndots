# Deployment — Steam Pipewire Desktop Entry and Fullscreen Window Rule

Date: 2026-08-19

## Status
Deployed and verified by user.

## Command run
```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Observed behavior
- `Steam (Pipewire)` desktop entry (`steam -pipewire %U`) is present in XDG application menus and recognized by Rofi.
- Hyprland window rule applies fullscreen mode upon Steam startup as expected.

## Rollback
If needed, revert the additions in `hosts/jpporta-nixos/home.nix` and `modules/home-manager/hyprland/default.nix`, then run `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.
