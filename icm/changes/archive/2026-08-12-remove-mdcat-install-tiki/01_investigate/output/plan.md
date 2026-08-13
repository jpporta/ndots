# Plan — remove-mdcat-install-tiki

Date: 2026-08-12
Status: awaiting human approval

## Target
- Host: `jpporta-nixos` user environment
- Build/switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
- Shared module impact: `modules/home-manager/wezterm/default.nix` is imported only by `hosts/jpporta-nixos/home.nix`; `jpporta-deck` is unaffected.

## Current behavior
- `modules/home-manager/wezterm/default.nix` enables WezTerm and installs `pkgs.mdcat`.
- `hosts/jpporta-nixos/home.nix` imports and enables that module.
- Hyprland already launches `wezterm` for `SUPER+Return`.
- `mdcat` is only referenced by the WezTerm module; Neovim's Markdown plugins are unrelated and remain unchanged.
- `tiki` is not present in nixpkgs. Upstream is a Go 1.25 project and publishes Linux binaries, but a reproducible Nix source build is preferable to a curl installer or mutable release download.

## Desired behavior
Remove `mdcat` and provide `tiki` in the `jpporta-nixos` Home Manager environment by packaging upstream `boolean-maybe/tiki` v0.6.1 with `buildGoModule`. Keep the existing WezTerm configuration and Hyprland launcher unchanged.

The package should:
- fetch the pinned `v0.6.1` source archive from GitHub;
- use the fixed source hash `sha256-uxdgB13rHwWperjuFMznUyP/70r4h2drVxSGSGFzYyM=`;
- use the Go module vendor hash discovered during investigation: `sha256-vV8iBVdurcMUC7kwkAlnSt6cI4gNFRg721rkSuuOC2g=`;
- build the `tiki` binary with release version metadata;
- expose `tiki` through the existing opt-in WezTerm Home Manager module.

## Affected files
- `modules/home-manager/wezterm/default.nix` — replace `pkgs.mdcat` with a local `tiki` `buildGoModule` derivation and install it.
- `hosts/jpporta-nixos/home.nix` — no edit expected; existing module import/enable remains sufficient.
- `icm/changes/2026-08-12-remove-mdcat-install-tiki/` — record the plan and later implementation/validation/deployment outputs.

## Validation
- `nix flake check`
- `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`
- Inspect the built Home Manager package closure or evaluate the module to confirm `tiki` is present and `mdcat` is absent.
- Run the packaged executable's `--version`/`--help` if available without deploying.

## Risks
- Upstream is young and may release incompatible changes; pinning v0.6.1 and both hashes makes the build reproducible.
- `buildGoModule` uses the pinned nixpkgs Go toolchain. The current pinned nixpkgs exposes Go 1.26.5, newer than upstream's declared Go 1.25 requirement; the source build was checked through dependency vendoring, but the full target build remains the validation gate.
- Tiki's interactive terminal rendering and image behavior cannot be proven by a non-interactive Nix build.
- Replacing mdcat removes the old executable intentionally. No terminal shortcut changes are included.

## Rollback
Revert the implementation commit and run:

```sh
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

The previous WezTerm module state restores `mdcat`; no external installer or mutable state is involved.

## Human gate
Review and approve this plan before any configuration edit.
