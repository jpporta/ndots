# Validation — wezterm-gruvbox-dark

Date: 2026-08-12

## Commands run

- `nix flake check` — passed.
- `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link` — passed.
- `git diff --check` — passed.

## Results

The flake evaluated successfully and the selected `jpporta-nixos` system derivation built successfully. The build included the updated Home Manager WezTerm configuration and generated color-scheme configuration.

## Warnings

- Existing warning: `xorg.xauth` is deprecated and has been renamed to `xauth`.
- Existing warning: the build uses the renamed `system` attribute.
- `nix flake check` omitted incompatible `aarch64-linux` checks; this is expected for the current local check invocation and does not affect the selected `x86_64-linux` target.
- The Git tree was dirty during validation because changes are staged but not committed.

## Unresolved risk

Interactive WezTerm rendering was not exercised. Existing WezTerm sessions may need to be restarted after deployment to load the generated Gruvbox scheme.

## Deployment gate

Validation is complete. The exact deployment command requiring explicit approval is:

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

No deployment command was run.
