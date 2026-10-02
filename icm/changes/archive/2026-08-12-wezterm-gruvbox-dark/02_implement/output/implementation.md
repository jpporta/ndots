# Implementation — wezterm-gruvbox-dark

Date: 2026-08-12

## Changes made

- Updated `modules/home-manager/wezterm/default.nix`.
- Added a complete local `Gruvbox Dark` WezTerm color scheme with ANSI, bright, background, foreground, cursor, and selection colors.
- Set `settings.color_scheme = "Gruvbox Dark"` so WezTerm uses the scheme by default.
- Preserved the existing WezTerm font, window opacity, padding, and tab-bar settings.

## Diff review

- `git diff --check` passed.
- Only the approved WezTerm module was edited for this change.
- Existing unrelated changes in the working tree were not modified.

## Deviations

None.

## Human gate

Implementation is complete. Review the source diff and this record before validation.
