# Deployment: virtual microphone input

## Target

- Host: `jpporta-nixos`
- Command: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Outcome

The deployment command was attempted from this session but could not obtain the sudo password because the environment has no interactive terminal:

```text
sudo: a terminal is required to read the password; either use the -S option or configure an askpass helper
sudo: a password is required
```

The user subsequently confirmed that the corrected virtual microphone works: output audio is looped into the virtual input and applications can use it.

## Observed behavior

- A named `Virtual_Microphone` input is available.
- Audio routed through the virtual output is available to applications through that input.

## Rollback

If needed, run `virtual-mic stop` to remove the runtime devices. Configuration rollback is to revert the change in `modules/home-manager/audio-rate/default.nix` and rebuild the target.
