# Validation — Steam Pipewire Desktop Entry and Fullscreen Window Rule

## Checks run

1. Evaluated the Home Manager desktop entry for steam-pipewire:
   - `nix eval .#nixosConfigurations.jpporta-nixos.config.home-manager.users.jpporta.xdg.desktopEntries.steam-pipewire.name` -> `"Steam (Pipewire)"`
   - `nix eval .#nixosConfigurations.jpporta-nixos.config.home-manager.users.jpporta.xdg.desktopEntries.steam-pipewire.exec` -> `"steam -pipewire %U"`

2. Performed a dry build of the NixOS system:
   ```bash
   nixos-rebuild dry-build --flake .#jpporta-nixos
   ```
   - Result: Successful. Built derivations include `steam-pipewire.desktop.drv` and `hm_hyprhyprland.lua.drv`.

## Warnings
- Deprecation warnings on `xorg.xauth` and `system` (pre-existing, unrelated to this change).

## Deployment command (awaiting approval)
```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Human check
Review this validation result and approve the deployment command before running switch.
