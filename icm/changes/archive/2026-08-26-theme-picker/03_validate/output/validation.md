# Validation — theme-picker

Date: 2026-08-26
Status: validated (live, on the target)

## What was validated

Run on `jpporta-nixos` after `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos` wrote the module's QML (`~/.config/quickshell/theme-picker/shell.qml`) and the new keybind.

| # | Check | Result |
|---|---|---|
| 1 | Flake evaluates; `custom.theme-picker.enable == true`; QML resolves into the store | pass |
| 2 | `qs -p ~/.config/quickshell/theme-picker` loads with `Configuration Loaded`, no runtime errors | pass |
| 3 | `SUPER + ALT + T` opens the picker centered, floating above all windows | pass |
| 4 | Rectangle count == number of `themes/*.yaml` (10); each bg = `#base00`, label = `scheme` name in `#base0A`, rounded corners | pass |
| 5 | vim keys (h/j/k/l) + arrow keys move the highlight; edges clamp; ESC + backdrop-click dismiss | pass |
| 6 | Mouse hover moves focus to the hovered rectangle | pass |
| 7 | Enter runs `theme-switcher <slug>` live (kitty/nvim/waybar/etc. switch) and the picker closes | pass |

## Issue found & fixed during validation

- **Symptom:** launching the picker also opened a blank, WM-managed window (class `org.quickshell`, tiled) that displaced other windows.
- **Root cause:** the shell's root object was a plain `Item` wrapping a `PanelWindow`. A bare top-level `Item` makes Quickshell open an extra managed toplevel; the `PanelWindow` is the layer-surface overlay (never WM-managed).
- **Confirmation:** `hyprctl clients` — root `Item` → `+2` managed `org.quickshell` windows; root `PanelWindow` → `+0`.
- **Fix:** made the `PanelWindow` the shell root (state + `Process` nested inside it). Re-checked: `Configuration Loaded`, `org.quickshell` managed-window count `0`.
- **Other QML root causes fixed while getting it to load:** `Process` cannot be nested under a `QtObject` root and `Process.command` is only assignable at declaration time (not via JS `= [..]`); apply now uses `Quickshell.execDetached(...)`. `color: "rgba(...)"` strings are invalid QML → `Qt.rgba()` / `#RRGGBB`.

## Invocation correction

- The launch command is `qs -p ~/.config/quickshell/theme-picker` (path), **not** `qs -c theme-picker` (name). `~/.config/quickshell/shell.qml` exists, so Quickshell registers it as the `default` config and ignores all subdirectories — `-c theme-picker` reports "config directory not found". `-p` bypasses that shadowing. The keybind and module comment reflect this.

## Remaining caveats (deferred, non-blocking)

- Multi-monitor: picker shows on `Quickshell.screens[0]` only.
- Cold-start: one-shot launch reloads Qt each invocation (acceptable for a manual picker).

## Human gate

Validation output reviewed; behavior confirmed on the live target. Proceed to deploy record.
