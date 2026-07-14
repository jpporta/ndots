## Why

Today, switching color themes on jpporta-nixos requires manual editing of files scattered across `~/.config/`, plus a `nixos-rebuild switch` whenever a themed Nix module (swaync, wlogout) is involved. The user already maintains 11 curated palettes under `~/.config/colorschemes/<theme>/` (catppuccin, gruvbox-dark, tokyo-night, nord-darker, rose-pine, kanagawa, nightfox, everforest-dark, e-ink, noir, and one more), but there is no canonical "current theme" pointer, no atomic swap, no live propagation to running apps, and no keybind-driven picker. The user wants to switch themes in one command — fast, with no rebuild — and have every themed app update.

## What Changes

- **New module `modules/home-manager/theme/`** that installs `theme-switch` (CLI) and `theme-picker` (rofi wrapper) into `~/.local/bin`, adds a `SUPER+T` Hyprland keybind for the picker, declares `custom.theme.current` as the boot-time default, and registers a systemd user oneshot that re-applies the current theme on graphical-session start.
- **New script `theme-switch <name>`** that performs an atomic theme swap by rewriting a single `~/.config/colorschemes/.active` symlink, then emits per-app reload signals (waybar SIGUSR2, swaync-client `--reload-css`, kitty `@ set-colors`, ghostty SIGUSR1, gsettings color-scheme flip, etc.) so live apps reflect the new palette without restart. Idempotent: invoked with no args, it re-applies whatever `.current` says (used on boot).
- **New script `theme-picker`** — a rofi-driven wrapper around `theme-switch` that lists available themes from `~/.config/colorschemes/*/meta` and invokes the switcher on selection.
- **New per-theme `meta` file** (one per theme): `name=...`, `mode=dark|light`. Drives gsettings and the darkman integration.
- **Hook point `~/.config/colorschemes/.hook <theme-name>`**: `theme-switch` execs this at the end of every switch. This is where the user drops their wallpaper-rotation script. The change does NOT write the wallpaper hook — that is owned by the user.
- **Cleanup pass** on `swaync`, `wlogout`, `alacritty`, and `darkman` Nix modules: drop the hardcoded gruvbox color strings (Nix store), point their configs at the active theme dir via out-of-store symlinks, and reduce `darkman` to only drive `hyprsunset` (time-of-day temperature). After this one-time rebuild, theme switching never touches Nix again.
- **Bonus (writer-deck)**: same Nix module imported by `hosts/writter-deck/home.nix` so the foot terminal on the Steam Deck can switch themes the same way (foot has no live reload, but a relaunch in cage is acceptable for a writer deck).

No app configuration is being deleted from `dotfiles/colorschemes/`; the cleanup pass only removes the *duplicate* hardcoded gruvbox strings that currently live in Nix modules while leaving the themed files in `~/.config/colorschemes/<theme>/` untouched.

## Capabilities

### New Capabilities

- `theme-switch`: the runtime CLI + rofi picker + boot-time applier; defines the contract for what "switching themes" means in this system (atomic `.active` symlink, per-app reload signals, hook execution, gsettings flip driven by `meta` mode).
- `theme-colors-sources`: the convention that every themed app on this system reads its colors from `~/.config/colorschemes/.active/<app>/...` rather than from Nix-store-baked strings; covers the cleanup pass on swaync/wlogout/alacritty so future theme additions don't require module edits.

### Modified Capabilities

<!-- No existing specs in openspec/specs/ yet, so nothing to list. The cleanup pass on swaync/wlogout/alacritty/darkman is implementation-level, not a requirement change for any existing spec. -->

## Impact

- **New files**:
  - `modules/home-manager/theme/default.nix`
  - `modules/home-manager/theme/theme-switch.sh` (script template embedded in Nix)
  - `modules/home-manager/theme/theme-picker.sh` (script template embedded in Nix)
  - `~/.config/colorschemes/.current` (runtime, owned by script)
  - `~/.config/colorschemes/.active` (symlink, runtime)
  - `~/.config/colorschemes/.hook` (user-owned, optional)
  - `~/.config/colorschemes/<theme>/meta` (one per theme)
- **Modified files**:
  - `modules/home-manager/swaync/default.nix` — drop inline gruvbox, point at out-of-store config
  - `modules/home-manager/wlogout/default.nix` — same
  - `modules/home-manager/alacritty/default.nix` — add `import` for external colors file (font/opacity stay Nix)
  - `modules/home-manager/darkman/default.nix` — remove `gtk-theme` scripts, keep `hyprsunset`
  - `modules/home-manager/hyprland/default.nix` — add `SUPER+T` keybind for `theme-picker` (or document the user adding it)
  - `hosts/jpporta-nixos/home.nix` — import new theme module
  - `hosts/writter-deck/home.nix` — import new theme module (bonus)
  - `~/.config/hypr/hyprland.conf` (or the lua-generated version) — point hyprland at `colorschemes/.active/hypr/colors.conf` via `source =`
  - `~/.config/waybar/style.css` — switch from `@import "./themes/gruvbox-dark.css"` to `@import` from a symlinked `themes/current.css` (or equivalent)
- **Affected apps** (live-reload behavior changes): swaync (CSS reload instead of restart), wlogout (next-invocation reload, no live signal), waybar (SIGUSR2), kitty (IPC), ghostty (SIGUSR1), alacritty (next-launch), nvim (new windows; optional remote-expr for running session), gtk-4 apps (gsettings flip).
- **No new external dependencies**: rofi, swaync-client, kitty, ghostty, waybar, gsettings, notify-send (libnotify) are already installed.
- **No breaking changes** for users not using the new command — existing gruvbox-dark setup continues to work; the first `theme-switch` after rebuild is a no-op if `.current` already matches.