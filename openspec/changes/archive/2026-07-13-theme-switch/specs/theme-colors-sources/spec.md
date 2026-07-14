# Spec: theme-colors-sources

## ADDED Requirements

### Requirement: Swaync reads colors from the active theme dir, not from Nix

The swaync Home Manager module SHALL NOT inline color strings. Instead, the module SHALL ensure that `~/.config/swaync/style.css` (and any related color file) is sourced from the active theme dir via an out-of-store symlink to `~/.config/colorschemes/.active/swaync/`.

#### Scenario: swaync config is symlinked to active theme
- **WHEN** the user has applied this change
- **THEN** `~/.config/swaync/colors.css` resolves through `~/.config/colorschemes/.active/swaync/colors.css`
- **AND** the swaync Nix module contains no color hex strings

#### Scenario: Theme switch reflects in swaync without rebuild
- **WHEN** the user runs `theme-switch catppuccin`
- **THEN** swaync restyles via `swaync-client --reload-css` after the symlink swap
- **AND** no `home-manager switch` is required

### Requirement: Wlogout reads colors from the active theme dir, not from Nix

The wlogout Home Manager module SHALL NOT inline color strings. Instead, the module SHALL ensure that `~/.config/wlogout/style.css` is sourced from the active theme dir via an out-of-store symlink to `~/.config/colorschemes/.active/wlogout/`.

#### Scenario: wlogout config is symlinked to active theme
- **WHEN** the user has applied this change
- **THEN** `~/.config/wlogout/style.css` resolves through `~/.config/colorschemes/.active/wlogout/style.css`
- **AND** the wlogout Nix module contains no color hex strings

#### Scenario: Next wlogout invocation uses new colors
- **WHEN** the user runs `theme-switch` and then invokes wlogout
- **THEN** wlogout uses the new palette (no live reload required; wlogout reads its config at launch)

### Requirement: Alacritty imports colors from an external file

The alacritty Home Manager module SHALL configure alacritty to import colors from `~/.config/alacritty/colors.toml` (or equivalent), which is symlinked from the active theme dir.

#### Scenario: alacritty config imports external colors file
- **WHEN** the user has applied this change
- **THEN** `~/.config/alacritty/alacritty.toml` contains an `import = [...]` directive that includes the colors file
- **AND** `~/.config/alacritty/colors.toml` resolves through `~/.config/colorschemes/.active/alacritty/colors.toml`
- **AND** the alacritty Nix module contains no color hex strings (font, opacity, padding remain in Nix)

#### Scenario: Next alacritty launch uses new colors
- **WHEN** the user runs `theme-switch` and then launches a new alacritty window
- **THEN** the new window uses the new palette

### Requirement: Darkman is narrowed to hyprsunset only

The darkman Home Manager module SHALL retain its `hyprsunset` script (sunset/sunrise temperature) and SHALL NOT contain any `gtk-theme` script. Theme-driven dark/light preference is owned by `theme-switch` via gsettings, not by darkman.

#### Scenario: darkman scripts contain no gtk-theme step
- **WHEN** the user has applied this change
- **THEN** `services.darkman.darkModeScripts` does not include a `gtk-theme` key
- **AND** `services.darkman.lightModeScripts` does not include a `gtk-theme` key

#### Scenario: darkman still drives hyprsunset
- **WHEN** the time crosses the darkman sunset/sunrise boundary
- **THEN** the `hyprsunset` script runs and adjusts temperature/gamma
- **AND** gsettings `color-scheme` is NOT modified by darkman

### Requirement: Hyprland sources its colors from the active theme dir

The hyprland Home Manager module (or its user-facing config file) SHALL be configured so that hyprland's color directives come from a `source =` directive pointing at `~/.config/colorschemes/.active/hypr/colors.conf`. The Nix module SHALL NOT inline color hex strings for theme-affected values (active/inactive borders, etc.).

#### Scenario: Hyprland config sources from active theme
- **WHEN** the user has applied this change
- **THEN** `~/.config/hypr/hyprland.conf` (or its lua-generated form) contains `source = ~/.config/colorschemes/.active/hypr/colors.conf`
- **AND** the Hyprland module contains no inline color hex strings for theme-affected directives

#### Scenario: Theme switch reflects in hyprland without rebuild
- **WHEN** the user runs `theme-switch`
- **THEN** hyprland automatically reloads its config (it watches the file)
- **AND** no `home-manager switch` is required

### Requirement: Every themed app reads from a single source of truth

Every app whose colors are themed on this host SHALL read its palette from `~/.config/colorschemes/.active/<app>/...` (directly or via symlink). No themed app SHALL have its colors baked into a Nix-managed file.

#### Scenario: Audit: no color hex strings in themed-app Nix modules
- **WHEN** the user runs `rg -i '#[0-9a-f]{6}' modules/home-manager/{swaync,wlogout,alacritty,hyprland,darkman}` after applying this change
- **THEN** the only matches are in non-theme-affected contexts (e.g., alacritty font color is fine; swaync/wlogout/hyprland theme colors are gone)

#### Scenario: Adding a new theme requires no Nix change
- **WHEN** the user creates a new `~/.config/colorschemes/<new-theme>/` directory with the same per-app subdirs as existing themes, plus a `meta` file
- **THEN** `theme-switch <new-theme>` works without any `home-manager switch`
- **AND** the new theme appears in the rofi picker on next invocation