# Implementation — install Superfile from nixpkgs unstable

## Change applied
- Removed the stable `superfile` entry from `modules/home-manager/arch-packages/default.nix`.
- Kept the explicit unstable package in `hosts/jpporta-nixos/home.nix`:
  `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.superfile`

## Reason
Home Manager was receiving both stable and unstable `superfile` derivations. They both install `bin/superfile`, causing `pkgs.buildEnv` to fail with a conflicting subpath error.

## Scope
Only the duplicate package entry was changed. Existing unrelated worktree changes were left untouched.

## Human check
Review the diff before validation.
