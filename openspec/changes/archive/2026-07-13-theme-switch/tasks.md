# Tasks: theme-switch

## 1. Per-theme metadata

- [ ] 1.1 Create `~/.config/colorschemes/<theme>/meta` for each of the 11 existing themes with `name=<Display Name>` and `mode=dark` (or `mode=light` for `e-ink` and `noir`).

## 2. Theme module scaffold

- [ ] 2.1 Create `modules/home-manager/theme/default.nix` declaring `options.custom.theme.current` (string, default `"gruvbox-dark"`) and `options.custom.theme.enable` (bool).
- [ ] 2.2 Embed the `theme-switch` shell script in the module via `pkgs.writeShellScriptBin` so it's installed to `~/.local/bin/theme-switch`.
- [ ] 2.3 Embed the `theme-picker` shell script in the module via `pkgs.writeShellScriptBin` so it's installed to `~/.local/bin/theme-picker`.
- [ ] 2.4 Add a systemd user oneshot `theme-apply.service` that runs `theme-switch` (no args) on `graphical-session.target`.
- [ ] 2.5 Add a `home.activation` block that creates `~/.config/colorschemes/.active` (symlink to `custom.theme.current`) and `.current` (text file with the name) if missing.

## 3. theme-switch script

- [ ] 3.1 Implement argument parsing: `<theme-name>` switches; no args reads `.current` and re-applies.
- [ ] 3.2 Validate `<theme-name>` exists under `~/.config/colorschemes/`; print list and exit non-zero otherwise.
- [ ] 3.3 Refuse to proceed if `~/.config/colorschemes/.active` is a non-symlink directory (defensive guard).
- [ ] 3.4 Atomically swap `.active` with `ln -sfn`.
- [ ] 3.5 Write `<theme-name>` to `~/.config/colorschemes/.current`.
- [ ] 3.6 Parse the new theme's `meta` for `name=` and `mode=`.
- [ ] 3.7 Emit `gsettings set org.gnome.desktop.interface color-scheme prefer-{dark,light}` based on `mode=`.
- [ ] 3.8 Update hyprland config: rewrite `~/.config/hypr/hyprland.conf` so its `source =` directive points at `~/.config/colorschemes/.active/hypr/colors.conf`. No signal (hyprland watches).
- [ ] 3.9 Update waybar: atomic symlink swap for `~/.config/waybar/themes/current.css` → `<theme>/waybar/colors.css`, then `pkill -USR2 waybar`.
- [ ] 3.10 Update swaync: atomic swap for `~/.config/swaync/colors.css` → `<theme>/swaync/colors.css`, then `swaync-client --reload-css`.
- [ ] 3.11 Update wlogout: atomic swap for `~/.config/wlogout/style.css` → `<theme>/wlogout/style.css`. No live signal (next-launch reload).
- [ ] 3.12 Update kitty: `kitty @ set-colors --all ~/.config/colorschemes/.active/kitty/colors.conf`.
- [ ] 3.13 Update ghostty: `pkill -SIGUSR1 ghostty`.
- [ ] 3.14 Update alacritty: atomic swap for `~/.config/alacritty/colors.toml` → `<theme>/alacritty/colors.toml`. No live signal (next-launch reload).
- [ ] 3.15 Update nvim: if `$NVIM` is set, `nvim --remote-expr 'lua vim.cmd.colorscheme("<name>")'`. Else no-op.
- [ ] 3.16 If `~/.config/colorschemes/.hook` exists and is executable, run `~/.config/colorschemes/.hook <theme-name>` at the end. Tolerate non-zero exit.
- [ ] 3.17 Notify via `notify-send "Theme: <name>"` if libnotify is available.

## 4. theme-picker script

- [ ] 4.1 List `~/.config/colorschemes/*/meta` files.
- [ ] 4.2 Parse each `meta` for `name=` and `mode=`.
- [ ] 4.3 Pipe the formatted entries (`<name> (<mode>)`) into `rofi -dmenu -p "Theme"`.
- [ ] 4.4 On selection, invoke `theme-switch <selected-theme-name>` and exit with its status.

## 5. Cleanup pass: swaync

- [ ] 5.1 Strip the inline gruvbox color strings from `modules/home-manager/swaync/default.nix` (the `let` block at the top with `background`, `text`, etc.).
- [ ] 5.2 Replace the `style = ''...''` block with `xdg.configFile."swaync/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/swaync/style.css"` (so the file lives in dotfiles and is theme-driven).
- [ ] 5.3 Verify `~/.config/colorschemes/<theme>/swaync/colors.css` exists for all 11 themes; if any are missing, copy from `gruvbox-dark/swaync/colors.css` as a placeholder.

## 6. Cleanup pass: wlogout

- [ ] 6.1 Strip the inline gruvbox color strings from `modules/home-manager/wlogout/default.nix`.
- [ ] 6.2 Replace the `style = ''...''` block with `xdg.configFile."wlogout/style.css".source = config.lib.file.mkOutOfStoreSymlink ...`.
- [ ] 6.3 Verify `~/.config/colorschemes/<theme>/wlogout/colors.css` exists for all 11 themes.

## 7. Cleanup pass: alacritty

- [ ] 7.1 Keep font, opacity, padding, blur in `modules/home-manager/alacritty/default.nix`.
- [ ] 7.2 Add `import = [ "~/.config/alacritty/colors.toml" ]` to `programs.alacritty.settings`.
- [ ] 7.3 Ensure `~/.config/colorschemes/<theme>/alacritty/colors.toml` exists for all 11 themes (or document a one-time port if the existing files are in a different format).
- [ ] 7.4 Add `xdg.configFile."alacritty/colors.toml".source = out-of-store symlink to ~/.config/colorschemes/.active/alacritty/colors.toml` (or document leaving it as a mutable file the script swaps).

## 8. Cleanup pass: darkman

- [ ] 8.1 Remove the `gtk-theme` key from both `services.darkman.darkModeScripts` and `services.darkman.lightModeScripts`.
- [ ] 8.2 Leave the `hyprsunset` key in both modes (still time-of-day driven).
- [ ] 8.3 Add a comment in the module noting that gsettings `color-scheme` is now owned by `theme-switch`.

## 9. Hyprland integration

- [ ] 9.1 In `modules/home-manager/hyprland/default.nix` (or the lua config it writes), ensure `~/.config/hypr/hyprland.conf` `source`s `~/.config/colorschemes/.active/hypr/colors.conf`.
- [ ] 9.2 Strip inline color hex strings (active/inactive border) from the lua config.
- [ ] 9.3 Add the `SUPER+T` keybind to launch `theme-picker` (in the `hl.bind` block).

## 10. Wire into hosts

- [ ] 10.1 Add `../../modules/home-manager/theme` to `imports` in `hosts/jpporta-nixos/home.nix`.
- [ ] 10.2 Set `custom.theme.current = "gruvbox-dark";` (or another default) in the same file.
- [ ] 10.3 (Bonus, deck) Add `../../modules/home-manager/theme` to `imports` in `hosts/writter-deck/home.nix` and set `custom.theme.current`.
- [ ] 10.4 (Bonus, deck) Add a footserver-specific step to `theme-switch` that sends SIGUSR1 to the running footserver, or skips if none.

## 11. Verification

- [ ] 11.1 `home-manager switch` succeeds with no errors after all module changes.
- [ ] 11.2 `~/.config/colorschemes/.active` exists and resolves to the configured theme on first boot.
- [ ] 11.3 `theme-switch catppuccin` (or any other valid theme) swaps `.active`, updates `.current`, and emits each per-app reload signal.
- [ ] 11.4 Each themed app reflects the new palette within ~2 seconds (manual eyeball test).
- [ ] 11.5 `theme-switch does-not-exist` prints the list of valid themes and exits non-zero without modifying `.active`.
- [ ] 11.6 `theme-picker` opens rofi, lists all 11 themes with their mode suffix, and switches on selection.
- [ ] 11.7 `SUPER+T` in Hyprland opens the rofi picker.
- [ ] 11.8 After a logout/login, the desktop matches `.current` (the systemd oneshot ran).
- [ ] 11.9 Drop a placeholder `~/.config/colorschemes/.hook` that logs the theme name; verify it runs after a switch.
- [ ] 11.10 (Deck, if wired) `theme-switch` works on the deck and footserver reloads colors (or relaunches).