# Design: theme-switch

## Context

The host (jpporta-nixos, Hyprland on Wayland) and the deck (jpporta-deck, cage + foot) both want a single command to swap themes across every themed tool. Today there is no canonical theme system on this host — themed files live wherever each tool installed them, several Nix modules bake gruvbox hex at build time, and there is no "current theme" pointer.

The user wants a clean slate. No files are migrated from anywhere; the curated tree at `~/.config/themes/` is laid down fresh. After install, the system is functional with one theme (gruvbox-dark) and adding a new theme is `mkdir` plus dropping per-app config files into the new directory.

Constraints discovered during exploration:

- All per-theme assets must remain editable without rebuild. The curated tree lives outside the Nix store, accessed via `mkOutOfStoreSymlink`.
- Theme colors live in dotfiles, not Nix. Anything baked into Nix is a second source of truth and must be removed.
- The `.active` symlink pattern is preferred over a sentinel file: atomic (`ln -sfn`), apps follow it directly, no second write per switch.
- nvim wants all themes installed as colorschemes simultaneously, regardless of which one is `.active`. The `.active` symlink is irrelevant to nvim-in-nvim coloring.
- No systemd service. No boot-time re-apply. Apps read on launch; live-reload-capable apps reload on signal or file watch.

## Goals / Non-Goals

**Goals:**

- Atomic theme swap with one shell command (`theme-switch <name>`) — no Nix rebuild, no per-app scripting by the user.
- Single canonical pointer (`~/.config/themes/.active` symlink) that every themed app follows.
- Per-app live reload: each app gets exactly the reload mechanism it natively supports, scripted in one place.
- gsettings `color-scheme` flip driven by the theme's mode, derived from dir name with `meta` fallback.
- All themes installed as nvim colorschemes simultaneously, regardless of `.active`.
- Rofi-driven picker (`theme-picker`) wired to a Hyprland keybind (`SUPER+T`).
- Adding a new theme = `mkdir ~/.config/themes/<new-name>/` + drop per-app files. No Nix rebuild.
- Boot-time default selectable via `custom.theme.current`.
- Same module on the nixos host and the deck; foot is deck-only.

**Non-Goals:**

- Generating palettes from images (matugen).
- Backwards compatibility with any pre-existing colorscheme files (none exist).
- Per-app templating engines — each app already has its own config format.
- Supporting themes that live outside `~/.config/themes/`.
- A systemd user service. No boot-time applier.
- A "current" text file — `.active` is the only pointer.
- Auto-detecting new themes at runtime. The script reads the directory at call time.
- Replacing darkman. darkman stays for `hyprsunset` time-of-day control; theme owns dark/light mode via gsettings.

## Decisions

### D1. Curated tree at `~/.config/themes/`, not `~/.config/colorschemes/`

**Choice:** The themed files live at `~/.config/themes/<theme>/<app>/...` with `.active` as a symlink at the root.

**Why:** Shorter. Conventional naming. Distinct from any historical colorschemes directory the user may have experimented with. The symlink convention is well-known (e.g., `~/.config/themes/.active`).

**Alternatives considered:**

- `~/.config/colorschemes/` — original proposal location. Renamed for clarity and brevity.

### D2. `.active` is a symlink; no `.current` text file

**Choice:** `~/.config/themes/.active` is a symlink to the current theme's directory. Apps follow it directly. `readlink .active` returns the current theme name for the picker.

**Why:** Atomic swap with one syscall (`ln -sfn`). Apps that support symlink-following read `~/.config/themes/.active/<app>/...` directly. No second write per switch, no second source of truth.

**Alternatives considered:**

- Plain `.current` text file — requires every app to maintain its own per-app link/symlink. Doesn't scale.
- Both `.active` and `.current` (original proposal) — redundant. The symlink target IS the name.

### D3. Per-app reload handled inside `theme-switch`, not via inotify watchers

**Choice:** `theme-switch` is the orchestrator. It runs each per-app reload step explicitly. No daemon watches `~/.config/themes/.active` for changes.

**Why:** Hyprland auto-watches its config (free). Other apps don't, and inventing an inotify daemon adds a new failure surface. Apps that don't reload get "next-launch only" — acceptable for wlogout/alacritty/bat/fastfetch/oh-my-posh/foot.

**Alternatives considered:**

- inotifywait daemon — one more systemd service, one more race condition, no benefit.
- DBus signal + per-app subscribers — significant scaffolding for ~10 commands.

### D4. Mode detection from dir name with optional `meta` fallback

**Choice:** If the dir name ends in `-dark` or `-light`, that's the mode. Otherwise, read `<theme>/meta` for `mode=dark` or `mode=light`. If neither resolves, default to `dark` and emit a warning to stderr.

**Why:** Most themes follow the convention; the few stragglers (cobalt2, tokyo-night) get a one-line `meta` file. No schema, no parser library. Adding a new theme is the smallest possible action.

**Alternatives considered:**

- Universal `meta` file required per theme — over-engineered for 14 themes that already encode mode in the name.
- Filename regex on full path — same idea, but the suffix convention is simpler to remember and document.

### D5. Out-of-store symlinks for every themed app config

**Choice:** The Nix module declares `xdg.configFile."<app>/<file>".source = mkOutOfStoreSymlink "<path-into-curated-tree>"` for every themed app. The symlink target is either `~/.config/themes/.active/<app>/<file>` (most apps) or `~/.config/themes/<theme>/<app>/<file>` (nvim, where ALL themes are exposed).

**Why:** One-time Nix rebuild wires up all the symlinks. After that, the curated tree is fully mutable — theme switches edit only the `.active` symlink or app config files inside the tree; Nix is not touched again.

**Alternatives considered:**

- Have `theme-switch` rewrite each app's config file path — fights Nix's source-of-truth model; the `xdg.configFile` declaration is the clean way.
- Template the config files at activation time — requires rebuild on every change.

### D6. nvim colorschemes are installed for ALL themes, not just the active one

**Choice:** Nix declares one symlink per theme under `~/.config/nvim/lua/colors/<theme>.lua`, pointing at `~/.config/themes/<theme>/nvim/colors.lua`. The Nix module adds `~/.config/nvim/lua/colors` to nvim's runtimepath.

**Why:** `:colorscheme <theme>` works for any theme at any time. Lazy.nvim / Telescope can list and select all of them. Session-local override via `:colorscheme` is fully decoupled from `.active` — closing nvim and reopening returns to `.active`'s theme by way of the file content at `<theme>/nvim/colors.lua`.

**Alternatives considered:**

- Only the active theme is exposed as a colorscheme — `:colorscheme gruvbox-dark` would fail when `.active` points at `rose-pine`. User explicitly rejected this.
- Nix reads the theme list at evaluation time — fragile if themes are added without rebuild. User wants adding a theme to be `mkdir` only.

### D7. External vs session-local nvim theme override

**Choice:** When `theme-switch` runs externally:
- If `$NVIM` is set, send `nvim --remote-expr 'lua vim.cmd.colorscheme("<name>")'`.
- Otherwise, just swap `.active`. The next nvim launch picks up `.active`'s theme.

When the user runs `:colorscheme <theme>` inside nvim, the session overrides; `.active` is not touched. Closing and reopening reverts to `.active`.

**Why:** Both paths exist for different reasons. External `theme-switch` is "I want everything in my desktop to follow." `:colorscheme` is "I'm in nvim, I want this window different." The two should not interfere.

### D8. Cleanup pass on swaync/wlogout/alacritty/hyprland is required, not optional

**Choice:** Remove the hardcoded gruvbox colors from the four Nix modules. They become thin wrappers that `xdg.configFile` the active theme dir via out-of-store symlinks. Hyprland replaces inline border colors with `source = ~/.config/themes/.active/hypr/colors.conf`.

**Why:** Without this, four of the user's themed apps don't switch (their colors are baked at build time). The cleanup is a one-time `home-manager switch`; theme switches thereafter are runtime only.

### D9. Darkman narrowed to hyprsunset only

**Choice:** `darkman` stays enabled. Its scripts lose the `gtk-theme` step (theme-switch owns that now) and keep the `hyprsunset` step (time-of-day temperature). `theme-switch` does not poke darkman.

**Why:** Theme owns which palette (dark vs light). Darkman owns when to warm the screen. They're orthogonal. Conflating them creates two writers for the same gsettings keys.

### D10. Wallpaper hook is user-owned, executed at end of switch

**Choice:** If `~/.config/themes/.hook` exists and is executable, `theme-switch` runs it as `~/.config/themes/.hook <theme-name>` at the very end of the switch. If it doesn't exist, the switch still completes. Non-zero exit is logged but does not fail the switch.

**Why:** Wallpaper policy is personal (random pick? curated list? match a subdirectory?). The change ships the hook point; the user provides the script.

### D11. Rofi picker is a thin wrapper, not a replacement for the CLI

**Choice:** `theme-picker` reads `theme-switch list`, pipes through `rofi -dmenu`, and execs `theme-switch` on the chosen name. The CLI is the source of truth; the picker is sugar.

**Why:** Scriptability (cron, hyprland keybind action, shell aliases) belongs in the CLI. The picker is one Hyprland keybind away.

### D12. CLI surface is minimal: `theme-switch <name>` and `theme-switch list`

**Choice:** Two subcommands. `theme-switch <name>` switches. `theme-switch list` prints one line per theme (`<name>\t<mode>\t<display_name>`). Invalid name → print available themes to stderr, exit 2.

**Why:** User explicitly chose minimal surface. `list` is enough for any external picker (rofi, fzf, TUI, GUI). No `--current`, no `--path`, no `--json`.

### D13. No systemd service, no boot-time applier

**Choice:** `theme-switch` runs on demand. There is no `theme-apply.service`, no `graphical-session.target` hook, no `.current` text file. Apps read on launch; live-reload-capable apps reload on signal or file watch.

**Why:** User explicitly rejected the systemd approach. Apps that need a re-apply on boot get it for free because they read the symlinked config files when they start. Swaync is autostarted by hyprland, so it picks up `.active` on every session start.

### D14. Deck adopts the same module with foot

**Choice:** Same Nix module imports into `hosts/writter-deck/home.nix`. The `theme-switch` script on the deck has a foot-specific step: try `pkill -SIGHUP foot` first; if the running footserver doesn't reload (older foot), fall back to `pkill -TERM foot` and let the cage/foot autostart restart it.

**Why:** Zero new concepts on the deck. The user's deck is gruvbox-dark; this just lets them pick another. Foot has no live color reload, so a one-window flash on switch is accepted.

## Risks / Trade-offs

- **Atomicity of multi-app reload** → Mitigation: order steps so data lands before signals. Symlink swap is one syscall; signals come after. If one app fails mid-sequence, the user re-runs `theme-switch <name>` — idempotent.

- **Hyprland's `source =` directive must point at a path that exists** → Mitigation: the activation script creates `.active` from `custom.theme.current` before hyprland reads it on first session start.

- **nvim colorscheme file is symlinked into `lua/colors/`** → Mitigation: if a theme has no `nvim/colors.lua` file, the colorscheme is not registered for that theme. The Nix activation warns about missing files at install time.

- **Alacritty has no live color reload** → Mitigation: documented; next-launched alacritty picks up new config. Matches alacritty's own behavior.

- **Foot on the deck may flash on switch** → Mitigation: try SIGHUP first; only restart if it doesn't work. Documented.

- **Adding a new theme requires writing the per-app config files** → Mitigation: documented in the module's option description. Adding a theme is `mkdir` + drop files. No Nix change required.

- **`darkman`'s gsettings writes could fight `theme-switch`'s** → Mitigation: the cleanup pass removes darkman's `gtk-theme` script. After this change, darkman writes only to `hyprsunset`. No overlap.

- **Hook script runs as the user with no sandboxing** → Mitigation: it lives in the user's home dir, owned by the user. Same trust level as a shell alias. Documented.

- **`ln -sfn` over an existing `.active` directory (corruption) creates the symlink inside it** → Mitigation: the script checks `[ -L .active ] || [ ! -e .active ]` and bails with a clear error if `.active` is a non-symlink directory.

- **Multiple themes with the same `-dark` suffix in dir name** → Mitigation: the script uses exact directory name match, not globbing. `gruvbox-dark` and `gruvbox-dark-extra` are distinct entries.