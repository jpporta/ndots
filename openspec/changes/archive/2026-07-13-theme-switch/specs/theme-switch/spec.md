# Spec: theme-switch

## ADDED Requirements

### Requirement: Atomic theme swap via a single canonical pointer

The system SHALL provide a single shell command, `theme-switch <theme-name>`, that switches the active theme by atomically rewriting `~/.config/colorschemes/.active` (a symlink) to point at `~/.config/colorschemes/<theme-name>/`.

#### Scenario: Successful switch to a valid theme
- **WHEN** the user runs `theme-switch catppuccin` and `~/.config/colorschemes/catppuccin/` exists
- **THEN** `~/.config/colorschemes/.active` is a symlink whose target resolves to `~/.config/colorschemes/catppuccin`
- **AND** `~/.config/colorschemes/.current` contains the text `catppuccin`

#### Scenario: Switch with an unknown theme name
- **WHEN** the user runs `theme-switch does-not-exist` and the directory does not exist
- **THEN** the command exits non-zero
- **AND** prints a list of valid theme names to stderr
- **AND** does not modify `.active` or `.current`

#### Scenario: Re-applying the current theme is a no-op
- **WHEN** the user runs `theme-switch` with no arguments
- **THEN** the command reads `.current`
- **AND** re-applies every per-app reload step (idempotent)

### Requirement: Per-theme metadata drives picker and gsettings

The system SHALL read each theme's mode (dark or light) and display name from a `meta` file at `~/.config/colorschemes/<theme>/meta`.

#### Scenario: meta file format
- **WHEN** the user runs `theme-switch` against any theme
- **THEN** the script reads `<theme>/meta`
- **AND** parses lines of the form `key=value`
- **AND** uses `mode=dark` or `mode=light` to drive gsettings
- **AND** uses `name=...` for the rofi picker label

#### Scenario: Missing meta file defaults to dark
- **WHEN** a theme directory has no `meta` file
- **THEN** `theme-switch` treats the theme as `mode=dark`
- **AND** uses the directory name as the display name
- **AND** emits a warning to stderr

### Requirement: Per-app live reload covers every themed app on jpporta-nixos

`theme-switch` SHALL emit the appropriate reload signal for each themed app on the host, in an order that places file/data changes before signals.

#### Scenario: Hyprland picks up new colors via file watch
- **WHEN** `theme-switch` rewrites `~/.config/hypr/hyprland.conf` so that its `source =` directive points at `~/.config/colorschemes/.active/hypr/colors.conf`
- **THEN** the running Hyprland instance reloads automatically (it watches its config file)

#### Scenario: waybar picks up new colors via SIGUSR2
- **WHEN** `theme-switch` swaps the waybar CSS symlink and the colors.css file under it
- **THEN** the running waybar instance receives SIGUSR2
- **AND** restyles with the new palette

#### Scenario: swaync picks up new CSS via swaync-client
- **WHEN** `theme-switch` swaps `~/.config/swaync/colors.css`
- **THEN** the script invokes `swaync-client --reload-css`
- **AND** swaync restyles without restart

#### Scenario: kitty picks up new colors via IPC
- **WHEN** `theme-switch` invokes `kitty @ set-colors --all ~/.config/colorschemes/.active/kitty/colors.conf`
- **THEN** every running kitty window restyles without restart

#### Scenario: ghostty picks up new colors via SIGHUP
- **WHEN** `theme-switch` sends SIGHUP to the running ghostty process
- **THEN** ghostty re-reads its config (including the colors block)

#### Scenario: alacritty uses the new palette on next launch
- **WHEN** `theme-switch` swaps the alacritty colors file that `alacritty.toml` imports
- **THEN** running alacritty windows keep their current colors until restarted
- **AND** any newly launched alacritty instance uses the new palette

#### Scenario: nvim recolors in-session when $NVIM is set
- **WHEN** `theme-switch` runs and the user has `$NVIM` set (a running nvim server)
- **THEN** the script invokes `nvim --remote-expr 'lua vim.cmd.colorscheme("<name>")'`
- **AND** the running nvim recolors immediately
- **WHEN** `$NVIM` is not set
- **THEN** the script takes no action for nvim
- **AND** newly launched nvim instances pick up the theme from the symlinked config

#### Scenario: GTK dark/light preference follows theme meta
- **WHEN** `theme-switch` reads `mode=dark` from the new theme's meta
- **THEN** the script invokes `gsettings set org.gnome.desktop.interface color-scheme prefer-dark`
- **WHEN** `mode=light`
- **THEN** the script invokes `gsettings set org.gnome.desktop.interface color-scheme prefer-light`

### Requirement: Rofi-driven theme picker is a thin wrapper over theme-switch

The system SHALL provide a `theme-picker` script that lists available themes (display name + mode) via `rofi -dmenu` and invokes `theme-switch` on the user's selection.

#### Scenario: Picker shows all available themes
- **WHEN** the user runs `theme-picker`
- **THEN** rofi displays one entry per theme directory under `~/.config/colorschemes/`
- **AND** each entry shows the display name from `meta` and a `(dark)` or `(light)` suffix

#### Scenario: Picker invokes theme-switch on selection
- **WHEN** the user selects an entry in rofi
- **THEN** `theme-picker` invokes `theme-switch <selected-theme-name>`
- **AND** exits with the same status code

### Requirement: Boot-time re-apply guarantees a consistent desktop on login

The system SHALL provide a systemd user oneshot service that runs `theme-switch` (no args) on graphical-session start, ensuring `.current` is applied before the user sees the desktop.

#### Scenario: Service runs on graphical-session start
- **WHEN** the user's graphical session (Hyprland on jpporta-nixos; cage on jpporta-deck) starts
- **THEN** `theme-apply.service` runs `theme-switch`
- **AND** the service has no effect if `.current` already matches the running state

#### Scenario: Service does not run before graphical session
- **WHEN** the user's session is not yet at graphical-session.target
- **THEN** `theme-apply.service` is not started
- **AND** waits for the target

### Requirement: Wallpaper hook is user-owned and exec'd at end of switch

`theme-switch` SHALL execute `~/.config/colorschemes/.hook <theme-name>` at the end of every successful switch if that file exists and is executable.

#### Scenario: Hook is invoked after all app reloads
- **WHEN** `theme-switch` finishes the per-app reload block
- **AND** `~/.config/colorschemes/.hook` exists and is executable
- **THEN** the script executes `~/.config/colorschemes/.hook <theme-name>`
- **AND** any non-zero exit status is logged but does not fail the switch

#### Scenario: Missing hook does not fail the switch
- **WHEN** `~/.config/colorschemes/.hook` does not exist or is not executable
- **THEN** the switch still completes successfully

### Requirement: Writer-deck adopts the same mechanism with foot handled at switch time

The same `theme-switch` script SHALL work on jpporta-deck (cage + foot). Foot has no live color reload, so the deck profile SHALL include a foot-specific step that sends `SIGUSR1` (footserver reload) or, as a fallback, restarts the foot server.

#### Scenario: Foot recolors via SIGUSR1 to footserver
- **WHEN** `theme-switch` runs on jpporta-deck
- **THEN** the script sends `SIGUSR1` to the footserver process if running
- **AND** foot reloads its config without losing the running instance

#### Scenario: footserver not running
- **WHEN** `theme-switch` runs on jpporta-deck and no footserver is running
- **THEN** the script takes no action for foot
- **AND** the next foot launch picks up the new theme

### Requirement: First-install migration creates .active from custom.theme.current

On a fresh `home-manager switch` after this change is applied, the theme module SHALL ensure `~/.config/colorschemes/.active` exists and points at the theme named in `custom.theme.current`.

#### Scenario: First install with default theme
- **WHEN** the user applies this change for the first time and `custom.theme.current = "gruvbox-dark"`
- **THEN** the activation creates `~/.config/colorschemes/.active` as a symlink to `~/.config/colorschemes/gruvbox-dark/`
- **AND** writes `gruvbox-dark` to `~/.config/colorschemes/.current`

#### Scenario: Existing wallpapers symlink is left in place during migration
- **WHEN** `~/.config/colorschemes/wallpapers` is already a symlink (legacy)
- **THEN** the migration does not remove it
- **AND** documents in a comment that it is now redundant