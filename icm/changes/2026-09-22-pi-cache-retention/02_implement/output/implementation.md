# Implementation — set pi cache retention

## Approved plan
Plan approval recorded in `../01_investigate/output/plan.md`:

- **Approved by:** user
- **Granted:** "implement it"
- **Date:** 2026-09-22 18:02

## Changed paths
- `modules/home-manager/pi/default.nix`
- `icm/changes/2026-09-22-pi-cache-retention/01_investigate/output/plan.md` (approval record only)

## Source change
Added the pi-specific Home Manager session variable inside the existing `custom.pi.enable` block:

```nix
home.sessionVariables.PI_CACHE_RETENTION = "long";
```

## Behavior
Any Home Manager target that imports this module and sets `custom.pi.enable = true` will get `PI_CACHE_RETENTION=long` in its session environment after activation.

Affected current targets:
- `jpporta-nixos`
- `jpporta-deck`

## Deviations from plan
None for the source edit.

## Formatting / validation status
- Attempted `nixfmt modules/home-manager/pi/default.nix`; it failed because `nixfmt` is not available in the current shell (`command not found`).
- No validation build/check was run; per the process, diff review is the next gate before validation.

## Human gate
Review the diff and this implementation record before validation.
