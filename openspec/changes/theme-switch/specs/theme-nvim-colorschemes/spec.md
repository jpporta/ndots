# Spec: theme-nvim-colorschemes

## ADDED Requirements

### Requirement: All themes are installed as nvim colorschemes

The system SHALL install every theme under `~/.config/themes/` as a nvim colorscheme, regardless of which theme is currently `.active`.

#### Scenario: Each theme has a colorscheme file
- **WHEN** the user has applied this change
- **THEN** for every theme directory under `~/.config/themes/`, a corresponding file exists at `~/.config/nvim/lua/colors/<theme>.lua`
- **AND** each file is a symlink whose target resolves to `~/.config/themes/<theme>/nvim/colors.lua`

#### Scenario: :colorscheme works for any theme
- **WHEN** the user runs `:colorscheme gruvbox-dark` inside nvim
- **THEN** nvim applies the gruvbox-dark colorscheme
- **AND** this works whether or not `.active` points at gruvbox-dark

#### Scenario: All themes visible to lazy.nvim / Telescope
- **WHEN** the user opens a colorscheme picker (lazy.nvim, Telescope, etc.)
- **THEN** every theme under `~/.config/themes/` appears in the list

### Requirement: nvim runtimepath includes the colors dir

The nvim Home Manager module SHALL add `~/.config/nvim/lua/colors` to nvim's runtimepath so the installed colorschemes are discoverable.

#### Scenario: colors dir is on runtimepath
- **WHEN** the user runs `:set runtimepath?` inside nvim
- **THEN** the output includes `~/.config/nvim/lua/colors`

### Requirement: Session-local override via :colorscheme does not touch .active

When the user runs `:colorscheme <theme>` inside nvim, the change is session-local and does not modify `~/.config/themes/.active`.

#### Scenario: In-nvim override is reverted on restart
- **WHEN** the user runs `:colorscheme gruvbox-dark` inside nvim while `.active` points at `rose-pine`
- **THEN** the current nvim session shows gruvbox-dark
- **AND** `~/.config/themes/.active` still resolves to `~/.config/themes/rose-pine`
- **AND** closing and reopening nvim applies rose-pine (the `.active` theme)

### Requirement: External theme-switch recolors running nvim

When `theme-switch` runs externally and a nvim server is reachable via `$NVIM`, the running nvim recolors to the new theme.

#### Scenario: External switch with $NVIM set
- **WHEN** the user runs `theme-switch catppuccin-mocha` from the shell
- **AND** `$NVIM` is set to a running nvim server socket
- **THEN** `theme-switch` invokes `nvim --remote-expr 'lua vim.cmd.colorscheme("catppuccin-mocha")'`
- **AND** the running nvim recolors immediately

#### Scenario: External switch without $NVIM
- **WHEN** the user runs `theme-switch catppuccin-mocha` from the shell
- **AND** `$NVIM` is not set
- **THEN** `theme-switch` does not invoke nvim
- **AND** the next nvim launch picks up the new `.active` theme on init

### Requirement: theme-switch swaps ALL themes' nvim files on switch

When `theme-switch` runs, the symlink at `~/.config/nvim/lua/colors/<theme>.lua` for each theme continues to point at `~/.config/themes/<theme>/nvim/colors.lua` — `theme-switch` does not need to touch these symlinks, since they point at per-theme paths, not at `.active`.

#### Scenario: External switch does not alter nvim-colors symlinks
- **WHEN** the user runs `theme-switch catppuccin-mocha`
- **THEN** `~/.config/nvim/lua/colors/gruvbox-dark.lua` still resolves to `~/.config/themes/gruvbox-dark/nvim/colors.lua`
- **AND** `theme-switch` only swaps the `.active` symlink (which affects other apps, not nvim's per-theme symlinks)

### Requirement: Adding a new theme makes it available in nvim

When the user adds a new theme directory at `~/.config/themes/<new-theme>/` with a `nvim/colors.lua` file, that theme becomes available as `:colorscheme <new-theme>` without any Nix rebuild.

#### Scenario: New theme appears in nvim after manual add
- **WHEN** the user creates `~/.config/themes/<new-theme>/nvim/colors.lua`
- **THEN** `:colorscheme <new-theme>` works on next nvim launch
- **AND** no `home-manager switch` is required

#### Scenario: New theme without nvim file
- **WHEN** the user creates `~/.config/themes/<new-theme>/` without a `nvim/colors.lua` file
- **THEN** `theme-switch <new-theme>` still works for other apps
- **AND** the theme is NOT available as a nvim colorscheme (`:colorscheme <new-theme>` fails)
- **AND** `theme-switch` emits a warning to stderr noting the missing nvim file