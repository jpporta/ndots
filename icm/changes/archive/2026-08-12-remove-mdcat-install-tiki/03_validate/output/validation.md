# Validation — remove-mdcat-install-tiki

Date: 2026-08-12

## Result

Validation passed and was confirmed by the requester.

## Commands

```sh
nix flake check
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link
git diff --check
```

All commands passed. The NixOS target built Tiki v0.6.1 successfully, and the resulting closure contains Tiki without mdcat.

## Remaining note

Interactive Tiki behavior should be checked after the configuration is applied.

## Deployment status

The change was archived at the requester's direction. No deployment command was run by this change record.

Approved switch command if needed:

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```
