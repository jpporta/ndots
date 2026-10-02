# Plan — replace-wezterm-with-kitty

Date: 2026-08-12
Status: awaiting human approval

## Target
- Host: `jpporta-nixos` user environment (Home Manager embedded in the NixOS configuration)
- Build/switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
- Shared module impact: `modules/home-manager/wezterm/default.nix` is imported only by `hosts/jpporta-nixos/home.nix` currently. `modules/home-manager/hyprland/default.nix` is reusable, but its terminal launcher change will affect any host that imports and enables that module in the future.

## Current behavior
On `jpporta-nixos`, `hosts/jpporta-nixos/home.nix` imports `modules/home-manager/wezterm` and enables `custom.wezterm`. The module installs Tiki 0.6.1 and Mermaid CLI alongside WezTerm, enables Kitty graphics, and configures:

- Gruvbox Dark colors
- Berkeley Mono Nerd Font Mono with JetBrains Mono and Nerd Font Symbols fallbacks
- Ligatures disabled
- Font size 11
- No window decorations
- 80% background opacity
- 10px horizontal and 16px vertical window padding
- No tab bar

Hyprland launches `wezterm` as its terminal. Tiki image rendering currently emits Kitty Unicode placeholders that do not render correctly in WezTerm.

## Desired behavior
Remove WezTerm and replace it with Kitty on `jpporta-nixos`. Translate the existing WezTerm appearance and behavior into Kitty settings wherever Kitty provides an equivalent, including the Gruvbox Dark palette, font/fallback intent, font size, opacity, padding, and borderless presentation. Preserve the existing Tiki 0.6.1 package definition and Mermaid CLI package. Update Hyprland to launch Kitty.

Where WezTerm has no direct Kitty equivalent, use the closest Kitty-native behavior rather than adding unnecessary compatibility machinery. Kitty must support Tiki's Kitty graphics image protocol, including the Unicode placeholder mode used by Tiki.

## Affected files
- `modules/home-manager/wezterm/default.nix` — replace the WezTerm Home Manager module with the Kitty configuration module while retaining the Tiki 0.6.1 build and Mermaid CLI package definitions.
- `hosts/jpporta-nixos/home.nix` — replace the WezTerm module import and `custom.wezterm.enable` setting with the Kitty module/import and enable setting.
- `modules/home-manager/hyprland/default.nix` — change Hyprland's configured terminal launcher from `wezterm` to `kitty`.

## Validation
- Command: `nix flake check`
- Command: `nixos-rebuild dry-build --flake ~/ndots#jpporta-nixos`
- Expected outcome: both commands complete successfully; the evaluated Home Manager configuration contains Kitty, Tiki, and Mermaid CLI; no WezTerm configuration or package remains in the selected host configuration; Hyprland's terminal launcher is `kitty`.

## Deployment
No deployment command is proposed in this stage. A separate human-approved deployment step is required after the implementation diff and validation output have been reviewed.

## Risks
- Replacing the terminal may temporarily remove the user's preferred terminal if Kitty configuration or package evaluation fails.
- Kitty configuration option names and behavior differ from WezTerm; unsupported options such as WezTerm's tab-bar setting may not have a literal one-to-one mapping.
- Changing the reusable Hyprland module's launcher affects any other host that later imports it.
- Tiki and Mermaid must remain available after the module rewrite; accidentally dropping either package would regress the existing workflow.
- The existing working tree contains unrelated staged changes; implementation must be limited to the files listed above and must not overwrite unrelated work.
- No deployment or switch should occur without review of the implementation and validation outputs.

## Rollback
Restore the affected files from the pre-change revision (or revert the dedicated change commit), then rerun the host's approved switch command:

```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```
