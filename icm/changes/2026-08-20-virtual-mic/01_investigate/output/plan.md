# Plan: virtual microphone for system audio

## Target

- Host: `jpporta-nixos`
- Scope: Home Manager user utility for the host's existing PipeWire/PulseAudio-compatible session.
- The shared Home Manager modules are imported by the NixOS host only for this feature; the writer deck is unaffected.

## Current behavior

- `hosts/jpporta-nixos/configuration.nix` enables PipeWire with its PulseAudio compatibility server (`services.pipewire.pulse.enable = true`).
- `hosts/jpporta-nixos/home.nix` already imports and enables the Home Manager `audio-rate` module, which is the smallest existing home for another PipeWire audio utility.
- No current script creates a virtual audio input.

## Desired behavior

Add a `virtual-mic` command with:

- `start`: create an idempotent PipeWire/PulseAudio null sink named `virtual_mic`, then loop the current default sink monitor into it;
- `stop`: remove only the loopback(s) feeding `virtual_mic`, then remove that null sink;
- `status`: report whether the virtual microphone exists;
- `toggle`: start or stop it; no argument uses `toggle` for quick use.

Applications can select **Monitor of Virtual Microphone** as their input. Normal playback remains on the existing default output because the script copies the default output monitor into the null sink rather than replacing the default sink.

## Proposed files

- `modules/home-manager/audio-rate/default.nix`: add the minimal `virtual-mic` `writeShellApplication` and include it in the existing module's `home.packages`.
- `hosts/jpporta-nixos/home.nix`: no change; the already-enabled `audio-rate` module will provide the command.

## Validation

1. Run `nix fmt -- --check` or the repository's available Nix formatter check.
2. Build the target without switching:
   `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel`
3. On the running session, run `virtual-mic start`, verify the sink/source with `pactl list short sinks` and `pactl list short sources`, then run `virtual-mic stop` and verify both are gone.
4. Confirm regular audio still plays and an application can select the virtual monitor as its input.

## Deployment

After the implementation diff and validation are reviewed and explicitly approved:

`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback

- The change only loads per-user PipeWire modules and does not alter the default output or system service configuration.
- If the virtual device misbehaves, run `virtual-mic stop`; the configuration rollback is to remove the added script and package entry from `modules/home-manager/audio-rate/default.nix`, then rebuild after approval.
