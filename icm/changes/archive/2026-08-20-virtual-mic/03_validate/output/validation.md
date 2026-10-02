# Validation: virtual microphone input

## Commands

- `git diff --check`
- `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`

## Results

- `git diff --check`: passed.
- NixOS target build: passed. The build included the generated `virtual-mic` derivation and the Home Manager generation.

## Runtime verification

The user confirmed that the corrected virtual microphone works after deployment: the output is looped into the virtual input and applications can use it.

## Warnings and residual risk

The build emitted existing deprecation warnings for the `system` attribute and `xorg.xauth`; neither is related to this change. No unresolved virtual-microphone issue remains.
