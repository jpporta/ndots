# Implementation — PipeWire sample rates and audio-rate switcher

## Status
Applied the approved changes exactly as planned.

## Changed Files
1. `hosts/jpporta-nixos/configuration.nix`:
   - Configured `services.pipewire.extraConfig.pipewire."92-sample-rates"` with `default.clock.rate = 48000;` and `default.clock.allowed-rates = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];`.
2. `modules/home-manager/audio-rate/default.nix`:
   - Created Home Manager module with `pkgs.writeShellApplication` for `audio-rate`.
   - Supports `status`, `auto`, `48k`/`normal`, `384k`/`hires`, `96k`, `192k`, and arbitrary `<rate>` values.
   - Sends desktop notifications via `notify-send`.
3. `hosts/jpporta-nixos/home.nix`:
   - Imported `../../modules/home-manager/audio-rate`.
   - Enabled `custom.audio-rate.enable = true;`.

## Deviations from Plan
None.

## Next Stage
`03_validate/`: Run `nix build` check on `jpporta-nixos` to confirm evaluation and package builds succeed before deployment.
