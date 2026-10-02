# Implementation — install leaf, ghgrab, tuxedo, kew

Plan approved: see `../../01_investigate/output/plan.md` (Approval — plan, 2026-09-17 15:36).

## Changed paths
- `modules/home-manager/leaf/default.nix` (new): `custom.leaf.enable` option; packages `leaf-markdown-viewer` 1.28.2 via `rustPlatform.buildRustPackage` from `RivoLink/leaf` release tag `1.28.2` (`fetchFromGitHub`, hash `sha256-WX9C4gWNPCHWFsHN4xFmShv6dJyYAVgr9xMw5JtoFHI=`, `cargoLock.lockFile = ./Cargo.lock`, `mainProgram = "leaf"`).
- `modules/home-manager/leaf/Cargo.lock` (new): verbatim `Cargo.lock` from the leaf 1.28.2 release tag, used as `cargoLock.lockFile`.
- `hosts/jpporta-nixos/home.nix`:
  - import `../../modules/home-manager/leaf`
  - `custom.leaf.enable = true`
  - `home.packages`: added `ghgrab` and `kew` (stable nixpkgs)
  - unstable block: added `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tuxedo`

## Behavior
- `leaf`, `ghgrab`, `tuxedo`, `kew` become available on PATH in the `jpporta-nixos` user environment after switch. `jpporta-deck` is untouched (new module imported only by the jpporta-nixos host; `arch-packages` not edited).

## Deviations from plan
- None. The module was implemented as a `custom.leaf.enable` option matching the repository's module convention (the plan said "package ... with buildRustPackage"; the option wrapper follows the repo pattern used by bat/lazygit/etc.).

## Notes
- `modules/home-manager/leaf` had to be `git add`ed for the Nix flake evaluator to see it (expected for a git-tracked flake; staged, not committed).
