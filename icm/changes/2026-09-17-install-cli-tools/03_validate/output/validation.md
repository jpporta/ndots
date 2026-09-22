# Validation — install leaf, ghgrab, tuxedo, kew

## Command
`nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`

(build only, no switch, run from `~/ndots`)

## Result
- Build succeeded: `nixos-system-jpporta-nixos-26.05.20260803.531670d` at `/nix/store/03lg695rzs2sbx7hk4alam3qdhv6a5zq-...`
- Evaluation warnings: only the pre-existing "Git tree is dirty" warning (unrelated work in the tree).

## Binary verification
Home Manager path of the built toplevel: `/nix/store/cncrfsbpb1538ck6r9axn306nqqsgf1l-home-manager-path`
- `bin/leaf` ✓ present
- `bin/ghgrab` ✓ present
- `bin/tuxedo` ✓ present
- `bin/kew` ✓ present

## Warnings / unresolved risk
- None blocking. Runtime behavior of the four programs can only be observed after the switch (deploy stage).

## Human gate
Explicit approval of the deployment command is required before switching:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
