# Implementation — Steam Pipewire Desktop Entry and Fullscreen Window Rule

## Change applied
- In `hosts/jpporta-nixos/home.nix`:
  Added `xdg.desktopEntries.steam-pipewire` with:
  - `name = "Steam (Pipewire)"`
  - `exec = "steam -pipewire %U"`
  - `icon = "steam"`
  - `type = "Application"`
  - `categories = [ "Game" ]`
  - `mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ]`
- In `modules/home-manager/hyprland/default.nix`:
  Added `hl.window_rule` with:
  - `name = "Steam Fullscreen"`
  - `match = { class = "^[sS]team$" }`
  - `fullscreen = true`

## Scope
Only the specified files for `jpporta-nixos` and Hyprland config were modified.

## Human check
Review the diff before validation.
