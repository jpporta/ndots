# Deployment — theme-picker

Date: 2026-08-26
Status: deployed

## Target

- Host: `jpporta-nixos` (Home Manager embedded in the NixOS config).
- Build/switch command: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.

## What was deployed

| File | Role |
|---|---|
| `modules/home-manager/theme-picker/default.nix` | HM module writing `~/.config/quickshell/theme-picker/shell.qml`. |
| `modules/home-manager/theme-picker/shell.qml` | The one-shot Quickshell picker (root = `PanelWindow`). |
| `hosts/jpporta-nixos/home.nix` | `custom.theme-picker.enable = true;` + module import (this change's lines only). |
| `modules/home-manager/hyprland/default.nix` | `p.theme_picker = "qs -p ~/.config/quickshell/theme-picker"` + bind `SUPER + ALT + T`. |
| `tooling/theme-switcher/theme-switcher` | Additive `--dump` subcommand (already committed in the prior `themes` commit). |

## Post-switch behavior

- `~/.config/quickshell/theme-picker/shell.qml` present (HM store symlink, refreshed by the rebuild).
- `SUPER + ALT + T` opens the centered grid overlay; no blank managed window.
- Navigation (vim/arrow), hover, ESC/backdrop dismiss, and Enter→live theme switch all work.
- Existing `theme-switcher` flows (`--list`, `<slug>`) unchanged.

## Rollback path

- Disable trigger: remove the `hl.bind(mod_alt .. " + T", ...)` line.
- Remove the shell: unset `custom.theme-picker.enable` and rebuild.
- `--dump` is additive; removing it only affects the picker, not existing switcher flows.

## Out of scope (left for separate changes)

- The unrelated staged work (little-coder module, ollama, oh-my-posh edits, configuration.nix) is **not** part of this change and was committed separately / left untouched.
