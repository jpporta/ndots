# Validation — PipeWire sample rates and audio-rate switcher

## Validation Command
```bash
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link
```

## Result
- **Success**: Top-level system derivation built without errors.
- Both `pipewire` extraConfig (`92-sample-rates.conf`) and the Home Manager `audio-rate` executable derivation built successfully.
- Tested `audio-rate` binary directly:
  - `audio-rate status`: correctly parsed active rate and mode.
  - `audio-rate auto`: correctly reset `clock.force-rate` to `0` for dynamic auto rate matching.
  - `audio-rate 48k`: correctly locked `clock.force-rate` to `48000`.

## Unresolved Risks
None.

## Deployment Command (Awaiting Approval)
```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```
