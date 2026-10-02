# Deployment — wezterm-gruvbox-dark

Date: 2026-08-12

## Deployment status

Not deployed by this change record. The repository process requires explicit approval of the exact switch command after validation; no such deployment approval was provided in this request.

## Command

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

Not run.

## Behavior

No post-switch behavior was observed. After an approved switch, restart existing WezTerm windows if necessary and confirm Gruvbox Dark is active.

## Rollback

If the deployed scheme is incorrect, revert the implementation change to `modules/home-manager/wezterm/default.nix` and rerun the approved NixOS switch command. No rollback was needed because no deployment occurred.

## Human gate

This record is complete as a non-deployment record. Deployment remains pending explicit approval of the command above.
