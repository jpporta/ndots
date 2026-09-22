# Plan — Visible diff line backgrounds in lazygit via delta

Date: 2026-09-15
Status: approved

## Approval — plan
- **Approved by:** jpporta
- **Granted:** "Before approving confirm if the file syntax highlight will also be enabled, if so please go ahead" (questionnaire answer; syntax highlighting confirmed kept via the `syntax` style keyword and prototype output), with shade choice "Muted" (#1a4a1a / #5c1717)
- **Date:** 2026-09-15
- **Scope:** the plan as written in this file; permission to proceed to implementation.

## Target
- Host: `jpporta-nixos` Home Manager configuration.
- Scope: `modules/home-manager/lazygit/default.nix` only (one command string).
- Shared module impact: `modules/home-manager/lazygit` is imported only by `hosts/jpporta-nixos/home.nix` (`lazygit.enable = true`). `writter-deck` installs lazygit as a bare package without this module and is unaffected.

## Current behavior
- Lazygit diffs are already rendered through delta via `git.diffRenderers`:
  `delta --dark --paging=never` (deployed, matching the staged working tree).
- Delta's default dark theme paints whole diff lines, but with backgrounds that are
  nearly invisible: added lines `#002800`, removed lines `#3f0001` (verified by
  piping `git diff HEAD` through the exact command lazygit runs and inspecting the
  ANSI output: `48;2;0;40;0` / `48;2;63;0;1`).
- Result: the diff reads as plain green/red text with no obvious line highlighting,
  which is what the user reported.

## Desired behavior
- Added lines highlighted with a clearly visible dark green background
  (`#1a4a1a`), removed lines with a clearly visible dark red background
  (`#5c1717`), keeping delta's syntax highlighting and word-level emphasis.
- Implemented purely in the delta command line, so no gitconfig changes and no
  new packages (delta 0.19.2 already installed).

## Proposed change (single line)
In `modules/home-manager/lazygit/default.nix`, change the renderer command from:

```nix
command = "delta --dark --paging=never";
```

to:

```nix
command = ''delta --dark --paging=never --plus-style 'syntax "#1a4a1a"' --minus-style 'syntax "#5c1717"' '';
```

Prototype verified: the new command emits line backgrounds `48;2;26;74;26` (added)
and `48;2;92;23;23` (removed) while preserving syntax foreground colors.

## Behavior guarantees
- Only rendering changes; lazygit still parses the raw diff for staging, hunk
  selection, discarding, etc. No side-by-side mode (keeps staging compatible).
- Only two style flags added; all other delta behavior (headers, syntax theme,
  dark mode) unchanged.

## Affected files
- `modules/home-manager/lazygit/default.nix` — the `diffRenderers[0].command` string.

## Validation
- `nix build .#homeConfigurations.jpporta-nixos.activationPackage --no-link` (or an
  equivalent dry-run switch) proves the Home Manager config evaluates/builds.
- After an approved switch: open lazygit, view a diff with added and removed
  lines, and confirm visible green/red line backgrounds in the diff and staging views.

## Deployment
After plan, implementation, and validation approvals:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos` (the host's Home Manager
configuration switches as part of the NixOS rebuild).

## Risks and rollback
- Risk: chosen background shades reduce contrast with syntax-highlighted text on
  some palettes. Mitigation: shades were kept dark; if the user dislikes them, we
  iterate on the two hex values only (no structural change).
- Risk: HM's lazygit settings formatting. Mitigation: `settings.git.diffRenderers`
  is existing YAML-mapped config; a dry-run build catches issues.
- Rollback: revert the command string to `delta --dark --paging=never` and switch;
  behavior returns to the current state.

## Human gate
Approve this plan before any configuration file is edited.
