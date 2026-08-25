# Plan — PipeWire 48k default with auto-switching allowed rates and Home Manager bitrate switcher script

## Target
- Host: `jpporta-nixos` (NixOS system configuration and Home Manager user environment).
- System source: `hosts/jpporta-nixos/configuration.nix`.
- User module source: `modules/home-manager/audio-rate/default.nix` (and enabling it in `hosts/jpporta-nixos/home.nix`).
- Impact: `jpporta-nixos` only; no other hosts affected.

## Current state and diagnosis
- The Topping DX1 USB DAC advertises a maximum sample rate of 384 kHz.
- When active, PipeWire automatically switches its graph clock rate to 384 kHz.
- WebRTC / Chromium audio capture (used by Electron apps like Granola for system audio loopback) does not support 384 kHz capture, resulting in silent audio buffers during recording.
- The user wants:
  1. Everyday activities (browsers, Google Meet, Granola, games) to default to 48 kHz.
  2. Dynamic/automatic rate switching when hi-res audio streams (e.g. 384 kHz, 192 kHz, 96 kHz) are played.
  3. A Home Manager script (`audio-rate`) to inspect, force a specific clock rate (e.g., `48000`, `384000`), or return to `auto` mode on demand.

## Proposed change
1. **NixOS System Configuration (`hosts/jpporta-nixos/configuration.nix`)**:
   Add PipeWire extra configuration under `services.pipewire.extraConfig.pipewire."92-sample-rates"`:
   ```nix
   extraConfig.pipewire."92-sample-rates" = {
     "context.properties" = {
       "default.clock.rate" = 48000;
       "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
     };
   };
   ```
2. **Home Manager Module (`modules/home-manager/audio-rate/default.nix`)**:
   Create a reusable module providing the `audio-rate` shell application (`pipewire`, `jq`, `libnotify`, `coreutils` in runtime inputs) with options:
   - `audio-rate` or `audio-rate status`: display the active graph sample rate and whether it is forced or dynamic.
   - `audio-rate 48k` / `audio-rate 48000` / `audio-rate normal`: force 48 kHz clock rate (`pw-metadata -n settings 0 clock.force-rate 48000`).
   - `audio-rate 384k` / `audio-rate 384000` / `audio-rate hires`: force 384 kHz clock rate (`pw-metadata -n settings 0 clock.force-rate 384000`).
   - `audio-rate auto` / `audio-rate 0`: return to automatic dynamic rate switching (`pw-metadata -n settings 0 clock.force-rate 0`).
   - Custom rate argument (e.g. `audio-rate 96000`, `audio-rate 192000`).
3. **Home Manager Host Config (`hosts/jpporta-nixos/home.nix`)**:
   Import and enable `custom.audio-rate.enable = true;`.

## Validation
- Evaluate and build the system derivation:
  `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`
- Evaluate Home Manager packages and verify `audio-rate` executable derivation.
- Verify `audio-rate --help`, status reporting, rate forcing, and auto-switching locally.

## Deployment
After validation and explicit human approval:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback
- Risk: None to system boot. Forcing an unsupported sample rate via the script will return an error or be constrained by ALSA/PipeWire supported rates.
- Rollback: Revert the commits or switch to the previous NixOS generation via `sudo nixos-rebuild switch --rollback`.

## Human gate
Approve this plan before configuration editing or implementation starts.
