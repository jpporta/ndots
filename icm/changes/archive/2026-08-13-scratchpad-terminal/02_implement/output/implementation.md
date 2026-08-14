# Implementation — scratchpad-terminal

Date: 2026-08-13
Status: implemented

## Changes made

### `modules/home-manager/hyprland/default.nix`

Added the following changes:

1. **Scratchpad terminal launch command** (line ~168):
   ```lua
   scratchpad_terminal = "kitty --class=scratchpad-terminal",
   ```

2. **Super+/ keybinding** (line ~177):
   ```lua
   hl.bind(mod .. " + code:84", hl.dsp.exec_cmd(p.scratchpad_terminal))
   ```
   Uses Linux keycode 84 for the forward slash (/) key.

3. **Window rule for centered floating 4:3 terminal** (lines ~350-357):
   ```lua
   hl.window_rule({
           name = "Scratchpad Terminal",
           match = { class = "scratchpad-terminal" },
           float = true,
           center = true,
           size = "(monitor_w*0.4) (monitor_w*0.3)",
   })
   ```
   - `float = true`: Makes the window floating (not tiled)
   - `center = true`: Centers the window on the active monitor
   - `size = "(monitor_w*0.4) (monitor_w*0.3)"`: Sets a 4:3 aspect ratio based on monitor width (40% width, 30% width for height = 4:3)

## Deviations from plan

None. Implementation follows the plan exactly.

## Validation

- `nix flake check`: **passed**
- `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --dry-run`: **passed** (8 derivations queued)

## Next steps

1. Review the source diff and this `implementation.md`
2. Proceed to `03_validate/` for full validation
3. After validation approval, proceed to `04_deploy/` for deployment with:
   ```
   sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
   ```
