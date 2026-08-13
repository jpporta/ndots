# Implementation — disable broken WezTerm ligatures

## Approved plan
Implemented the approved change from `../01_investigate/output/plan.md`.

## Changed path
- `modules/home-manager/wezterm/default.nix`

## Change
Replaced the simple Berkeley Mono font expression with the expanded WezTerm font form and disabled the HarfBuzz features `calt`, `clig`, and `liga` for that font.

No other settings, hosts, modules, or dependencies were changed.

## Checks
- Inspected the source diff: one configuration line changed.
- Evaluated the generated Lua value with `nix-instantiate`; it renders the expected `wezterm.font { ... harfbuzz_features = { ... } }` expression.

## Human gate
Review the source diff and this implementation record before validation.
