## Context

The user runs jpporta-nixos (Hyprland on Wayland) and jpporta-deck (a OrangePi running cage + foot as a "writer deck"). They maintain 11 hand-curated palettes under `~/.config/colorschemes/<theme>/` with per-app config files (hyprland, waybar, swaync, wlogout, kitty, ghostty, nvim, rofi, gtk-4.0, plus a `wallpapers/` directory). Currently:

- **Hyprland, awww, waybar, kitty, ghostty** are reachable from the themed dirs (with manual edits).
- **swaync, wlogout, alacritty** have their colors hardcoded as Nix strings in `modules/home-manager/*/default.nix`, so swapping themes requires `home-manager switch`.
- **darkman** runs a dark/light switch (geolocation-based) that flips GTK theme and hyprsunset temperature — its `gtk-theme` step overlaps with what theme-switch will own.
- **No canonical "current theme" pointer** exists. The `~/.config/colorschemes/wallpapers` symlink is a one-off pointing at gruvbox-dark.
- **No live propagation contract** — every themed app needs its own reload mechanism (file watch, IPC, signal, or restart-on-next-launch).

The user wants: one command to swap themes, no rebuild, every themed app reflects the new palette, dark/light mode is owned by the theme (not by darkman), darkman keeps doing what it's good at (time-of-day temperature), and the writer deck can adopt the same workflow.

Constraints discovered during exploration:

- All per-theme assets must remain editable in `~/.config/colorschemes/<theme>/` without rebuild — this is the precedent set by the `awww` module (reads wallpaper dir live, never copies to store).
- Theme colors live in dotfiles, not Nix. Anything baked into Nix is a second source of truth and must be removed.
- The `.active` symlink pattern is preferred over a sentinel file because it's atomic (`ln -sfn`) and serves as the directory apps follow directly.
- Darkman should keep its sunset/sunrise logic for `hyprsunset`, but stop touching GTK (theme owns that).

## Goals / Non-Goals

**Goals:**

- Atomic theme swap with one shell command (`theme-switch <name>`) — no Nix rebuild, no per-app scripting by the user.
- Single canonical pointer (`~/.config/colorschemes/.active` symlink) that every themed app can follow.
- Per-app live reload: each app gets exactly the reload signal it natively supports, scripted in one place.
- gsettings `color-scheme` flip driven by `meta` (theme declares its mode).
- Hook point for user-owned wallpaper logic (`~/.config/colorschemes/.hook <theme-name>`), exec'd at the end of every switch.
- Boot-time application: a systemd user oneshot re-applies `.current` on graphical-session start so login is consistent.
- Rofi-driven picker (`theme-picker`) wired to a Hyprland keybind (`SUPER+T`).
- Same module works on the writer deck; foot has no live reload but a relaunch in cage is fine.

**Non-Goals:**

- Generating palettes from images (this is what matugen/pywal do — user wants named curated palettes).
- Per-app templating engines. Each app already has its own config format; we hand-write the swap for each.
- Supporting themes that live outside `~/.config/colorschemes/`.
- Backwards compatibility for the existing `~/.config/colorschemes/wallpapers` symlink (it becomes redundant once `.active/wallpapers/` exists; the script handles the migration).
- Replacing darkman. darkman stays for `hyprsunset` time-of-day control.
- Auto-detecting new themes. The `meta` file must exist per theme; the user adds them by hand.
- Adding new external dependencies (no new packages).

## Decisions

### D1. `.active` symlink as the single source of truth, not a sentinel file

**Choice:** `~/.config/colorschemes/.active` is a symlink pointing at the current theme's directory. A `.current` text file mirrors the name for tools that can't follow symlinks (some app loaders, the boot-time applier).

**Why:** Atomic swap with one syscall (`ln -sfn`). Apps that support symlink-following read `~/.config/colorschemes/.active/<app>/` directly. Apps that need a name read `.current`. Both can coexist; the cost is two writes per switch.

**Alternatives considered:**
- *Plain `.current` text file only*: requires every app to maintain its own per-app link/symlink. Doesn't scale.
- *Environment variable*: lost across reboots, hard to introspect from running processes, fights with systemd user services.
- *dconf / gsettings schema*: forces every app into a GTK-ish world; waybar/kitty/ghostty/hyprland don't read it.

### D2. Per-app reload handled inside `theme-switch`, not via inotify watchers

**Choice:** `theme-switch` is the orchestrator. It runs each per-app reload step explicitly. No daemon watches `~/.config/colorschemes/.active` for changes.

**Why:** Hyprland auto-watches its config (free). Other apps don't, and inventing an inotify daemon to *poke* apps adds a new failure surface. The user's stance: "if the app watches its own config, fine; otherwise, send the signal." That's exactly what `theme-switch` does.

**Alternatives considered:**
- *inotifywait daemon*: one more systemd service, one more race condition, no benefit over the explicit script.
- *DBus signal + per-app subscribers*: significant scaffolding for what amounts to ~10 commands.

### D3. Theme metadata via per-theme `meta` file, not Nix

**Choice:** Each theme gets a one-line `~/.config/colorschemes/<theme>/meta` file with `name=Display Name` and `mode=dark|light` (KEY=value, simple parser).

**Why:** Keeps the colorscheme dir fully self-describing. The `theme-picker` script reads these for its rofi menu. `theme-switch` reads the mode field to flip gsettings. No Nix expression, no rebuild.

**Alternatives considered:**
- *Filename convention (`gruvbox-dark/`, `e-ink-light/`) — infer mode from name*: fragile, requires a registry.
- *First-line comment in `colors.conf`*: mixes concerns (colors.conf is for hyprland, not for metadata).

### D4. Cleanup pass on swaync/wlogout/alacritty is required, not optional

**Choice:** Remove the hardcoded gruvbox colors from the three Nix modules. They become thin wrappers that `xdg.configFile` the active theme dir via out-of-store symlinks (same pattern as the existing `nvim` module).

**Why:** Without this, three of the user's themed apps simply won't switch (their colors are baked at build time). The cleanup is a one-time `home-manager switch`; theme switches thereafter are runtime only.

**Alternatives considered:**
- *Leave Nix modules alone, accept that swaync/wlogout/alacritty don't switch*: violates the user's goal of "every app picks up the new theme."
- *Template them at activation time*: requires `home-manager switch` on every theme change — explicitly rejected.

### D5. Darkman narrowed to hyprsunset only

**Choice:** `darkman` stays enabled. Its scripts lose the `gtk-theme` step (theme-switch owns that now) and keep the `hyprsunset` step (time-of-day temperature). `theme-switch` does not poke darkman.

**Why:** Theme owns *which palette* (dark vs light). Darkman owns *when to warm the screen* (sunset/sunrise). They're orthogonal and shouldn't fight. Conflating them — e.g., theme-switch telling darkman what mode to be in — creates two writers for the same gsettings keys.

**Alternatives considered:**
- *Theme-switch sets the darkman mode file*: simple but couples two systems that don't otherwise need to know about each other.
- *Kill darkman*: loses the automatic sunset temperature shift, which the user said they want to keep.

### D6. Wallpaper hook is user-owned, executed at end of switch

**Choice:** If `~/.config/colorschemes/.hook` exists and is executable, `theme-switch` runs it as `~/.config/colorschemes/.hook <theme-name>` at the very end of the switch. If it doesn't exist, the switch still completes.

**Why:** Wallpaper policy is personal (random pick? curated list? match a subdirectory?). The change shouldn't ship a wallpaper-rotation script the user didn't ask for. The hook is a single, documented extension point.

**Alternatives considered:**
- *Bundle a default random-wallpaper script in the Nix module*: scope creep, and the user explicitly said "you can leave that part to me."
- *awww integration baked into theme-switch*: same as above; also, awww already has its own `awww-cycle` systemd timer that picks from `~/Wallpapers`, and the `wallpapers` symlink today points at the theme's dir — so all theme-switch needs to do is repoint the symlink.

### D7. Boot-time re-apply via systemd user oneshot

**Choice:** `theme-switch` (no args) is idempotent: it reads `.current` and re-applies. A `theme-apply.service` systemd user oneshot is `WantedBy=graphical-session.target` and runs it on session start.

**Why:** Ensures the desktop matches `.current` after login even if a previous session crashed mid-switch. Cheap (the script no-ops if the symlink already points there).

**Alternatives considered:**
- *Home Manager activation hook*: runs only on `home-manager switch`, not on plain reboots.
- *Hyprland autostart command*: works but mixes init logic into compositor config; systemd target is cleaner.

### D8. Rofi picker is a thin wrapper, not a replacement for the CLI

**Choice:** `theme-picker` is a small script that reads each theme's `meta`, pipes them through `rofi -dmenu`, and `exec`s `theme-switch` on the chosen name. The CLI is the source of truth; the picker is sugar.

**Why:** Scriptability (cron, hyprland keybind action, shell aliases) belongs in the CLI. The picker is one Hyprland keybind away.

**Alternatives considered:**
- *Waybar module*: cute but adds a waybar dependency to a feature that doesn't need it.
- *TUI (fzf, gum)*: extra dependency, no gain.

### D9. Writer deck adopts the same script, with foot handled as "relaunch on switch"

**Choice:** Same Nix module imports into `hosts/writter-deck/home.nix`. The `theme-switch` script on the deck has a foot-specific step: `pkill foot && foot --server &` (foot's server-mode makes this near-instant for a writer deck).

**Why:** Zero new concepts on the deck. The user's deck is already gruvbox; this just lets them pick another.

**Alternatives considered:**
- *Separate `theme-switch-foot` script*: duplication for one app.
- *Skip the deck*: explicit non-goal of the user — they want it if cheap.

## Risks / Trade-offs

- **Atomicity of multi-app reload** → Mitigation: order the steps so data lands before signals (`hyprland` config swap is just a file rewrite; signals come after). If one app fails mid-sequence, the user can re-run `theme-switch <name>` — it's idempotent.

- **Hyprland's `source =` directive points at a path that must exist before hyprland reads it** → Mitigation: on first install, the activation script creates `.active` from `custom.theme.current` *before* hyprland starts. Hyprland only loads on graphical-session start (after `theme-apply.service`).

- **Waybar `@import` and symlink interplay** → Mitigation: waybar's `style.css` will `@import` from `themes/current.css` (a symlink the script updates); SIGUSR2 forces re-eval.

- **nvim running sessions won't recolor** → Mitigation: the script tries `nvim --remote-expr "colorscheme <name>"` if `$NVIM` is set; if not, only new nvim windows pick up the new theme. Documented as expected.

- **alacritty has no live color reload** → Mitigation: next-launched alacritty instances pick up the new config; existing windows keep their colors until restarted. Documented. (This matches alacritty's own behavior; not a regression.)

- **ghostty live reload is `SIGHUP`** → Mitigation: send `SIGHUP` to the running ghostty; on some versions this re-reads the config. If ghostty is unresponsive, the user restarts the terminal. Acceptable.

- **First-time switch after the cleanup rebuild may visually flash old-then-new** → Mitigation: the boot-time oneshot re-applies `.current` *before* the user sees the desktop; the flash only happens if the user runs `theme-switch` interactively, which is the point.

- **Adding a new theme requires writing a `meta` file** → Mitigation: documented in the theme module's option description. The `meta` file is two lines.

- **`darkman`'s gsettings writes could fight `theme-switch`'s** → Mitigation: the cleanup pass removes darkman's `gtk-theme` script entirely. After this change, darkman writes only to `hyprsunset`. No overlap.

- **Nix modules becoming "thin" can feel like over-abstraction to a reader who expects colors there** → Mitigation: the modules keep their `enable` options and any non-color config (font, opacity, layout). Only color strings leave. Comment in each module notes "colors come from `~/.config/colorschemes/.active/<app>/`."

- **Hook script runs as the user with no sandboxing** → Mitigation: it lives in the user's home dir, owned by the user. This is the same trust level as a shell alias. Documented in `theme-switch`'s usage output.

- **`ln -sfn` over an existing `.active` symlink is correct, but if `.active` exists as a *directory* (corruption), the symlink will be created inside it** → Mitigation: the script first checks `[ -L .active ] || [ ! -e .active ]` and bails with a clear error if `.active` is a directory. Documented in the script header.
