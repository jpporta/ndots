# Validation — fix-wezterm-ligatures

Date: 2026-08-12

## Result

Validation was confirmed by the requester after implementation. The implementation record also documents successful evaluation of the generated Lua font expression with the three disabled HarfBuzz features.

## Scope checked

- `modules/home-manager/wezterm/default.nix`
- Selected target: `jpporta-nixos`
- No deployment or switch was run as part of this record.

## Remaining note

Interactive rendering should be checked after the configuration is applied and existing WezTerm windows are restarted.

## Deployment status

The change was archived at the requester's direction after validation. The approved switch command remains:

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

No deployment was performed by this change record.
