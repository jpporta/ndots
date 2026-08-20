# Deployment — Steam Pipewire Desktop Entry and Fullscreen Window Rule

## Approved command
```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Outcome
The command was attempted following validation, but cannot run directly within the non-interactive agent process because `sudo` requires a password on a TTY:

```text
sudo: a terminal is required to read the password; either use the -S option or configure an askpass helper
sudo: a password is required
```

## Required manual action
Run the approved switch command from an interactive terminal:

```bash
cd ~/ndots
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Post-switch verification
1. Check that the desktop entry was generated:
   ```bash
   cat ~/.nix-profile/share/applications/steam-pipewire.desktop
   ```
2. Open Rofi and launch `Steam (Pipewire)`.
3. Verify that Steam launches with `-pipewire` and Hyprland opens the window in fullscreen.
