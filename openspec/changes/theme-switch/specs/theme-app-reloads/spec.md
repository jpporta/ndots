# Spec: theme-app-reloads

## ADDED Requirements

### Requirement: theme-switch emits the appropriate reload signal per app

`theme-switch` SHALL emit, for each themed app, exactly the reload mechanism that app natively supports — no more, no less.

### Per-app reload mechanisms

#### Scenario: Hyprland reloads via file watch
- **WHEN** `theme-switch` swaps `.active` and the new `~/.config/themes/.active/hypr/colors.conf` is in place
- **THEN** the running Hyprland instance reloads automatically (it watches its config file)
- **AND** `theme-switch` does not send any explicit reload command to hyprland

#### Scenario: waybar reloads via SIGUSR2
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** the script invokes `pkill -SIGUSR2 waybar`
- **AND** waybar restyles with the new palette

#### Scenario: swaync reloads via swaync-client
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** the script invokes `swaync-client --reload-css`
- **AND** swaync restyles without restart

#### Scenario: kitty reloads via IPC
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** the script invokes `kitty @ set-colors --all ~/.config/themes/.active/kitty/colors.conf`
- **AND** every running kitty window restyles without restart

#### Scenario: ghostty reloads via SIGHUP
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** the script invokes `pkill -SIGHUP ghostty`
- **AND** ghostty re-reads its config (including the colors block)

#### Scenario: alacritty uses the new palette on next launch
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** running alacritty windows keep their current colors until restarted
- **AND** any newly launched alacritty instance uses the new palette

#### Scenario: wlogout uses the new palette on next launch
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** running wlogout instances keep their current colors until restarted
- **AND** any newly launched wlogout instance uses the new palette

#### Scenario: bat uses the new palette on next invocation
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** the script takes no action for bat
- **AND** the next `bat` invocation uses the new palette from `.active/bat/colors.tmTheme`

#### Scenario: fastfetch uses the new palette on next invocation
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** the script takes no action for fastfetch
- **AND** the next fastfetch invocation uses the new palette from `.active/fastfetch/colors.conf`

#### Scenario: oh-my-posh uses the new palette on next shell
- **WHEN** `theme-switch` finishes the `.active` swap
- **THEN** the script takes no action for oh-my-posh
- **AND** the next shell that sources oh-my-posh uses the new palette from `.active/oh-my-posh.omp.json`

#### Scenario: nvim recolors in-session when $NVIM is set
- **WHEN** `theme-switch` runs and the user has `$NVIM` set (a running nvim server)
- **THEN** the script invokes `nvim --remote-expr 'lua vim.cmd.colorscheme("<name>")'`
- **AND** the running nvim recolors immediately

#### Scenario: nvim running but $NVIM not set
- **WHEN** `theme-switch` runs and `$NVIM` is not set
- **THEN** the script does not invoke nvim
- **AND** newly launched nvim instances pick up `.active`'s theme on init

#### Scenario: foot on the deck tries SIGHUP first, falls back to SIGTERM
- **WHEN** `theme-switch` runs on the deck (jpporta-deck)
- **THEN** the script first invokes `pkill -SIGHUP foot`
- **AND** if footserver is unresponsive after a short grace period, falls back to `pkill -TERM foot`
- **AND** the cage autostart relaunches foot with the new colors

### Requirement: Reload ordering places data before signals

`theme-switch` SHALL swap the `.active` symlink and write any data files before sending reload signals.

#### Scenario: Signal sent after data is in place
- **WHEN** `theme-switch` runs
- **THEN** step 1 is the `.active` symlink swap
- **AND** step 2 is any per-app data rewrites
- **AND** steps 3+ are the reload signals in a defined order

### Requirement: Reload failures are non-fatal

`theme-switch` SHALL tolerate individual app reload failures — one failing app does not prevent the rest of the switch from completing.

#### Scenario: swaync not running
- **WHEN** `theme-switch` invokes `swaync-client --reload-css` and swaync is not running
- **THEN** the failure is logged to stderr
- **AND** the switch continues to the next app

#### Scenario: kitty not running
- **WHEN** `theme-switch` invokes `kitty @ set-colors` and no kitty server is reachable
- **THEN** the failure is logged to stderr
- **AND** the switch continues