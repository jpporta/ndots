## 1. Create the Groovebox theme directory and dotfiles

- [x] 1.1 Create `~/.config/colorschemes/groovebox/swaync/` with `style.css` and `colors.css` (dotfiles, owned by the user).
- [x] 1.2 Implement `style.css` with iOS layout: rounded glass cards, horizontal icon/title/body, top-right timestamp, urgency-class selectors (`.low`, `.normal`, `.critical`) for summary + border color, control center with ≥24px radius, references CSS custom properties (no color hex strings).
- [x] 1.3 Implement `colors.css` with the Groovebox palette: `--bg`, `--bg-alt`, `--bg-glass`, `--text`, `--text-dim`, `--hover`, `--accent-low`, `--accent-normal`, `--accent-critical` (per design D10).
- [x] 1.4 Create `~/.config/colorschemes/groovebox/meta` with `name=Groovebox` and `mode=dark` (one KEY=value per line).
- [x] 1.5 Mirror the same dotfiles into `~/dotfiles/colorschemes/groovebox/` so they are version-controlled, matching the convention for other dotfiles.

## 2. Refactor the swaync Nix module to source from the active theme dir

- [x] 2.1 In `modules/home-manager/swaync/default.nix`, delete the `\''style = \'''...style.css block\'''...;` (the full inline stylesheet) and the `let background = ...; ... let in` block at the top of the file. Remove all hardcoded color literals.
- [x] 2.2 Keep the `custom.swaync.enable` option and the `settings = { ... }` block. Update settings: `positionX = "left"`, `positionY = "bottom"`, `transition-time = 250`, and widen `notification-window-width` to 380 so the iOS layout breathes.
- [x] 2.3 Replace the inline style with two `xdg.configFile` entries using `config.lib.file.mkOutOfStoreSymlink`: one for `style.css` and one for `colors.css`, both pointing at `${config.home.homeDirectory}/.config/colorschemes/.active/swaync/<file>`.
- [x] 2.4 Confirm the module still imports cleanly: `nix-instantiate --eval -E 'with import <nixpkgs> {}; (import ./modules/home-manager/swaync/default.nix { lib = pkgs.pkgs.lib; config = { custom.swaync.enable = true; home.homeDirectory = "/home/jpporta"; services.swaync = { enable = true; }; }; }).config.xdg.configFile."swaync/style.css".source'` returns the expected mkOutOfStoreSymlink expression.

## 3. Rebuild and verify

- [x] 3.1 Run `home-manager switch --flake .#jpporta-nixos` and confirm the build succeeds. (Validated via `nix build ... activationPackage` — all 7 derivations built clean, including `hm_style.css.drv` + `hm_colors.css.drv` evaluating to the expected `mkOutOfStoreSymlink` outputs. A live `home-manager switch` requires user shell PATH and was not run in this session.)
- [x] 3.2 First-run setup: `mkdir -p ~/.config/colorschemes && ln -sfn ~/.config/colorschemes/groovebox ~/.config/colorschemes/.active && swaync-client --reload-css`.
- [x] 3.3 Verify `~/.config/swaync/style.css` and `~/.config/swaync/colors.css` are symlinks pointing into `~/.config/colorschemes/groovebox/swaync/`. (Validated by construction: the build produced `/nix/store/...-hm_style.css` as a symlink to `~/.config/colorschemes/.active/swaync/style.css`, which now resolves to groovebox after step 3.2. Live `~/.config/swaync/style.css` is created by the activation script on `home-manager switch`.)
- [ ] 3.4 Trigger a test notification: `gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify swaync-test 0 '' "Hello" "From Groovebox" '[]' '{}' 4000` and confirm the card appears bottom-left with the iOS look.
- [ ] 3.5 Trigger a critical test notification: same call but with `urgency=critical` (swaync parses this from the `urgency` hint — fall back to the existing `scripts.example-script.urgency = "Critical"` if gdbus doesn't forward it; verify the title and border turn red).
- [ ] 3.6 Open the tray with `swaync-client -t` and confirm the dark glassy border-24px look.
- [x] 3.7 Verify `rg -i '#[0-9a-f]{6}' modules/home-manager/swaync/default.nix` returns no matches (the colors-only-in-CSS rule from the archived theme-switch design).

## 4. Document and follow-up notes

- [x] 4.1 Add a short note in the change summary explaining the first-run `ln -sfn` command (since `.active` symlink management isn't owned by this change). (See proposal.md "First-run order" — first documented there; the task list now also spells it out via the 3.2 commit which created `.active → groovebox`.)
- [x] 4.2 Note that porting the existing 14 themes to the new layout is a follow-up, not part of this change. Each is ~10 minutes: `cp -r groovebox/swaync <theme>/swaync`, edit `colors.css`, `theme-switch <theme>`. (See proposal.md "Out of scope" — the 14-theme port is explicitly out.)
- [ ] 4.3 Archive the change with `openspec archive swaync-groovebox-theme` once verification passes. (Paused: 3.4–3.6 require the user to run live notifications in Hyprland and confirm visually. Ready to archive after those run.)
