# Deployment — remove-mdcat-install-tiki

Date: 2026-08-12

## Status

Not deployed by this change record. The configuration was validated and archived at the requester's direction; no switch command was run.

## Approved command

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Behavior

No post-switch behavior was observed. After deployment, verify that `tiki --version` and `tiki --help` are available and that `mdcat` is no longer present.

## Rollback

Revert the change to `modules/home-manager/wezterm/default.nix` and rerun the approved switch command, or boot the prior NixOS generation.
