# Spec: theme-colors-sources

## ADDED Requirements

### Requirement: Every themed app reads colors from the active theme dir, not from Nix

Every app whose colors are themed on this system SHALL read its palette from `~/.config/themes/.active/<app>/...` (directly or via a Nix-managed out-of-store symlink at the app's own config path).

#### Scenario: App config symlinks into active theme
- **WHEN** the user has applied this change
- **THEN** for each themed app, the Nix-managed config file at `~/.config/<app>/<config-file>` is a symlink whose target resolves to `~/.config/themes/.active/<app>/<config-file>`
- **AND** the symlinks are created at `home-manager switch` time
- **AND** after install, theme-switch only edits the curated tree — Nix is not touched again

#### Scenario: No themed app has colors baked into a Nix file
- **WHEN** the user runs `rg -i '#[0-9a-f]{6}' modules/home-manager/{swaync,wlogout,alacritty,hyprland,darkman}` after applying this change
- **THEN** no matches exist in theme-affected contexts

### Requirement: Swaync reads colors from the active theme dir, not from Nix

The swaync Home Manager module SHALL NOT inline color strings. Instead, the module SHALL declare `~/.config/swaync/colors.css` as an out-of-store symlink to `~/.config/themes/.active/swaync/colors.css`.

#### Scenario: swaync config is symlinked to active theme
- **WHEN** the user has applied this change
- **THEN** `~/.config/swaync/colors.css` resolves through `~/.config/themes/.active/swaync/colors.css`
- **AND** the swaync Nix module contains no color hex strings

#### Scenario: Theme switch reflects in swaync without rebuild
- **WHEN** the user runs `theme-switch catppuccin-mocha`
- **THEN** swaync restyles via `swaync-client --reload-css` after the `.active` swap
- **AND** no `home-manager switch` is required

### Requirement: Wlogout reads colors from the active theme dir, not from Nix

The wlogout Home Manager module SHALL NOT inline color strings. Instead, the module SHALL declare `~/.config/wlogout/style.css` as an out-of-store symlink to `~/.config/themes/.active/wlogout/style.css`.

#### Scenario: wlogout config is symlinked to active theme
- **WHEN** the user has applied this change
- **THEN** `~/.config/wlogout/style.css` resolves through `~/.config/themes/.active/wlogout/style.css`
- **AND** the wlogout Nix module contains no color hex strings

#### Scenario: Next wlogout invocation uses new colors
- **WHEN** the user runs `theme-switch` and then invokes wlogout
- **THEN** wlogout uses the new palette (no live reload required; wlogout reads its config at launch)

### Requirement: Alacritty imports colors from an external file

The alacritty Home Manager module SHALL configure alacritty to import colors from `~/.config/alacritty/colors.toml`, which is an out-of-store symlink to `~/.config/themes/.active/alacritty/colors.toml`.

#### Scenario: alacritty config imports external colors file
- **WHEN** the user has applied this change
- **THEN** `~/.config/alacritty/alacritty.toml` contains an `import = [...]` directive that includes the colors file
- **AND** `~/.config/alacritty/colors.toml` resolves through `~/.config/themes/.active/alacritty/colors.toml`
- **AND** the alacritty Nix module contains no color hex strings (font, opacity, padding remain in Nix)

#### Scenario: Next alacritty launch uses new colors
- **WHEN** the user runs `theme-switch` and then launches a new alacritty window
- **THEN** the new window uses the new palette

### Requirement: Hyprland sources its colors from the active theme dir

The hyprland Home Manager module SHALL configure hyprland's config to `source = ~/.config/themes/.active/hypr/colors.conf` for theme-affected directives (active/inactive borders).

#### Scenario: Hyprland config sources from active theme
- **WHEN** the user has applied this change
- **THEN** `~/.config/hypr/hyprland.lua` (or the generated `hyprland.conf`) contains `source = ~/.config/themes/.active/hypr/colors.conf`
- **AND** the Hyprland module contains no inline color hex strings for theme-affected directives

#### Scenario: Theme switch reflects in hyprland without rebuild
- **WHEN** the user runs `theme-switch`
- **THEN** hyprland automatically reloads its config (it watches the file)
- **AND** no `home-manager switch` is required

### Requirement: Darkman is narrowed to hyprsunset only

The darkman Home Manager module SHALL retain its `hyprsunset` scripts (sunset/sunrise temperature) and SHALL NOT contain any `gtk-theme` script. Theme-driven dark/light preference is owned by `theme-switch` via gsettings.

#### Scenario: darkman scripts contain no gtk-theme step
- **WHEN** the user has applied this change
- **THEN** `services.darkman.darkModeScripts` does not include a `gtk-theme` key
- **AND** `services.darkman.lightModeScripts` does not include a `gtk-theme` key

#### Scenario: darkman still drives hyprsunset
- **WHEN** the time crosses the darkman sunset/sunrise boundary
- **THEN** the `hyprsunset` script runs and adjusts temperature/gamma
- **AND** gsettings `color-scheme` is NOT modified by darkman

### Requirement: Adding a new theme requires no Nix change

The system SHALL allow adding a new theme by creating a new directory under `~/.config/themes/` with the standard per-app subdir layout, without any `home-manager switch`.

#### Scenario: Adding a new theme by hand
- **WHEN** the user creates `~/.config/themes/<new-theme>/` with `hypr/`, `kitty/`, `waybar/`, `nvim/colors.lua`, and other per-app subdirs as needed
- **THEN** `theme-switch <new-theme>` works without any `home-manager switch`
- **AND** the new theme appears in `theme-switch list` and `theme-picker` on next invocation