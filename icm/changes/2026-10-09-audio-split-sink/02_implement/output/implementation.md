# Implementation — audio-split module

## Status
Plan approved 2026-10-09 19:11. Edits applied to the exact files named in the plan.

## Changed files
1. **New** `modules/home-manager/audio-split/default.nix`
   - Declares `options.custom.audio-split.enable`.
   - `audioSplitScript = pkgs.writeShellApplication { name = "audio-split"; ... }`
     using `runtimeInputs = [ coreutils gawk gnugrep pulseaudio ]` (same set as the
     existing `virtual-mic` script).
   - Script behavior:
     - `sink_name=split_combined`, description `Combined_Output`.
     - Hardware sinks hardcoded by Pulse node name:
       - `hw_sink_1 = alsa_output.usb-Topping_DX1-00.HiFi__Headphones__sink` (DX1 Headphones)
       - `hw_sink_2 = alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink` (USB Audio Speakers)
     - `start`: rejects if either hardware sink is missing; creates the null sink
       if absent; creates one loopback per hardware sink (each guarded by an
       existence check, so it is idempotent and self-heals a single missing loopback).
     - `stop`: unloads both loopbacks (matched per target sink) then the null sink.
     - `status` / `toggle` mirror the `virtual-mic` interface.
   - `config = lib.mkIf cfg.enable { home.packages = [ audioSplitScript ]; };`
2. **Edit** `hosts/jpporta-nixos/home.nix`
   - Added `../../modules/home-manager/audio-split` to `imports`.
   - Added `audio-split.enable = true;` next to `audio-rate.enable = true;`.

## Deviations from plan
None.

## Notes
- The working tree already contained unrelated staged/unstaged changes before this
  change began (e.g. `modules/nixos/gaming`, `modules/home-manager/gaming`,
  `configuration.nix`, `hyprland` module, a `ranger` package in `home.nix`).
  Those are **not** part of this change and were not modified here.
- Only the two lines in `home.nix` (plus the new audio-split module) belong to this change.

## Diff (this change only)
- `home.nix`: +2 lines (one import, one enable flag).
- `modules/home-manager/audio-split/default.nix`: new file (~100 lines).