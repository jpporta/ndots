# Deployment — fix-wezterm-ligatures

Date: 2026-08-12

## Status

Not deployed by this change record. The configuration was validated and the change was archived at the requester's direction; no switch command was run.

## Approved command

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Behavior

No post-switch behavior was observed. After deployment, restart existing WezTerm windows and confirm that ligature marks no longer overlap neighboring characters.

## Rollback

If the deployed configuration behaves incorrectly, revert the change to `modules/home-manager/wezterm/default.nix` and rerun the approved switch command, or boot the prior NixOS generation.
