# Implementation — replace WezTerm with Kitty

## Approved plan
Implemented the approved change from `../01_investigate/output/plan.md`.

## Changed paths
- `modules/home-manager/kitty/default.nix` — added the Kitty Home Manager module, retaining the pinned Tiki 0.6.1 derivation and Mermaid CLI package.
- `modules/home-manager/wezterm/default.nix` — removed the obsolete WezTerm module.
- `hosts/jpporta-nixos/home.nix` — imports and enables the Kitty module instead of WezTerm.
- `modules/home-manager/hyprland/default.nix` — launches `kitty` for the terminal binding.

## Change
The new module configures Kitty with the existing Gruvbox Dark palette, Berkeley Mono Nerd Font Mono, disabled ligatures, font size 11, 80% background opacity, borderless windows, 10px horizontal/16px vertical padding, and a hidden tab bar. Kitty's native graphics protocol is used; no compatibility layer is added. Tiki and Mermaid CLI remain in `home.packages`.

The Kitty module path is new rather than reusing the old `wezterm` directory, so the selected host has no remaining WezTerm import, option, or program configuration.

## Checks
- Inspected the final source diff and searched the selected Nix configuration for remaining WezTerm references; none remain under `hosts/jpporta-nixos` or `modules/home-manager`.
- `nix flake check` — passed (`all checks passed!`).
- `nixos-rebuild dry-build --flake ~/ndots#jpporta-nixos` — passed evaluation and dry-build planning; Kitty, Tiki, Mermaid CLI, and the generated Kitty configuration are present in the planned derivations.
- Generated Kitty configuration includes the translated palette, font, ligature, opacity, padding, border, and tab settings. Kitty 0.47.0 natively implements the Kitty graphics protocol and Unicode placeholders.
- No deployment command was run.

## Deviations
The approved plan named the old WezTerm module path as an affected file while also requiring a Kitty module/import. Following the implementation direction, Kitty is provided at `modules/home-manager/kitty/default.nix` and the obsolete WezTerm module is removed rather than being repurposed under its old path.

## Human gate
Review the source diff and this implementation record before validation/deployment.
