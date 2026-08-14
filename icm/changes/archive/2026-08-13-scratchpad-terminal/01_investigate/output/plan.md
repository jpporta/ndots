# Plan — scratchpad-terminal

Date: 2026-08-13
Status: awaiting human approval

## Target
- Host: `jpporta-nixos` user environment (Home Manager)
- Build/switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
- Shared module impact: The affected Hyprland module is shared Home Manager code, but it is currently imported by `hosts/jpporta-nixos/home.nix` only; no effect on `jpporta-deck` is expected.

## Current behavior
Hyprland launches the normal Kitty terminal with `Super+Return`. There is currently no separate `Super+/` launch command, dedicated Kitty class, or matching Hyprland window rule for a centered floating terminal. Kitty already uses `close_on_child_death = true`, so a Kitty window closes when its child shell exits.

## Desired behavior
`Super+/` launches Kitty with a dedicated class (for example, `scratchpad-terminal`). A matching Hyprland window rule floats that class, centers it on the active monitor, and gives it a 4:3 aspect ratio. The terminal is distinct from `Super+Return`'s normal Kitty launch. It remains an interactive shell until the shell exits, at which point Kitty destroys the window.

## Affected files
- `modules/home-manager/hyprland/default.nix` — add the dedicated Kitty launch command and `Super+/` binding, plus a matching Hyprland window rule that centers the dedicated class and configures a 4:3 window.
- `hosts/jpporta-nixos/home.nix` — reviewed as the target Home Manager entry point; no content change is expected because it already enables and imports the Hyprland module.

## Validation
- Command: `nix flake check`
- Command: `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --dry-run`
- Expected outcome: Both commands complete successfully. After an approved deployment, `Super+/` opens the dedicated Kitty window as a centered floating 4:3 terminal, while `Super+Return` continues to open the normal Kitty terminal; closing the interactive shell destroys the scratchpad window.

## Deployment
- Command: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks
- The Hyprland module is shared configuration; an incorrect rule could affect any other host that later imports it.
- A class/name mismatch between Kitty and the Hyprland rule could leave the terminal tiled or incorrectly sized.
- The `Super+/` key syntax may need to match Hyprland's key naming for the slash key.
- Deploying the switch command against the wrong host would apply the configuration to an unintended system; verify the target before switching.

## Rollback
- Revert the affected configuration commit with `git revert <commit>`.
- Reapply the host configuration with `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.
