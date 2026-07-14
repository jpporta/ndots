# Spec: theme-switch

## ADDED Requirements

### Requirement: Atomic theme swap via a single canonical pointer

The system SHALL provide a shell command, `theme-switch <theme-name>`, that switches the active theme by atomically rewriting `~/.config/themes/.active` (a symlink) to point at `~/.config/themes/<theme-name>/`.

#### Scenario: Successful switch to a valid theme
- **WHEN** the user runs `theme-switch gruvbox-dark` and `~/.config/themes/gruvbox-dark/` exists
- **THEN** `~/.config/themes/.active` is a symlink whose target resolves to `~/.config/themes/gruvbox-dark`

#### Scenario: Switch with an unknown theme name
- **WHEN** the user runs `theme-switch does-not-exist` and the directory does not exist
- **THEN** the command exits with code 2
- **AND** prints a list of valid theme names to stderr
- **AND** does not modify `.active`

### Requirement: Theme listing for picker integration

The system SHALL provide a `theme-switch list` subcommand that prints one line per available theme in the format `<name>\t<mode>\t<display_name>`.

#### Scenario: list prints all available themes
- **WHEN** the user runs `theme-switch list`
- **THEN** the command prints one line per directory under `~/.config/themes/` (excluding `.active` and `.hook`)
- **AND** each line contains the directory name, the resolved mode, and the display name

#### Scenario: list output is script-friendly
- **WHEN** any picker (rofi, fzf, custom TUI) consumes `theme-switch list`
- **THEN** the output is stable, newline-separated, and tab-separated within each line
- **AND** the picker can extract `<name>` as the first field and invoke `theme-switch <name>` on selection

### Requirement: Mode detection from dir name with optional meta fallback

The system SHALL determine each theme's mode (dark or light) by checking the directory name suffix first, then a `meta` file, then defaulting to dark.

#### Scenario: Suffix convention resolves mode
- **WHEN** a theme directory is named `gruvbox-dark` or `rose-pine-light`
- **THEN** `theme-switch` treats the theme as dark or light respectively without reading any file

#### Scenario: meta file overrides dir-name convention
- **WHEN** a theme directory is named `cobalt2` (no suffix) and contains a `meta` file with `mode=dark`
- **THEN** `theme-switch` reads `mode=dark` from the `meta` file
- **AND** treats the theme as dark

#### Scenario: Missing meta defaults to dark
- **WHEN** a theme directory has no suffix and no `meta` file
- **THEN** `theme-switch` treats the theme as `mode=dark`
- **AND** emits a warning to stderr

### Requirement: gsettings color-scheme follows theme mode

`theme-switch` SHALL invoke `gsettings set org.gnome.desktop.interface color-scheme prefer-{dark,light}` based on the resolved mode of the target theme.

#### Scenario: Dark theme flips gsettings to prefer-dark
- **WHEN** `theme-switch` resolves the target theme's mode to `dark`
- **THEN** the script invokes `gsettings set org.gnome.desktop.interface color-scheme prefer-dark`

#### Scenario: Light theme flips gsettings to prefer-light
- **WHEN** `theme-switch` resolves the target theme's mode to `light`
- **THEN** the script invokes `gsettings set org.gnome.desktop.interface color-scheme prefer-light`

### Requirement: Wallpaper hook is user-owned and exec'd at end of switch

`theme-switch` SHALL execute `~/.config/themes/.hook <theme-name>` at the end of every successful switch if that file exists and is executable.

#### Scenario: Hook is invoked after all app reloads
- **WHEN** `theme-switch` finishes the per-app reload block
- **AND** `~/.config/themes/.hook` exists and is executable
- **THEN** the script executes `~/.config/themes/.hook <theme-name>`
- **AND** any non-zero exit status is logged but does not fail the switch

#### Scenario: Missing hook does not fail the switch
- **WHEN** `~/.config/themes/.hook` does not exist or is not executable
- **THEN** the switch still completes successfully

### Requirement: Defensive guard against .active as a real directory

`theme-switch` SHALL refuse to proceed if `~/.config/themes/.active` is a non-symlink directory.

#### Scenario: .active is a directory (corruption)
- **WHEN** `~/.config/themes/.active` exists as a real directory (not a symlink)
- **THEN** `theme-switch` prints an error explaining the corruption and exits non-zero
- **AND** does not modify `.active`

### Requirement: First-install creates .active from custom.theme.current

On a fresh `home-manager switch` after this change is applied, the theme module SHALL ensure `~/.config/themes/.active` exists and points at the theme named in `custom.theme.current`.

#### Scenario: First install with default theme
- **WHEN** the user applies this change for the first time and `custom.theme.current = "gruvbox-dark"`
- **THEN** the activation creates `~/.config/themes/.active` as a symlink to `~/.config/themes/gruvbox-dark/`