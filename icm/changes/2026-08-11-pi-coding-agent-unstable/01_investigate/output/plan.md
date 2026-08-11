# Plan — switch `pi-coding-agent` to nixpkgs-unstable

## Target
- Shared Home Manager module: `modules/home-manager/pi/default.nix`.
- Per `icm/_shared/targets.md`, this module is shared. Imports verified:
  - `hosts/jpporta-nixos/home.nix` → uses stable nixpkgs (`nixos-26.05`) via the host's `home-manager`.
  - `hosts/writter-deck/home.nix` → uses `home-manager-deck` which follows `nixpkgs-deck` (`nixos-unstable`). The deck already gets pi from unstable; net behavior on the deck is unchanged.

## Current behavior
`modules/home-manager/pi/default.nix` lists `pi-coding-agent` from `pkgs`, i.e. the host's default nixpkgs:
- `jpporta-nixos` → stable `nixos-26.05` (currently pi `0.75.4`, bundled `@earendil-works/pi-ai@0.75.4`).
- `jpporta-deck` → `nixos-unstable` (already newer, so no functional change there after this switch).

This is the source of the recent extension failure: `pi-subagents@0.46.0` and `pi-web-access@0.21.0` import `@earendil-works/pi-ai/compat`, a subpath that only exists in `pi-ai ≥ 0.80.0`. Workarounds were applied (pinned `pi-subagents@0.34.0`, `pi-web-access@0.10.7`) — this change makes those workarounds unnecessary on next `pi update`.

## Affected files
1. `flake.nix` — add an `nixpkgs-unstable` input.
2. `modules/home-manager/pi/default.nix` — source `pi-coding-agent` from `inputs.nixpkgs-unstable`.

No other files require edits. `inputs` is already passed to Home Manager via `extraSpecialArgs` in both host entry points.

## Proposed change

### `flake.nix` — add input
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";  # NEW
  nixpkgs-deck = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
  # ... rest unchanged
};
```
Rationale: keeps `nixpkgs-deck` for the deck host unchanged (zero behavior change there). New `nixpkgs-unstable` is a separate input dedicated to this override — keeps the diff small and the deck path untouched.

### `modules/home-manager/pi/default.nix`
```nix
{ lib, config, pkgs, inputs, ... }:

{
  options.custom = {
    pi.enable = lib.mkEnableOption "enable pi - pi.dev coding agent";
  };

  config = lib.mkIf config.custom.pi.enable {
    home.packages = [
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent
      worktrunk
      sesh
      sl
      signal-cli
    ];
  };
}
```
Other entries stay on `pkgs` (stable); only pi is overridden. `inputs` is already in scope via `extraSpecialArgs`.

## Validation approach
1. `nix flake check` — schema check.
2. Per-host build only (no switch):
   - `nix build ~/ndots#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --dry-run` — or full dry build to confirm resolution.
   - `nix build ~/ndots#homeConfigurations.jpporta-deck.activationPackage --dry-run` — confirms the deck still resolves.
3. Confirm resolved version: `nix eval ~/ndots#homeConfigurations.jpporta-deck.config.home.packages --apply 'pkgs: builtins.head (builtins.filter (p: (p.pname or "") == "pi-coding-agent") pkgs).version'` (or equivalent expression). Should report a version newer than `0.75.4`.

## Deployment
1. NixOS host: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.
2. Deck host: `home-manager switch --flake ~/ndots#jpporta-deck` (only required to keep flake outputs in sync; no behavior change expected there).
3. After switch, run `pi --version` and `pi list` on the NixOS host; confirm the user-installed extensions (`pi-subagents@0.34.0`, `pi-web-access@0.10.7`) load without the `/compat` import error.

## Risks
- **Unstable churn.** Pulling one package from `nixos-unstable` means future pi updates track unstable. Containment is good (single package), but expect more frequent rebuilds for pi only.
- **Extension pins.** User currently has `pi-subagents@0.34.0` and `pi-web-access@0.10.7` pinned to work around the old pi-ai. After the bump these pins may be removed (`pi update --extension npm:pi-subagents`) once the extension loads on the new pi-ai. Not part of this change — note for follow-up.
- **Deck input drift.** `nixpkgs-deck` and the new `nixpkgs-unstable` both point at `nixos-unstable` but are independent flake inputs — they may pin to different commits if one is updated and the other isn't. Acceptable; flag for consolidation later if desired.

## Rollback
1. Revert the two edits.
2. `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos` on the NixOS host.
3. (Optional) `home-manager switch --flake ~/ndots#jpporta-deck` on the deck.
4. If extension pins need to come back into force after rollback, reinstall them per the prior session commands.