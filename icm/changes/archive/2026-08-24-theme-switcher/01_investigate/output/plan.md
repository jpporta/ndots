# Plan — theme-switcher

Date: 2026-08-24
Status: awaiting human approval

## Request

A theme switcher that (1) stores several developer color schemes as YAML, (2) switching applies live to every themed app without a `nixos-rebuild`/`home-manager switch`, (3) is invoked as a script, e.g. `theme-switcher rose-pine`, and (4) later becomes a theme picker.

The switch must also:

- Keep per-theme **wallpapers** in their own folders and surface the active theme's wallpapers
  via a symlink (no file copies, no moves).
- Trigger **awww** once on switch so the new theme's wallpaper is picked up live.
- Update and reload **waybar** colors to match the theme.

## Target

- Host: `jpporta-nixos` user environment (Home Manager embedded in the NixOS config).
- Source: `hosts/jpporta-nixos/home.nix`, existing modules under `modules/home-manager/`.
- Build/switch today: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.
- **Design intent: theme switches must NOT require this rebuild.** The switcher writes color fragments to runtime locations, swaps a wallpaper symlink, and signals each app to reload; Nix/HM keeps owning the static app config (fonts, layout, habits).

## Current behavior

The theme is per-app and hardcoded today:

- `modules/home-manager/kitty/default.nix` — Gruvbox Dark colors inline in `programs.kitty.settings`.
- `modules/home-manager/nvim/nvim/lua/jpporta/theme.lua` — unconditionally `dofile`s `gruvbox-dark.lua`.
- `modules/home-manager/awww/default.nix` — `awww.enable = true`; systemd user service + a `awww-cycle`
  timer+oneshot already pick a random image from `~/Wallpapers` and call `awww img <file>`. The
  configured `wallpaperDir` default is `~/Wallpapers`.
- `modules/home-manager/hyprpaper/default.nix` — currently pins a gruvbox wallpaper path under
  `~/dotfiles/colorschemes/.../wallhaven-9oxg98.jpg`. With `awww` already enabled, hyprpaper is
  dead config and shouldn't render wallpapers.
- `modules/home-manager/tmux/` — Catppuccin tmux-theme plugin (flavor option present).
- `modules/home-manager/darkman/default.nix` — GTK light/dark via `gsettings`; hooked to `hyprsunset`.
- Waybar: config is **not** managed by this repo — it lives under `~/.config/waybar/` and is launched
  by `~/.config/waybar/scripts/launch.sh` (referenced from `modules/home-manager/hyprland/default.nix`).
- `modules/home-manager/zshrc`, `oh-my-posh`, `bat`, `fastfetch` — may carry theme/color settings.
- Only one scheme is active at a time; changing it means editing Nix and rebuilding.

There is already a `modules/home-manager/nvim/nvim/lua/jpporta/themes/` directory with 12 theme
Lua files (gruvbox light/dark, rose-pine light/dark, catppuccin light/mocha, tokyonight, dracula,
ayu light/dark, monokai light/dark, snazzy, cobalt2) — several match the requested top developer
themes but are nvim-only.

## Desired behavior

1. Add a directory of theme **YAML scheme files** (one per theme, shared structure) in the repo
   — not under Nix modules — e.g. `themes/<theme>.yaml`.
2. Each theme also has a `themes/<theme>/wallpapers/` directory containing its images. The
   active theme's wallpapers become available to the system via a single symlink (e.g.
   `~/Wallpapers/current -> themes/<theme>/wallpapers`) that the switcher rewrites atomically.
   No file copies, no moves; a single canonical path the rest of the system reads.
3. Build a `theme-switcher <theme>` command that:
   - Resolves the chosen YAML scheme and its `wallpapers/` folder.
   - Rewrites the wallpaper symlink target to the new theme's wallpaper folder.
   - Writes per-app color fragment files the apps already source/watch (kitty theme `.conf`,
     nvim theme `.lua`, a runtime waybar CSS fragment, tmux/zsh fragments as applicable).
   - Triggers **awww** once to set a wallpaper from the newly-linked folder (either invoke the
     existing `awww-cycle` oneshot via `systemctl --user`, or call `awww img <file>` directly
     after picking one from the symlinked dir).
   - Signals each running app to reload (kitty reload, nvim SIGUSR1, waybar reload signal,
     zsh re-source, etc.) so the change is **live with no rebuild**.
4. Home Manager keeps owning the static parts of each app config; only the color fragment,
   the waybar fragment, and the wallpaper symlink are runtime-mutable. If Home Manager
   re-evaluates later, the switcher state persists (stored in a plain file, not in Nix).

This is deliberately a **minimal runtime-override layer**, not a Nix-type-system redesign.

## Why this approach (research findings)

This satisfies all hard requirements and is the lazy read of the ecosystem:

- **no rebuild**: theme fragments + reload signals replace the HM regenerate-and-switch path. The
  alternists (vogix16, nix-colors/stylix-style `stylix.base16Scheme`) still rebuild Nix structures on
  switch, which violates requirement #1. Avoid them here.
- **live on all apps**: kitty natively supports non-interactive switching
  (`kitten themes NAME --reload-in=all`, or sourcing a `current-theme.conf` via `include` + config
  reload); nvim `theme.lua` already contains a commented-out `nvim_create_autocmd("Signal", SIGUSR1)`
  reload hook to re-enable. awww daemon responds to a single `awww img <file>` invocation.
  waybar reloads on its config-file change (SIGHUP is the common one — to be confirmed against
  the running binary). Each app gets its own tiny reload path. No daemon needed.
- **no HM conflict**: HM writes application-layout, the switcher owns the color fragment, the
  waybar fragment, and the wallpaper symlink. On any future HM switch the layout stays
  authoritative and the color state survives.

The first-pass theme set maps onto base16-schemes theme names and matches the existing nvim theme
files; several top developer themes (gruvbox, rose-pine, catppuccin, ayu, monokai, snazzy, dracula,
tokyonight, cobalt2) are already present in nvim form for harvesting the palettes.
`themes/*.yaml` becomes the single source; nvim/kitty/waybar fragments are generated from it.

## Increment: prompt colors (oh-my-posh) — live reload confirmed

Investigating the user's request to theme the terminal prompt with the switch.

### Does oh-my-posh support live reload? (yes — keep it)

- oh-my-posh re-evaluates on every prompt render and watches its config file
  (`oh-my-posh enable reload` turns the file watcher on; config is otherwise cached). Verified
  against upstream repo/issues. Our shell is zsh, which re-renders the prompt after every command, so
  a written config is picked up on the next Prompt natively — no daemon and no signal needed.
- No alternative (Starship, powerlevel10k) is needed; swapping tools would add risk for no gain.

### How HM wires it today (the constraint)

- `programs.oh-my-posh.enable = true`; the HM module generates
  `eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.json)"` and writes the
  hand-authored `oh-my-posh.omp.json` (7 hardcoded hex colors) to that path at build time.
- Keep the static template as the HM fallback (fixes the fresh-boot-before-first-switch case).

### Design (matches the switcher's disjoint-files rule)

- **New** `tooling/theme-switcher/omp-template.json` — the prompt template, static parts only, with
  named placeholders (`__C_ACCENT__`, `__C_PATH__`, `__C_GIT__`, `__C_NODE__`, `__C_RAM__`, `__C_OK__`,
  `__C_ERR__`) in place of the hardcoded hex. Single source of truth (replaces the colors already
  baked into `oh-my-posh.omp.json`).
- HM `oh-my-posh/default.nix` keeps the current JSON as a build-time default.
- **Switcher** adds `write_omp()`: reads the template, substitutes the base16 colors of the active
  theme (base0A→accent, base0D→git, base0C→node, base0B→ram, base05→path, base08→error, … exact map
  fixed at implement), writes `~/.config/oh-my-posh/theme-current.json` (runtime path, NOT
  `config.json` which HM owns → no write conflict).
- zsh init (our `zshrc` module): after HM's omp eval, if `theme-current.json` exists, re-eval
  `oh-my-posh init zsh --config ~/.config/oh-my-posh/theme-current.json`. If it does not exist yet
  (never switched), HM's baked default renders — prompt never blank.
- No reload signal: next prompt renders the new colors automatically.

### Validation (adds to stage list)

1. After a switch, an idle zsh prompt shows the new theme colors on the next keypress/Enter — no
   rebuild, no shell restart.
2. Fresh shell (before any switch) still renders the HM default (goto path exists).
3. Colors actually come from `themes/<slug>.yaml`, matching kitty/waybar/nvim.

## Affected files

- `themes/<theme>.yaml` — new: YAML scheme source (one per theme).
- `themes/<theme>/wallpapers/` — new: per-theme wallpaper folder containing images the switcher
  exposes by symlink to a single runtime wallpaper directory.
- `modules/home-manager/kitty/default.nix` — replace inline colors with an `include`/override
  of the runtime-generated theme fragment (keeps the rest of kitty.conf owned by HM).
- `modules/home-manager/nvim/nvim/lua/jpporta/theme.lua` — re-enable the SIGUSR1 reload path and
  point the sourced theme path at the generated fragment.
- `modules/home-manager/hyprpaper/default.nix` — disable `custom.hyprpaper.enable`. With `awww`
  enabled as the wallpaper daemon, hyprpaper is dead config; this change collapses the two-renderer
  ambiguity so only awww paints wallpapers.
- New: the `theme-switcher` script (path TBD — likely `tooling/` or `modules/home-manager/`)
  plus the runtime fragments it generates.
- Possibly existing nvim `themes/*.lua` become generated fragments rather than hand-authored source.
- Runtime-only (not in this repo): the active wallpaper symlink (e.g. `~/Wallpapers/current`),
  the runtime waybar CSS fragment that waybar `include`s, and any in-nvim theme path.

No `configuration.nix` edits, no HM module additions beyond what's listed.

## Validation

1. `theme-switcher gruvbox` changes kitty + nvim + awww + waybar live with no rebuild
   (verify each: kitty one instance, nvim, wallpaper, waybar).
2. `theme-switcher ayu-dark` switches again; old windows reload or a documented caveat.
3. The wallpaper symlink target flips to the new theme's folder and `awww` renders an image
   from it within a transition.
4. `nix flake check` still evaluates (HM static config is intact).
5. `git diff --check`.
6. Confirm persistence after a later `sudo nixos-rebuild switch` — the chosen theme survives.

## Risks

- Not every app hot-reloads natively. First scope: kitty + nvim + waybar + awww (verified
  reload paths); tmux/zsh/other extensions come in later stages.
- The switcher must not write into HM-managed files; fragment files live in app-runtime paths
  so HM and the switcher own disjoint files.
- `awww` and `hyprpaper` both render wallpapers — they must not be enabled simultaneously. The
  current `awww.enable = true` plus `custom.hyprpaper.enable = true` state means two renderers
  fight. Disabling `hyprpaper` in this change collapses that ambiguity.
- Waybar config is not managed by this repo (lives under `~/.config/waybar/`); the switcher
  rewrites a waybar-included fragment, not the repo.
- Waybar's reload signal needs to be confirmed during implement (SIGHUP is the usual one but
  will be verified against the running binary before relying on it).
- `awww` IPC semantics (`awww img <file>` vs daemon flag) need to be confirmed against the
  pinned `awww` package version; reuse the existing `awww-cycle` systemd oneshot if the
  daemon-side API changes.
- The repository still contains unstaged/uncommitted items from prior changes (steam-pipewire,
  pipewire, etc.). Do not touch or include those in this change's implementation.

## Rollback

- The switcher writes to runtime fragment paths and a single symlink, not to managed Nix
  files; revert = `theme-switcher` rewrites the fragment with the previous scheme and flips
  the symlink back, or the user resets to the HM-layout default.
- The HM module edits (kitty/nvim/hyprpaper disable) are revertible via git; no package or
  host-delete is unwired.

## Human gate

Review and approve this plan before any theme files or script edits. No implementation yet.
This is staged: step 1 = YAML sources + per-theme wallpaper folders + switcher covering
kitty, nvim, awww, waybar. Later steps add the remaining app reloads and the theme picker.
