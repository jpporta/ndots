# Plan — fix WezTerm ligature placement

## Target
- Host: `jpporta-nixos`
- Scope: Home Manager user environment, shared module imported only by `hosts/jpporta-nixos/home.nix`.
- Source: `modules/home-manager/wezterm/default.nix`

## Observed behavior
The supplied screenshot shows ligature marks rendered over neighboring characters rather than occupying the expected combined cell spacing. The current WezTerm configuration explicitly selects `BerkeleyMono Nerd Font Mono` but leaves HarfBuzz shaping features at their defaults, so ligatures are enabled.

## Proposed change
Disable the OpenType ligature features for the selected Berkeley Mono font by changing the existing `wezterm.font(...)` expression to the expanded form with:

```lua
harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
```

This preserves the font, size, colors, padding, opacity, and all other terminal behavior while avoiding the broken ligature glyph placement. It is scoped to this font rather than changing shaping globally.

## Affected files
- Edit: `modules/home-manager/wezterm/default.nix`
- Record only: this change folder under `icm/changes/2026-08-12-fix-wezterm-ligatures/`

The module is not currently imported by `hosts/writter-deck/home.nix`; no deck configuration is affected.

## Validation
Run:

```sh
nix build .#nixosConfigurations.jpporta-nixos.config.home-manager.users.jpporta.home.activationPackage
```

Inspect the generated WezTerm configuration if needed to confirm the font expression includes the three disabled features. Do not switch until validation and the deployment command are explicitly approved.

## Deployment and rollback
Approved target command from `icm/_shared/targets.md`:

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

Rollback: revert the one-line font setting change and rerun the same approved NixOS switch command (or use the prior NixOS generation if the switch itself fails).

## Risks
- Existing ligature-dependent visual preferences will be removed for this font; ordinary glyphs and Nerd Font symbols remain available.
- No secrets, external dotfiles, system services, or other hosts are involved.

## Human gate
Please review and approve this plan before any configuration edit.
