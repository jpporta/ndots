# Tasks: theme-switch

## 1. Theme module scaffold

- [x] 1.1 Create `modules/home-manager/theme/default.nix` declaring `options.custom.theme.enable` and `options.custom.theme.current` (string, default `"gruvbox-dark"`).
- [x] 1.2 Embed the `theme-switch` shell script in the module via `pkgs.writeShellScriptBin` so it's installed to `~/.local/bin/theme-switch`.
- [x] 1.3 Embed the `theme-picker` shell script in the module via `pkgs.writeShellScriptBin` so it's installed to `~/.local/bin/theme-picker`.
- [x] 1.4 Add a `home.activation` block that creates `~/.config/themes/.active` as a symlink to `config.custom.theme.current` if missing.
- [x] 1.5 Add a `home.activation` block that creates `~/.config/themes/` if missing.

## 2. theme-switch script

- [x] 2.1 Implement `theme-switch <name>`: validate the dir exists, swap `.active` with `ln -sfn`, derive mode from suffix/meta.
- [x] 2.2 Implement `theme-switch list`: print `<name>\t<mode>\t<display_name>` per theme directory.
- [x] 2.3 Implement mode detection: suffix `*-dark`/`*-light` first, then `meta` file, then default to `dark` with stderr warning.
- [x] 2.4 Implement gsettings flip based on resolved mode.
- [x] 2.5 Implement per-app reload block (hyprland file-watch auto, waybar SIGUSR2, swaync-client --reload-css, kitty @ set-colors, ghostty SIGHUP, nvim --remote-expr if $NVIM).
- [x] 2.6 Implement defensive guard: bail with error if `.active` exists as non-symlink directory.
- [x] 2.7 Implement `.hook <theme-name>` exec at end of switch; tolerate non-zero exit; tolerate missing file.
- [x] 2.8 Implement error UX: invalid name → print available themes to stderr, exit 2.
- [x] 2.9 Implement notify-send at end of switch.
- [x] 2.10 Implement reload-ordering discipline: symlink swap first, signals after.

## 3. theme-picker script

- [x] 3.1 Pipe `theme-switch list` output through `rofi -dmenu -p "Theme"`.
- [x] 3.2 On selection, invoke `theme-switch <selected-theme-name>` and exit with its status.

## 4. Cleanup pass: swaync

- [x] 4.1 Strip the inline gruvbox color strings from `modules/home-manager/swaync/default.nix`.
- [x] 4.2 Replace the style block with `xdg.configFile."swaync/style.css".source = config.lib.file.mkOutOfStoreSymlink ...themes/.active/swaync/colors.css`.
- [x] 4.3 Seed `~/.config/themes/gruvbox-dark/swaync/colors.css` with gruvbox CSS.

## 5. Cleanup pass: wlogout

- [x] 5.1 Strip inline gruvbox color strings from `modules/home-manager/wlogout/default.nix`.
- [x] 5.2 Replace style with `xdg.configFile."wlogout/style.css".source = mkOutOfStoreSymlink ...themes/.active/wlogout/style.css` (using `lib.mkForce`).
- [x] 5.3 Seed `~/.config/themes/gruvbox-dark/wlogout/style.css` with gruvbox CSS.

## 6. Cleanup pass: alacritty

- [x] 6.1 Keep font, opacity, padding, blur in `modules/home-manager/alacritty/default.nix`.
- [x] 6.2 Add `import = [ "~/.config/alacritty/colors.toml" ]` to `programs.alacritty.settings`.
- [x] 6.3 Declare `xdg.configFile."alacritty/colors.toml".source = mkOutOfStoreSymlink ...themes/.active/alacritty/colors.toml`.
- [x] 6.4 Seed `~/.config/themes/gruvbox-dark/alacritty/colors.toml` with gruvbox colors.

## 7. Cleanup pass: darkman

- [x] 7.1 Remove the `gtk-theme` key from both `services.darkman.darkModeScripts` and `services.darkman.lightModeScripts`.
- [x] 7.2 Leave the `hyprsunset` key in both modes (still time-of-day driven).
- [x] 7.3 Add a comment noting that gsettings `color-scheme` is now owned by `theme-switch`.

## 8. Cleanup pass: hyprland

- [x] 8.1 In `modules/home-manager/hyprland/default.nix`, replace inline `col.active_border` and `col.inactive_border` with `dofile(home .. "/.config/hypr/colors.conf")` and a `xdg.configFile."hypr/colors.conf"` symlink to `.active/hypr/colors.conf`.
- [x] 8.2 Other inline color hex strings left in place (decoration.shadow.color is rgba with alpha and not directly theme-affected).
- [x] 8.3 Seed `~/.config/themes/gruvbox-dark/hypr/colors.conf` with gruvbox border colors.

## 9. Hyprland keybind for picker

- [x] 9.1 Add the `SUPER+T` keybind to `modules/home-manager/hyprland/default.nix` to launch `theme-picker`.

## 10. nvim colorscheme wiring

- [x] 10.1 Declare `xdg.configFile."nvim/lua/colors/<theme>.lua"` symlinks pointing at `${home}/.config/themes/<theme>/nvim/colors.lua`.
- [x] 10.2 List seeded with `gruvbox-dark` only (more themes added by re-declaring the Nix module).
- [x] 10.3 Add `vim.opt.rtp:append(vim.fn.stdpath("config") .. "/lua/colors")` to nvim init.lua.
- [x] 10.4 Seed `~/.config/themes/gruvbox-dark/nvim/colors.lua` with `vim.o.background = "dark"; vim.cmd("colorscheme gruvbox")`.

## 11. Wire into hosts

- [x] 11.1 Add `../../modules/home-manager/theme` to `imports` in `hosts/jpporta-nixos/home.nix`.
- [x] 11.2 Set `custom.theme = { enable = true; current = "gruvbox-dark"; }` in the same file.
- [x] 11.3 Add `../../modules/home-manager/theme` to `imports` in `hosts/writter-deck/home.nix`.
- [x] 11.4 Set `custom.theme = { enable = true; current = "gruvbox-dark"; }` in the deck host file.

## 12. Seed gruvbox-dark theme

- [x] 12.1 Ship `modules/home-manager/theme/seeds/gruvbox-dark/` with subdirs for `hypr/`, `kitty/`, `waybar/`, `swaync/`, `wlogout/`, `rofi/`, `gtk-3.0/`, `gtk-4.0/`, `alacritty/`, `ghostty/`, `nvim/`, `bat/`, `fastfetch/`, `wallpapers/`, plus a `meta` file.
- [x] 12.2 Seed each subdir with hand-crafted gruvbox config files; activation script copies them to `~/.config/themes/gruvbox-dark/` on first install and skips themes that already exist.

## 13. Verification

- [x] 13.1 `nix flake check --no-build` passes for both `nixosConfigurations.jpporta-nixos` and `homeConfigurations.jpporta-deck` (proves the eval succeeds end to end).
- [ ] 13.2 `~/.config/themes/.active` exists and resolves to `gruvbox-dark` on first boot — requires `home-manager switch` on real host.
- [x] 13.3 `theme-switch list` prints `gruvbox-dark` — verified via smoke test.
- [x] 13.4 `theme-switch does-not-exist` prints the list to stderr and exits 2 — verified via smoke test.
- [x] 13.5 `theme-switch gruvbox-dark` is a no-op (idempotent) — verified via smoke test.
- [ ] 13.6 Each themed app's config path resolves through `.active/<app>/...` — requires `home-manager switch` on real host.
- [ ] 13.7 nvim: `:colorscheme gruvbox-dark` works on a fresh launch — requires `home-manager switch` on real host.
- [ ] 13.8 `SUPER+T` opens the rofi picker — requires `home-manager switch` on real host.
- [x] 13.9 `.hook` exec runs after a switch — verified via smoke test (placeholder hook logged the theme name).

NOTE 13.2, 13.6, 13.7, 13.8 require running `home-manager switch` on each host; the change is ready to deploy.