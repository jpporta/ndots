# Implementation — theme-picker

Date: 2026-08-26
Status: awaiting diff approval

Plan: `../01_investigate/output/plan.md` (approved as written, keybind SUPER+ALT+T).

## Changed paths

| File | Change |
|---|---|
| `tooling/theme-switcher/theme-switcher` | Additive: new `dump_json()` + a `--dump` case in `main()` + a line in the `--help` header. No existing path touched. |
| `modules/home-manager/theme-picker/shell.qml` | New: the one-shot Quickshell picker. |
| `modules/home-manager/theme-picker/default.nix` | New: `options.custom.theme-picker.enable` + `xdg.configFile."quickshell/theme-picker/shell.qml"`. |
| `hosts/jpporta-nixos/home.nix` | Import the new module + `custom.theme-picker.enable = true;` (2 lines). |
| `modules/home-manager/hyprland/default.nix` | `p.theme_picker = "qs -p ~/.config/quickshell/theme-picker"` entry + one bind `hl.bind(mod_alt .. " + T", hl.dsp.exec_cmd(p.theme_picker))`. |

No edits to `configuration.nix`, no new packages (quickshell already in `arch-packages`), no touch to the existing theme YAMLs or any themed-app module. The uncommitted prior work (steam-pipewire, little-coder, ollama, oh-my-posh edits, etc.) was **not** included.

## Behavior

- Hyprland `SUPER + ALT + T` runs `qs -p ~/.config/quickshell/theme-picker`.
- The shell is loaded by explicit **path** (`-p`), not config name (`-c`). Restriction discovered live: `~/.config/quickshell/shell.qml` exists, so Quickshell registers it as the `default` config and **ignores all subdirectories** — `qs -c theme-picker` returns "Could not find ... config directory" even though `theme-picker/shell.qml` is present. `-p <path>` bypasses that shadowing.
- On open, the picker runs `theme-switcher --dump` once; output is JSON `{"current":"<slug>","themes":[{"slug","name","bg","primary"}, ...]}` read straight from `themes/*.yaml` via the existing `value_of`/`hex_of` helpers. Add/remove a theme yaml → it appears in the picker with no other change.
- A full-screen `PanelWindow` (`aboveWindows`, `focusable`, `exclusionMode: Ignore`, `exclusiveZone: -1`) dims the desktop and centers a grid of rounded rectangles. `bg` = `#base00`, centered label = theme `scheme` name in `#base0A` primary, with a raised style for legibility.
- Initial focus = the live theme (from `dump.current`), else index 0.
- Keys (window has keyboard focus): ESC → quit; h/← and l/→ move columns; j/↓ and k/↑ move rows (clamp at grid edges); Enter → apply. Mouse hover moves focus; click applies; backdrop click quits.
- Enter/click calls `Quickshell.execDetached([switcher, slug])` (fire-and-forget; the switcher keeps running and applies the theme live after the picker quits) then `Qt.quit()`.

## QML implementation notes (root-cause fixes from live testing)

- **`Process` must not be nested under a plain `QtObject` root**, and `Process.command` is a `QQmlListProperty` — assignable only at **declaration time** (a literal array), never via a JS `= [..]` in a function body (both raise "Cannot assign to non-existent default property"). So:
  - root is an `Item` (state lives on it; `Process` nests fine under items/windows);
  - the dump `Process` declares `command: [switcher, "--dump"]` statically;
  - applying a theme uses `Quickshell.execDetached(...)` instead of a runtime-configured second `Process`.
- `color: "rgba(...)"` strings are rejected by QML color ("color expected") — translucent colors use `Qt.rgba(r, g, b, a)`; opaque use `#RRGGBB`.
- The deployed `~/.config/quickshell/theme-picker/shell.qml` is a Home Manager **store symlink**; after editing `modules/home-manager/theme-picker/shell.qml` you must rebuild for the runtime copy to refresh.
- Grid is 5 columns (10 themes → 2 rows); extra themes flow into further rows.

## Validation done so far

- `theme-switcher --dump` parses as valid JSON (verified via `node -e JSON.parse`): 10 themes, `current=ayu-dark`. Colors match `themes/*.yaml` (bg=base00, primary=base0A, name=scheme).
- Flake evaluates: `home-manager.users.jpporta.config.custom.theme-picker.enable == true` and `xdg.configFile."quickshell/theme-picker/shell.qml".source` resolves (success=true).
- `qmlformat` (Qt 6.11.1, the Qt build quickshell links against) accepts `shell.qml` (exit 0) — QML syntax is valid.
- `qs -p <dir>` on the fixed module file loads cleanly: `Configuration Loaded`, no runtime errors; the dump `Process` runs `theme-switcher --dump` (JSON verified earlier via `node -e JSON.parse`: 10 themes, `current=ayu-dark`).
- `git diff --check` clean.

## Not yet validated (stage 03, on the live target)

These need the running Hyprland session; they are the stage-03 checklist, run after this diff is approved:

1. `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos` — confirm `~/.config/quickshell/theme-picker/shell.qml` is written and no eval error.
2. `SUPER+ALT+T` opens a centered grid floating above all windows; rectangle count == number of `themes/*.yaml` (add a dummy `themes/test.yaml`, rebuild-switch, confirm it shows, then remove).
3. Each rectangle: bg matches `base00`, label text matches the `scheme` name in `base0A`, rounded corners.
4. h/j/k/l + arrows move the highlight (clamp at edges); ESC and backdrop-click dismiss.
5. Mouse hover moves focus to the hovered rectangle.
6. Enter on a theme runs `theme-switcher <slug>` (kitty/nvim/waybar/etc. switch live) and the picker closes.

## Risks confirmed / to confirm at stage 03

- **Quickshell key focus** — set via `focusable: true` on the `PanelWindow` + `focus: true` on the root Item with `Keys.onPressed`. Confirmed the property exists in the 0.3.0 qmltypes; runtime behavior (keys reach the grid) is a stage-03 check. Fallback if it doesn't: launch via a focused surface or use `Shortcut`/`Keysym` — not needed yet.
- **Cold-start latency** — one-shot launch reloads Qt each time. Acceptable for a manual picker; if it feels slow, a later iteration makes the shell persistent and toggles visibility via IPC.
- **Repo path** — QML resolves the switcher at `~/ndots/tooling/theme-switcher/theme-switcher` via `Quickshell.env("HOME")`. Same assumption as the existing `nixs`/`hms` aliases.
- **Multi-monitor** — picker shows on `Quickshell.screens[0]` only; deferred per plan.

## Rollback

- Remove the keybind line to disable the trigger with no behavior rebuild.
- Unset `custom.theme-picker.enable` and rebuild to remove the written QML.
- The `--dump` subcommand is additive; removing it only breaks the picker, not the existing `theme-switcher` flows.
