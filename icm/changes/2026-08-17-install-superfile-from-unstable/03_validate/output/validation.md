# Validation — install Superfile from nixpkgs unstable

## Checks run

1. Evaluated the Home Manager package list and counted `superfile` entries.
   - Result: exactly one `superfile-*` entry.
   - The remaining entry is the explicit `inputs.nixpkgs-unstable...superfile` package in `hosts/jpporta-nixos/home.nix`.

2. Built the NixOS target without switching:
   ```text
   nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link
   ```
   - Result: successful.
   - The previous `pkgs.buildEnv` conflicting-subpath error did not recur.

## Warnings
- Nix warns that `system` is deprecated in favor of `stdenv.hostPlatform.system` in an evaluated configuration path.
- Nix warns that `xorg.xauth` is deprecated in favor of `xauth`.
- Neither warning prevented the build and neither is part of this focused change.

## Deployment status
Not deployed. The exact switch command still requires explicit human approval:
```text
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Human check
Review this validation result and explicitly approve the switch command before deployment.
