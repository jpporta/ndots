# Implementation — `pi-coding-agent` from nixpkgs-unstable

## Files changed
- `flake.nix` — added `nixpkgs-unstable` input pointing at `github:NixOS/nixpkgs/nixos-unstable`.
- `modules/home-manager/pi/default.nix` — added `inputs` to the function args; sourced `pi-coding-agent` from `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}`; left the other four entries on stable `pkgs`.

## Diff
```diff
 flake.nix                           |  3 +++
 modules/home-manager/pi/default.nix | 11 ++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)
```

Full diff is in the working tree (`git diff flake.nix modules/home-manager/pi/default.nix`).

## Behavior
- `jpporta-nixos`: pi-coding-agent now resolves from `nixos-unstable` instead of `nixos-26.05`. Expect a version newer than `0.75.4`; `@earendil-works/pi-ai` should be ≥ `0.80.0`, restoring the `/compat` subpath. Other packages on this host (`worktrunk`, `sesh`, `sl`, `signal-cli`) remain on stable.
- `jpporta-deck`: pi-coding-agent already came from `nixpkgs-deck` (`nixos-unstable`); behavior unchanged.

## Deviations from plan
None. The flake edit is byte-identical to the plan snippet; the module edit follows the plan's proposed shape. One cosmetic adjustment in the module: the original `with pkgs; [ … ]` block was split into `[ unstable-attr ] ++ (with pkgs; [ … ])` so only `pi-coding-agent` is sourced from unstable and the rest keep their unqualified `pkgs.<name>` style.

## Next
Stage 03 (`validate`) — run `nix flake check` and dry builds for both hosts. Awaiting diff review before validation per safety gate 3.