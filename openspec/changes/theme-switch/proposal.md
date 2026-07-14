# Change: theme-switch

## Why

Today the host has no canonical theme system. Per-app color files live wherever each tool happened to install them, several Nix modules (swaync, wlogout, alacritty, hyprland) bake gruvbox hex strings at build time, and changing the palette means editing files scattered across `~/.config/` plus a `home-manager switch` for the themed modules. There is no "current theme" pointer, no atomic swap, no live propagation contract, and no picker.

The user wants: one command to switch themes, no rebuild, every themed app reflects the new palette, adding a new theme is `mkdir` and dropping files, and the colorscheme tree lives entirely under the user's home directory outside the Nix store so it is freely editable.

The result is a clean slate. No existing colorscheme files are migrated; the curated tree at `~/.config/themes/` is laid down fresh, and all themed Nix modules lose their inline color strings in favor of out-of-store symlinks into the curated tree.

## What Changes

- **New module `modules/home-manager/theme/`** that installs `theme-switch` and `theme-picker` into `~/.local/bin`, adds a `SUPER+T` Hyprland keybind for the picker, declares `options.custom.theme.{enable,current}` for the boot-time default, and runs a `home.activation` block that creates `~/.config/themes/.active` (symlink) on first install. No systemd service.
- **New script `theme-switch`** with two subcommands:
  - `theme-switch <name>` — validates the name, atomically swaps `~/.config/themes/.active`, derives mode from the dir name (or `meta` fallback), flips gsettings `color-scheme`, emits per-app reload signals, and execs `.hook <name>` if present.
  - `theme-switch list` — prints one line per theme (`<name>\t<mode>\t<display_name>`) for pickers to consume.
  - Invalid name: print available themes to stderr, exit 2.
- **New script `theme-picker`** — rofi-driven wrapper that reads `theme-switch list` and invokes `theme-switch <name>` on selection.
- **Convention: per-theme `meta` file** — optional, one per theme, format `key=value` lines. Used only to override mode detection for themes whose dir name doesn't end in `-dark` or `-light`.
- **Convention: out-of-store symlinks** — every themed app's config file is declared in Nix as `xdg.configFile."<app>/<file>".source = mkOutOfStoreSymlink "<path-into-curated-tree>"`. The symlinks are created at `home-manager switch` time; after that, theme-switch only edits the curated tree and apps follow.
- **Hook point `~/.config/themes/.hook <theme-name>`** — if it exists and is executable, `theme-switch` runs it at the end of every successful switch. Non-zero exit is logged but does not fail the switch. Used by the user for wallpaper rotation policy.
- **Cleanup pass on themed Nix modules**: drop inline gruvbox hex strings from `swaync`, `wlogout`, `alacritty`, `hyprland`; replace with `xdg.configFile` symlinks into `~/.config/themes/.active/<app>/`. Reduce `darkman` to only drive `hyprsunset` (drop the `gtk-theme` scripts that theme-switch now owns).
- **nvim colorscheme installation**: Nix declares a fixed set of symlinks under `~/.config/nvim/lua/colors/` pointing into `~/.config/themes/<theme>/nvim/colors.lua`, and adds that dir to nvim's runtimepath. All themes are installed as colorschemes regardless of which one is `.active`. `:colorscheme <theme>` works at any time, including mid-session, including from a Telescope picker. External `theme-switch` pokes the running nvim via `--remote-expr` if `$NVIM` is set, otherwise the next nvim launch picks up `.active`.

No app configuration is being migrated from anywhere. The curated tree is seeded fresh with at least one theme (gruvbox-dark) so the system is usable on first install.

## Capabilities

### New Capabilities

- `theme-switch`: the runtime CLI; defines atomic swap, mode detection, gsettings flip, error UX, `list` subcommand, `.hook` exec.
- `theme-colors-sources`: the convention that themed apps read their colors from `~/.config/themes/.active/<app>/` via Nix-managed out-of-store symlinks; covers the cleanup pass on swaync/wlogout/alacritty/hyprland/darkman and the `xdg.configFile` declarations.
- `theme-app-reloads`: per-app live reload semantics — which apps reload automatically (file watch), which need an explicit signal/command from `theme-switch`, and which only pick up new colors on next launch.
- `theme-nvim-colorschemes`: every theme is installed as a nvim colorscheme under `~/.config/nvim/lua/colors/`, regardless of `.active`. Includes the runtimepath wiring and the external-vs-session override contract.

### Modified Capabilities

None — this is the first theme-related spec on this system.

## Impact

- **New files**:
  - `modules/home-manager/theme/default.nix`
  - `modules/home-manager/theme/theme-switch.sh` (script template embedded in Nix via `writeShellScriptBin`)
  - `modules/home-manager/theme/theme-picker.sh` (script template embedded in Nix via `writeShellScriptBin`)
  - `~/.config/themes/.active` (symlink, runtime, owned by script)
  - `~/.config/themes/.hook` (user-owned, optional)
  - `~/.config/themes/<theme>/...` per-app subdirs (seeded fresh with gruvbox-dark)
  - `~/.config/nvim/lua/colors/<theme>.lua` (Nix-managed symlinks)
- **Modified files**:
  - `modules/home-manager/swaync/default.nix` — drop inline colors, point at `.active/swaync/colors.css`
  - `modules/home-manager/wlogout/default.nix` — same
  - `modules/home-manager/alacritty/default.nix` — add `import = [~/.config/alacritty/colors.toml]`, declare the colors.toml symlink
  - `modules/home-manager/darkman/default.nix` — remove `gtk-theme` scripts, keep `hyprsunset`
  - `modules/home-manager/hyprland/default.nix` — replace inline border colors with `source = ~/.config/themes/.active/hypr/colors.conf`; add `SUPER+T` keybind for `theme-picker`
  - `modules/home-manager/nvim/default.nix` — declare the `~/.config/nvim/lua/colors/` symlinks (one per theme) and the runtimepath wiring
  - `hosts/jpporta-nixos/home.nix` — import the new theme module; set `custom.theme.current = "gruvbox-dark"`
  - `hosts/writter-deck/home.nix` — import the new theme module; set `custom.theme.current = "gruvbox-dark"`; same nvim colorscheme wiring
- **Affected apps** (live-reload behavior):
  - Live reload (file watch): hyprland, gtk-3, gtk-4
  - Live reload (signal/cmd): kitty (`@ set-colors`), ghostty (`SIGHUP`), waybar (`SIGUSR2`), swaync (`swaync-client --reload-css`), nvim (`--remote-expr`)
  - Next-launch only: wlogout, alacritty, bat, fastfetch, oh-my-posh, foot (deck)
- **No new external dependencies**: rofi, swaync-client, kitty, ghostty, waybar, gsettings, notify-send are already installed.
- **No breaking changes**: the system boots into gruvbox-dark by default; first switch is a normal user action.