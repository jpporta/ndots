# Validation — theme-switcher (stage 3)

Date: 2026-08-24
Status: **pending deployment** — static checks pass; live runtime checks require the
rebuild (kitty.conf must gain the `include` line) and a running desktop session.

## Static checks (already passed)

| check | result |
|---|---|
| `nix flake check` | exit 0, all checks passed |
| `bash -n tooling/theme-switcher/theme-switcher` | pass |
| `git diff --check` | pass (no whitespace errors) |
| sandbox smoke: `--list`, unknown theme, illegal slug, real switch, idempotent re-switch, waybar prepend + rewrite | all pass (prepend-path bug found and fixed during review) |
| 10-theme loop in sandbox | every theme parses, emits 16 kitty colors + 10 waybar defines |
| live host partial state | switcher state = `dracula`; `~/.config/waybar/style.css` already imports `./themes/theme-current.css`; `~/Wallpapers/current` already symlinks to `themes/dracula/wallpapers` |

## Pending live checks (after rebuild + approved deployment)

1. kitty.conf contains `include .../theme-current.conf` (rebuild applies the HM edit).
2. `theme-switcher <slug>` on the live host:
   - writes kitty/nvim/waybar fragments, flips symlink, triggers awww, reloads apps;
   - exit 0, no errors.
3. Each app actually re-renders (needs a running desktop session):
   - kitty: one instance color change (auto-reload);
   - nvim: SIGUSR1 reload re-sources fragment (open nvim, switch, colorscheme changes);
   - waybar: SIGUSR2 re-reads style.css (colors change);
   - awww: wallpaper from the new theme's folder (empty folders → skipped by design).
4. Persistence: after a later `sudo nixos-rebuild switch`, the chosen theme survives
   (state file `~/.config/theme-switcher/current` is runtime-owned, not HM-managed).

## Live checks — DONE (2026-08-25, this session)

After the user's rebuild and the install fix (see implementation record):

| check | result |
|---|---|
| `theme-switcher --list` | 10 themes listed (was empty: stale copy in `~/dotfiles` resolved the wrong repo root) |
| `theme-switcher gruvbox` (alias) | exit 0; resolved to gruvbox-dark |
| kitty fragment | written to `~/.config/kitty/theme-current.conf`, 16 colors |
| nvim fragment | written to `~/.config/theme-switcher/nvim-current.lua` (bg=dark, colorscheme=gruvbox) |
| waybar fragment + import | `theme-current.css` written; `style.css` imports it |
| wallpaper symlink | `~/Wallpapers/current -> themes/gruvbox-dark/wallpapers` |
| awww | **set** `ghibli-japanese-walled-garden.png` from the new folder (was skipping: folders were empty; now seeded from `~/dotfiles/wallpapers/`) |
| nvim reload | SIGUSR1 sent |
| waybar reload | not running at test time; SIGUSR2 verified against v0.15 docs + sandbox |

User-observed after rebuild: kitty + nvim picked up the new color; waybar needed a
manual reset (root cause: SIGHUP instead of SIGUSR2 — fixed); wallpapers didn't
change (root cause: empty theme folders — seeded).

## Round-2 fixes (2026-08-25, this session)

User reported after the round-1 fixes: nvim + wallpaper auto-reload, but **kitty
and waybar still need manual refresh**.

| app | root cause | fix |
|---|---|---|
| kitty | auto-watch on the *included* fragment is broken by the atomic `mv` (watcher tracks the old inode) | switcher sends `SIGUSR1` to kitty (documented reload) |
| waybar | `SIGUSR2` reload has known no-op/crash issues (waybar#3126) | `"reload_style_on_change": true` in `~/.config/waybar/config.jsonc` — waybar watches `style.css` + imported `theme-current.css` and hot-reloads colors, no signal needed |

Both verified in sandbox; live re-test pending (apps not running at test time).

## Round-3 fixes (2026-08-25, this session)

User reported after round 2: waybar still needs `launch.sh`-style restart, and kitty
only changed after a manual `kill -SIGUSR1 <pid>`.

**Root cause (both):** kitty and waybar are Nix-wrapped, so their `comm` is
`.kitty-wrapped` / `.waybar-wrapped`. `pgrep -x` / `pkill -x` never matched, so the
switcher's signals were silently sent to nothing.

| app | fix |
|---|---|
| kitty | match cmdline: `pgrep -f '^kitty( |$)'` + `pkill -SIGUSR1 -f '^kitty( |$)'` |
| waybar | restart via `~/.config/waybar/scripts/launch.sh` (killall + relaunch); SIGUSR2 only as fallback |
| nvim | same cmdline-pattern fix for consistency |

**Live verification (this session):**
- `pgrep -f '^kitty( |$)'` → 118226; `pgrep -f '^waybar( |$)'` → 145766 (both matched).
- `theme-switcher gruvbox` → kitty SIGUSR1 sent (PID 118226 alive), waybar restarted
  via launch.sh (new PID 162236, reloaded config + CSS), awww set dock.png.
- kitty + waybar both live and applied gruvbox-dark.

## Unresolved risks

- kitty/waybar reload semantics depend on the running binaries — confirmed in the
  live check above.
- Per-theme nvim `colorscheme` must be installed on the host; missing ones silently
  fall back to the default colorscheme (accepted caveat).
- Theme wallpaper folders are empty → awww skips until the user populates them.

## Human check

Review this validation record and explicitly approve the deployment command
(`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`) before deployment.
## Stage 1b validation (prompt theming)

### Static checks (passed this session)
| check | result |
|---|---|
| `bash -n tooling/theme-switcher/theme-switcher` | pass |
| sandbox switch (dracula) | kitty+nvim+waybar+**oh-my-posh**+**tmux** fragments all written; symlink/state/awww intact |
| 10-theme omp loop | every theme emits valid `theme-current.json`, no `__C_*__` placeholder left |
| tmux fragment (dracula) | correct base16 status/pane/window colors emitted |
| `nix flake check` | all checks passed (exit 0); HM substitution + zsh inset order valid |

### Pending live checks (after rebuild + approved deployment)
1. rebuild applies the HM zsh init override + omp defaults + tmux guarded source (zsh/tmux are
   static; the switcher fragments are already runtime).
2. `theme-switcher dracula` → an idle zsh prompt shows the theme colors on the next Enter, no
   shell restart; tmux status bar recolors (new + existing sessions).
3. Fresh shell before any switch still renders (HM default path guard).
4. kitty/nvim/waybar/awww behavior from stage 1 unchanged.
