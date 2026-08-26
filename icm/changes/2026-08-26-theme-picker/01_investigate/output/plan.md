# Plan — theme-picker

Date: 2026-08-26
Status: awaiting human approval

## Request

A theme picker UI that:

- Built on **Quickshell** (QML).
- Triggered by a **Hyprland keybind** that launches the Quickshell picker.
- Appears **centered, floating above everything**.
- Dismissed with **ESC**.
- Shows a **grid of rounded rectangles**, one per theme.
- Each rectangle's **background is the theme's background** (`base00`).
- Each rectangle shows the **theme name centered**, in the theme's **primary color** (`base0A`).
- A **highlight** marks the hovered/focused rectangle.
- **Navigation with vim keys (h/j/k/l) or arrow keys**.
- **Enter** selects: runs the existing `theme-switcher` script and dismisses the menu.
- The picker **derives its list from the theme YAML definitions** in `themes/*.yaml`, so adding/removing a theme yaml automatically updates the picker (no manual list to maintain).

This is the previously-deferred "later becomes a theme picker" step from the `2026-08-24-theme-switcher` change; the switcher script and YAML sources already exist and stay untouched in behavior.

## Target

- Host: `jpporta-nixos` user environment (Home Manager embedded in the NixOS config).
- Source: `hosts/jpporta-nixos/home.nix`, `modules/home-manager/`.
- `quickshell` is already installed via `modules/home-manager/arch-packages/default.nix` (`home.packages`).
- Build/switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`. **Only needed once** to install the new HM module + keybind; the picker itself is a transient process launched on demand, no daemon.

## Current behavior

- Theme switching is manual via the script `tooling/theme-switcher/theme-switcher <slug>` (invoked by full repo path; not installed on `PATH`). It reads `themes/<slug>.yaml`, writes runtime color fragments, swaps a wallpaper symlink, and signals each themed app to reload live (no rebuild). See `icm/changes/2026-08-24-theme-switcher/` for full behavior.
- `themes/` holds **10** theme YAMLs today: `ayu-dark, catppuccin-mocha, dracula, gruvbox-dark, kanagawa, monokai, nord, rose-pine, snazzy, tokyonight-storm`. Each is base16-spec with `base00..base0F` plus extension keys `scheme` (display name), `colorscheme`, `bg`. All 10 have both `base00` (bg) and `base0A` (primary) — the two keys the picker needs.
- Hyprland config is a single generated `hyprland.lua` from `modules/home-manager/hyprland/default.nix`. Binds are written with `hl.bind(mod .. " + <key>", hl.dsp.exec_cmd("<cmd>"))`. A `p` table already groups launcher commands (`terminal`, `menu`, etc.). There is no existing theme keybind.
- No Quickshell config exists in the repo or (expected) under `~/.config/quickshell/`. Quickshell is present as a package only.
- `arch-packages` also installs `matugen` and `pywal16`; neither is needed here (we already have authoritative palettes in the YAMLs).

## Desired behavior

1. New HM module `modules/home-manager/theme-picker/` that writes the Quickshell shell to the user config dir via `xdg.configFile`: `~/.config/quickshell/theme-picker/shell.qml` (+ any small support files). HM owns the static QML; the picker is stateless at runtime.
2. The QML picker:
   - On launch, runs `theme-switcher --dump` once (see below) and `JSON.parse`es the result into a theme array. Each entry: `{ slug, name, bg, primary }`.
   - Shows a full-screen `PanelWindow` on the **overlay** layer (above all windows), with a translucent/dimmed backdrop, and a centered grid of rounded rectangles.
   - Each rectangle: `radius` for rounded corners, `color` = `"#" + theme.bg`, a centered `Text` showing `theme.name` with `color` = `"#" + theme.primary`.
   - One rectangle is **focused** (initially the currently-active theme, read from `~/.config/theme-switcher/current`, or index 0). The focused item has a visible highlight border (and optional scale); **hovering a rectangle with the mouse moves focus to it**.
   - Keys: **ESC → quit**; **h/← and l/→** move focus left/right across the grid; **j/↓ and k/↑** move down/up; wrap or clamp at edges (clamp is simpler — chosen). **Enter → select**.
   - Enter / mouse click on a rectangle: runs `theme-switcher <slug>` (via a `Process`), then `Qt.quit()`. The switcher applies the theme live (existing behavior); the picker just triggers it and closes.
   - Mouse click on the dimmed backdrop = quit (cheap extra dismiss path).
3. New Hyprland keybind in `modules/home-manager/hyprland/default.nix`: a one-line `hl.bind(...)` launching `quickshell -p ~/.config/quickshell/theme-picker` (transient; the QML quits itself on dismiss/select). Exact chord proposed: **`SUPER + ALT + T`** (`mod_alt .. " + T"`) — does not collide with any existing bind (checked: existing `mod_alt` binds are P, C, R, L). Final chord is the user's call.
4. Add a `--dump` subcommand to `tooling/theme-switcher/theme-switcher` that prints one JSON array derived straight from `themes/*.yaml`:
   `[{"slug":"catppuccin-mocha","name":"Catppuccin Mocha","bg":"1e1e2e","primary":"f9e2af"}, ...]`
   Reuses the script's existing `value_of`/`hex_of` helpers and `list_themes` glob. This keeps **the YAMLs as the single source of truth** (add/remove a yaml → it shows in the picker with no other change) and gives QML native `JSON.parse` (no hand-rolled YAML parser in QML, no extra dependency).

### Why this approach (research findings)

- **One-shot launch + `Qt.quit()`, not a persistent daemon.** The picker only exists while open. A long-running Quickshell shell with IPC toggling would add complexity for no gain on a manually-triggered picker. Cost: a brief Qt cold-start each invocation (acceptable for a keypress-triggered menu; flagged as risk/iteration if it feels slow).
- **`--dump` JSON over reading YAML in QML.** QML has no native YAML parser; Quickshell's `FileView` would force a hand-rolled regex parser for the two keys we need, fragile to comment/format drift. The switcher already parses the YAMLs correctly; emitting JSON reuses that and gives QML `JSON.parse`. One process call at open. Fewer moving parts, single source of truth.
- **No new dependency.** `quickshell` is already a package. No `matugen`/`pywal16` needed.
- **Repo path / PATH.** The picker calls `theme-switcher` by the same full path used today (`~/ndots/tooling/theme-switcher/theme-switcher`), resolved in QML via `Quickshell.env("HOME") + "/ndots/tooling/theme-switcher/theme-switcher"`. No change to how the script is currently invoked → zero risk to existing switcher behavior. (Installing `theme-switcher` as a real `PATH` bin is deliberately **not** in scope; it's a separate, optional cleanup.)
- **Keyboard focus.** Quickshell `PanelWindow` must receive key events. Layer-shell keyboard interactivity / the window's focus policy needs to be set so keys reach the grid. This is the one runtime detail to confirm against the pinned Quickshell version at implement (same kind of "confirm against the running binary" caveat as waybar's reload signal in the prior change). Fallback if native key grab is awkward: a tiny `Shortcut`/`Keysym` handling on the window, or launch via a grab — resolved at implement.

## Affected files

- New: `modules/home-manager/theme-picker/default.nix` — HM module: `options.custom.theme-picker.enable` + `xdg.configFile."quickshell/theme-picker/shell.qml"` (and any split QML files). Imported from `home.nix` and enabled on `jpporta-nixos`.
- New: `modules/home-manager/theme-picker/shell.qml` (source of the written config; kept in the repo so HM writes a versioned file) — the picker UI.
- `hosts/jpporta-nixos/home.nix` — add `custom.theme-picker.enable = true;` (one line, alongside existing `custom.*.enable` flags).
- `modules/home-manager/hyprland/default.nix` — add one `hl.bind(mod_alt .. " + T", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/theme-picker"))` (in the App launchers section), and optionally a `p` entry.
- `tooling/theme-switcher/theme-switcher` — add `--dump` subcommand (~10 lines, reusing existing helpers; no change to any existing code path).

No edits to `configuration.nix`, no new packages, no touch to the existing theme YAMLs or any themed-app module. Shared modules affect only `jpporta-nixos` (deck does not import Hyprland/Quickshell picker; will state in implementation that this module is jpporta-nixos-only via where it's enabled).

## Validation

1. Rebuild once: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`; picker QML present at `~/.config/quickshell/theme-picker/shell.qml`; no evaluation errors (`nix flake check` if quick).
2. Press the keybind: a centered floating grid appears above all windows; count of rectangles == number of `themes/*.yaml` (verify after adding a dummy `themes/test.yaml` it appears, then remove it).
3. Each rectangle: background matches its theme's `base00`, label text matches its `scheme` name in `base0A` color, rounded corners.
4. Vim keys (h/j/k/l) and arrow keys move the highlight; edges clamp; ESC and backdrop-click dismiss.
5. Mouse hover moves focus to the hovered rectangle.
6. Enter on a theme: `theme-switcher <slug>` runs (kitty/nvim/waybar/etc. switch live, per the existing switcher) and the picker closes.
7. `git diff --check`; confirm no existing switcher behavior regressed (run `theme-switcher --list`, `theme-switcher <slug>` by hand).
8. Confirm the uncommitted items from prior changes (steam-pipewire, little-coder, ollama, oh-my-posh edits, configuration.nix/home.nix edits already staged) are **not** included in this change's diff.

## Risks

- **Quickshell key focus:** the overlay must capture keyboard for vim/arrow/ESC/Enter nav. Needs confirmation against the pinned Quickshell version at implement; fallback path noted above.
- **Cold-start latency:** one-shot launch reloads Qt each time. Fine for a manual picker; if it feels slow, a later iteration can make the shell persistent and toggle window visibility via IPC (out of scope here).
- **Repo-path assumption:** QML resolves the switcher at `~/ndots/tooling/theme-switcher/theme-switcher`. If the repo moves, the launch path breaks (same assumption the existing `nixs`/`hms` aliases already make). Acceptable; document in the QML.
- **Quickshell shell-discovery / `-p` flag:** exact `quickshell` CLI invocation (`-p <dir>` vs a named shell under `~/.config/quickshell/`) to be confirmed against the installed version at implement; the bind command will match whatever the module writes.
- **No daemon state to persist.** The picker is stateless; the only persistent state is the existing `~/.config/theme-switcher/current`, which the picker only reads to set initial focus.
- **Must not entangle uncommitted prior work.** Several unrelated files are already staged/modified (see git status); this change's diff stays limited to the files listed above.

## Rollback

- The keybind is a single added line; remove it to disable the trigger with no rebuild of behavior.
- The HM module is opt-in via a flag; unset `custom.theme-picker.enable` and rebuild to remove the written QML.
- The `--dump` subcommand is additive; removing it only breaks the picker, not the existing `theme-switcher` flows.
- All changes are git-revertible; no package or host is rewired.

## Human gate

Review and approve this plan before any file edits. No implementation yet.
Scope is intentionally minimal: Quickshell picker UI + one Hyprland keybind + one additive `--dump` subcommand. UI polish (animations, multi-monitor placement, search/filter) is deferred to later iterations unless the plan is amended.
