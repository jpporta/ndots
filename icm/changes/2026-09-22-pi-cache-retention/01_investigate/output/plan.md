# Plan — set pi cache retention

## Request
Set `PI_CACHE_RETENTION=long` with the pi coding agent Home Manager module so pi-related setup stays in one file.

## Target and impact
- Target source: shared Home Manager module `modules/home-manager/pi/default.nix`.
- Imported by:
  - `hosts/jpporta-nixos/home.nix` (`custom.pi.enable = true`)
  - `hosts/writter-deck/home.nix` (`custom.pi.enable = true`)
- Impact: both configured Home Manager targets get `PI_CACHE_RETENTION=long` when the pi module is enabled.

## Current behavior
`modules/home-manager/pi/default.nix` only installs the pi package and helper packages under `config.custom.pi.enable`; it does not set pi-specific environment variables.

## Proposed change
Add one Home Manager session variable inside the existing `lib.mkIf config.custom.pi.enable` block:

```nix
home.sessionVariables.PI_CACHE_RETENTION = "long";
```

This keeps the value module-scoped: it is present only for hosts/users that enable `custom.pi.enable`. It is session-wide, not a wrapper that restricts the variable to only the `pi` process.

## Files to edit
- `modules/home-manager/pi/default.nix`

## Validation
Run formatting/checks after implementation:

```sh
nixfmt modules/home-manager/pi/default.nix
nix flake check
```

If `nix flake check` is too broad or unavailable, build the affected Home Manager targets instead:

```sh
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel
nix build .#homeConfigurations.jpporta-deck.activationPackage
```

## Deployment commands, after validation approval
- NixOS host/user environment:

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

- Deck Home Manager environment:

```sh
home-manager switch --flake ~/ndots#jpporta-deck
```

## Risks
- Shared-module change affects both machines that enable `custom.pi.enable`.
- The variable is session-wide once Home Manager activates; if strict per-process scoping is required, use a pi wrapper instead of `home.sessionVariables`.

## Rollback
Remove `home.sessionVariables.PI_CACHE_RETENTION = "long";` from `modules/home-manager/pi/default.nix`, validate, and redeploy the affected target.

## Human gate
Approve this plan before any configuration edit.

## Approval — plan
- **Approved by:** user
- **Granted:** "implement it"
- **Date:** 2026-09-22 18:02
- **Scope:** Implementation of this plan: add `PI_CACHE_RETENTION=long` to the pi Home Manager module.
