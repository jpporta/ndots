# Plan — wezterm-gruvbox-dark

Date: 2026-08-12  
Status: awaiting human approval

## Target

- Host: `jpporta-nixos` user environment.
- Source: `modules/home-manager/wezterm/default.nix`, enabled by `hosts/jpporta-nixos/home.nix`.
- Build/check: `nix flake check` and `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`.
- Deployment, after validation approval: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.
- Shared module impact: `modules/home-manager/wezterm` is currently imported only by `hosts/jpporta-nixos/home.nix`; `jpporta-deck` is unaffected.

## Current behavior

The enabled WezTerm Home Manager module configures the BerkeleyMono Nerd Font Mono at 11pt, undecorated windows, 0.8 opacity, 10x16 padding, and no tab bar. It does not define or select a terminal color scheme. The existing Alacritty module and Neovim theme files contain separate Gruvbox-related configuration, but neither controls WezTerm.

## Desired behavior

Add a `Gruvbox Dark` color scheme to the WezTerm module using the standard Gruvbox dark palette, and set WezTerm's `color_scheme` setting to `Gruvbox Dark` so it is active by default. Keep the scheme local to the existing module; do not add a dependency or import external dotfiles.

The scheme will include the complete terminal palette expected by WezTerm: ANSI and bright colors, background/foreground, cursor colors, and selection colors. The background remains compatible with the existing window opacity setting.

## Affected files

- `modules/home-manager/wezterm/default.nix` — add the `colorSchemes.Gruvbox Dark` definition and select it with `settings.color_scheme`.
- `icm/changes/2026-08-12-wezterm-gruvbox-dark/` — preserve this change record through the required review stages.

No host entry point or Hyprland configuration needs to change because WezTerm is already enabled and launched by the existing configuration.

## Validation

1. Run `nix flake check`.
2. Run `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`.
3. Run `git diff --check`.
4. Inspect the generated Home Manager WezTerm configuration to confirm it contains `color_scheme = "Gruvbox Dark"` and a generated `wezterm/colors/Gruvbox Dark.toml` file if the build output makes those files inspectable.

Expected result: the flake evaluates and the selected NixOS configuration builds successfully with the custom scheme generated and selected. Interactive color rendering cannot be verified without launching WezTerm after deployment.

## Risks

- The custom palette may differ slightly from a user's preferred Gruvbox variant (for example, hard/soft background); the selected palette is the conventional Gruvbox Dark palette.
- Existing WezTerm windows may need to be restarted after the Home Manager switch to load the generated scheme.
- The repository currently contains unrelated staged/uncommitted changes from the prior WezTerm installation change; those must not be modified or included in this change's implementation.

## Rollback

Revert only the implementation change to `modules/home-manager/wezterm/default.nix`, rebuild the target, and switch with the same approved command. The prior WezTerm configuration remains the fallback state; no package or host wiring is removed.

## Human gate

Review and approve this plan before any configuration edit. No implementation has been performed.
