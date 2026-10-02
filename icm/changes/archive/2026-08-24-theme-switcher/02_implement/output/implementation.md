# Implementation — theme-switcher (stage 1)

Date: 2026-08-24
Status: **implemented** — iteration 1 applied, awaiting review/validation.

A minimal runtime-override layer. Theme switches are live (no `nixos-rebuild`): the switcher
writes color fragments to runtime paths, flips a wallpaper symlink, and signals each app to
reload. Home Manager keeps owning static app config.

## Source of truth

All 10 theme palettes were fetched fresh from upstream
`tinted-theming/base16-schemes` (commit `2b6f2d0677216ddda50c1dabd6ee78fae4665f81`).
No existing repo or user-owned theme files were copied. Each YAML is base16-spec
(`scheme`, `author`, `base00..base0F`) plus two extension keys consumed by nvim:
`colorscheme` (neovim colorscheme name) and `bg` (light/dark).

## Files created

| path | purpose |
|---|---|
| `themes/<slug>.yaml` ×10 | base16 scheme source + nvim extension keys |
| `themes/<slug>/wallpapers/` ×10 | per-theme wallpaper folders (empty in this commit; user-owned) |
| `tooling/theme-switcher/theme-switcher` | bash switcher (no third-party deps) |

Theme set (upstream slug): `gruvbox-dark`, `ayu-dark`, `rose-pine`, `catppuccin-mocha`,
`tokyonight-storm`, `dracula`, `nord`, `monokai`, `snazzy`, `kanagawa`.

CLI:
- `theme-switcher` → show current theme (from `~/.config/theme-switcher/current`)
- `theme-switcher --list` / `--help`
- `theme-switcher <slug>` → resolve YAML + wallpapers, write kitty/nvim/waybar fragments,
  atomic-swap `~/Wallpapers/current -> themes/<slug>/wallpapers`, trigger awww once,
  reload nvim + waybar, persist state. Unknown/illegal slug and malformed scheme exit
  non-zero after listing available themes.

## Files modified

| path | change |
|---|---|
| `modules/home-manager/kitty/default.nix` | removed inline gruvbox colors; added
  `include = "${config.home.homeDirectory}/.config/kitty/theme-current.conf"` so the switcher's
  runtime fragment is sourced. Fonts/layout remain HM-owned. |
| `modules/home-manager/nvim/nvim/lua/jpporta/theme.lua` | source the runtime fragment
  `~/.config/theme-switcher/nvim-current.lua` and re-enable the SIGUSR1 autocmd so live reload
  works. |

## Runtime paths (written by the switcher, NOT in the repo)

| path | owner |
|---|---|
| `~/.config/kitty/theme-current.conf` | switcher; kitty.conf `include`s it |
| `~/.config/theme-switcher/nvim-current.lua` | switcher; sourced by HM-managed `theme.lua` |
| `~/.config/theme-switcher/current` | switcher (state) |
| `~/.config/waybar/themes/theme-current.css` | switcher; style.css `@import`s it |
| `~/.config/waybar/style.css` | user-owned; first `@import "./themes/<f>.css"` line rewritten |
| `~/Wallpapers/current` | switcher symlink → `themes/<slug>/wallpaper` |

## Reload summary

| app | trigger |
|---|---|
| kitty | auto-reload on config-file change (writes `theme-current.conf`) |
| nvim | `pkill -SIGUSR1 -x nvim` re-runs `theme.lua` |
| waybar | `SIGHUP` to waybar processes |
| awww | direct `awww img <random-file>` from the symlinked folder (empty → skipped) |

## Validation performed

- `bash  -n` on the switcher: pass
- sandboxed smoke test of `--list`, unknown theme, illegal slug, and a real switch in a temp
  `HOME` producing kitty(16 colors)+nvim+waybar(10 `@define-color`) fragments, symlink flip,
  state write, idempotent re-switch, and waybar `@import` rewrite.
- full run across all 10 themes in sandbox: every theme parses and emits 16 kitty colors +
  10 waybar defines.
- `nix flake check`: passes (exit 0) — HM static config intact.
- `git diff --check`: no whitespace errors.

## Intentional deviations from the plan / proposal
1. **nvim runtime fragment path moved**: plan text suggested `~/.config/nvim/theme-current.lua`,
   but `~/.config/nvim` is a symlink into the repo (module default.nix uses
   `xdg.configFile."nvim".source = mkOutOfStoreSymlink ...`). Writing there would land in the
   repo and break the disjoint-files rule the plan itself sets. The fragment lives at
   `~/.config/theme-switcher/nvim-current.lua` instead, and `theme.lua` points there.
2. **Theme set finalized from availability**: plan listed cobalt2/kanagawa-wave; `cobalt2` is
   not in upstream base16-schemes, and the wave slug is simply `kanagawa` upstream. Both
   dropped/re-slugged so every YAML is fetched fresh. Full list above.
3. **hyprpaper**: no module edit, because the host already sets `hyprpaper.enable = false`
   (`home.nix:78`), which collapses the two-renderer ambiguity without touching the module.
4. **waybar reload**: `SIGHUP` (standard waybar reload) rather than a kill+restart via the
   user's `launch.sh`. To be confirmed against the running binary during stage 3.
5. **kitty reload**: relies on kitty's native config auto-reload (no signal). Confirmed during
   implementation read; still worth a runtime spot-check in stage 3.

## Review fix (this session)

- **waybar prepend path bug fixed**: `ensure_waybar_import` used
  `sed '1i,@import ...;,'` which inserted literal commas around the line when
  `style.css` had no existing `@import` (the smoke test only covered the rewrite
  path). Now `sed '1i@import ...;'` — verified in sandbox: prepend and rewrite
  both produce a clean `@import "./themes/theme-current.css";` line.
- **waybar reload signal fixed**: switcher sent `SIGHUP`; waybar v0.15 reloads on
  `SIGUSR2` (default `on-sigusr2: reload`). Now `pkill -SIGUSR2 -x waybar`.
- **slug aliases added**: `gruvbox`→`gruvbox-dark`, `catppuccin`→`catppuccin-mocha`,
  `tokyonight`→`tokyonight-storm`; `list`/`-l` accepted as `--list`.
- **install fixed**: `~/.local/bin` is a symlink into `~/dotfiles`; the script was
  copied to `dotfiles/scripts/.local/bin/theme-switcher`, so `git` resolved the
  repo root to `~/dotfiles` (no `themes/` there) → empty list. Replaced the copy
  with a symlink to `ndots/tooling/theme-switcher/theme-switcher`.
- **wallpapers seeded**: copied the user's existing per-theme images from
  `~/dotfiles/wallpapers/<src>/` into `themes/<slug>/wallpapers/` (8 of 10 themes;
  kanagawa/nord have no dotfiles source). External-source policy: user's own
  files, copied once into the new source of truth; dotfiles stays read-only.
- **kitty reload fixed (round 2)**: kitty auto-watch on the included fragment is
  broken by the atomic `mv` (the watcher tracks the old inode). Switcher now
  sends `SIGUSR1` to kitty — the documented config reload
  (`kill -SIGUSR1 $KITTY_PID`).
- **waybar reload fixed (round 2)**: `SIGUSR2` is documented but has known
  no-op/crash issues (waybar#3126). Added `"reload_style_on_change": true` to
  the user-owned `~/.config/waybar/config.jsonc` — waybar then watches
  `style.css` and its imported `theme-current.css` and hot-reloads colors with
  no signal. SIGUSR2 kept as a fallback in the switcher.
- **Nix-wrapped process matching fixed (round 3)**: kitty/waybar are Nix-wrapped,
  so `comm` is `.kitty-wrapped`/`.waybar-wrapped` and `pgrep -x`/`pkill -x`
  **never matched** — the real reason kitty needed a manual `kill -SIGUSR1 <pid>`.
  Switcher now matches the cmdline with `pgrep -f '^kitty( |$)'` etc. Verified
  live: kitty SIGUSR1 hits PID 118226.
- **waybar reload switched to launch.sh (round 3)**: user confirmed the reliable
  waybar reload is `~/.config/waybar/scripts/launch.sh` (killall + relaunch).
  Switcher now restarts waybar via that script when running; SIGUSR2 kept only
  as a fallback if the script is absent.

## Review verdict (this session)

Independent review by the orchestrator (background reviewer subagent failed twice
on runner infrastructure, not on content):

- **APPROVED for stage 3** with the prepend-path fix above.
- Verified against the approved plan: YAMLs are fresh upstream base16-schemes
  (commit `2b6f2d0...`), 10 wallpaper dirs exist, switcher does atomic symlink
  swap + fragment writes + awww trigger + reload signals, kitty module includes
  the runtime fragment, nvim theme.lua sources it and re-enables SIGUSR1.
- All 10 YAMLs carry `bg` + `colorscheme` extension keys.
- `nix flake check` passes (exit 0); `bash -n` and `git diff --check` clean.
- Deviations are honest and match the plan's own constraints (nvim fragment
  outside the repo-symlinked `~/.config/nvim`, hyprpaper already disabled on
  host, waybar SIGHUP, kitty auto-reload).

## Next

Stage 3 (validate) should run a real `theme-switcher <slug>` on the live host after the
stage-4 rebuild applies the HM edits, then confirm each app actually re-renders.
## Stage 1b — prompt theming (oh-my-posh + tmux; bat/fastfetch inherit)

Requested by the user after stage-1 review: theme the terminal prompt with the switch.

### Research verdict
- **oh-my-posh supports live reload natively** (`oh-my-posh enable reload` watches the config;
  config is otherwise cached). zsh re-renders the prompt after every command, so a written config
  is picked up on the next prompt line — no daemon, no signal, no shell restart, no tool swap.
  Starship/p10k rejected as needless risk.

### What changed
- `modules/home-manager/oh-my-posh/oh-my-posh.omp.json` — hardcoded hex replaced by
  `__C_ACCENT__/__C_PATH__/__C_GIT__/__C_NODE__/__C_RAM__/__C_ERR__` placeholders. Single source.
- `modules/home-manager/oh-my-posh/default.nix` — now `lib.replaceStrings`s the placeholders to the
  original defaults (build-time fallback so a fresh shell before any switch still renders).
- `modules/home-manager/zshrc/default.nix` — `initContent` order-1001: if
  `~/.config/oh-my-posh/theme-current.json` exists, re-eval
  `oh-my-posh init zsh --config <that>` (overrides HM's baked config path, which stays the fallback).
- `modules/home-manager/tmux/default.nix` — tmux.conf ends with a guarded
  `if-shell -f ~/.config/tmux/theme-current.conf 'source-file ...'` (fresh-session-safe).
- `tooling/theme-switcher/theme-switcher` — new `write_omp()` (fills the template from the active
  base16 theme → `~/.config/oh-my-posh/theme-current.json`, disjoint from HM's `config.json`) and
  `write_tmux()` (status/pane/window colors → `~/.config/tmux/theme-current.conf`); both wired into
  `main`; `reload_apps` now `tmux source-file`s the tmux fragment.

### base16 → prompt/tmux color mapping
- prompt: ACCENT=base0A, PATH=base0D, GIT=base0E, NODE=base0C, RAM=base0B, ERR=base08
- tmux: status fg/bg=base05/base00, pane border=base02, active border=base0A,
  window=base04/base01, current window=base00/base0A

### bat & fastfetch — intentionally NOT given explicit themes
- bat uses `theme = "ansi"` → renders with the terminal palette, which kitty now sets to the active
  base16 → already themed live by the same switch.
- fastfetch uses empty `display.color` (terminal defaults) and the `nixos_small` logo drawn from
  ANSI colors → also inherits kitty's base16. Adding explicit overrides would duplicate the palette
  for no visible gain. Revisit only if divergence from the terminal is wanted.
