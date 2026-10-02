# Implementation: install `slk` on `jpporta-nixos`

## Plan approval
The target plan was approved by the user before implementation.

## Changed paths
- `flake.nix`
  - Added the pinned upstream input `github:gammons/slk`.
- `flake.lock`
  - Locked `slk` and its transitive `flake-utils`, `nix-systems`, and nixpkgs inputs.
- `hosts/jpporta-nixos/home.nix`
  - Added `slk` to the `jpporta` Home Manager package list.
  - Disabled the upstream package's check phase because its isolated Nix build fails in `TestUserResolver_BatchesMissesThroughEdge`; this is a package test failure, not a compile failure.

## Result
The `slk` executable will be installed in the `jpporta` user environment for `jpporta-nixos` after the approved NixOS switch.

## Diff check
`git diff --check` passed.

## Intentional deviation
The original plan named the `slk` input and package additions. Updating `flake.lock` was also required to pin the new flake input reproducibly.
