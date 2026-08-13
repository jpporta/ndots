# Implementation — remove-mdcat-install-tiki

Date: 2026-08-12
Status: implemented; validation passed; awaiting configuration diff review and deployment approval

## Changed
- `modules/home-manager/wezterm/default.nix`
  - Removed the `pkgs.mdcat` package.
  - Added a pinned `buildGoModule` derivation for `boolean-maybe/tiki` v0.6.1.
  - Added release version linker metadata.
  - Installed the resulting `tiki` package through the existing WezTerm module.

## Unchanged
- `hosts/jpporta-nixos/home.nix` still imports and enables the existing WezTerm module.
- Hyprland's `wezterm` terminal launcher was not changed.
- The writer-deck configuration was not changed.

## Diff review
The implementation changes one configuration file and only replace mdcat with tiki. No external dotfiles, secrets, or deployment commands were used.

## Validation results
- `nix flake check` passed.
- `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link` passed.
- The build compiled Tiki v0.6.1 and included `git` as a native test input so upstream integration tests could run successfully in the sandbox.
- `git diff --check` passed.
- The resulting closure contains Tiki and no mdcat reference.

The source and vendor hashes were obtained from reproducible Nix fixed-output failures during investigation. Interactive Tiki behavior remains a post-deployment check.

## Human gate
Review the source diff and this implementation record before deployment approval.
