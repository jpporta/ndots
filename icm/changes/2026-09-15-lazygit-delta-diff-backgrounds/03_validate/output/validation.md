# Validation — Visible diff line backgrounds in lazygit via delta

Date: 2026-09-15

## Command run
```
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link
```
(Flake does not expose `homeConfigurations.jpporta-nixos`; Home Manager for this
host is a NixOS module, so the system toplevel is the correct build target.
Plan's `nix build .#homeConfigurations...` path was adapted accordingly.)

## Result
- **Success.** Exit code 0; only warning: `Git tree '/home/jpporta-ndots' is dirty`
  (expected — uncommitted work in the tree, including this change).
- The toplevel closure built: `/nix/store/ijdgg5imcpbwcg65y152qkimfllym15c-nixos-system-jpporta-nixos-26.05.20260803.531670d`.

## Generated-config verification
The built lazygit config contains exactly the approved renderer command:
```yaml
git:
  diffRenderers:
  - command: 'delta --dark --paging=never --plus-style ''syntax "#1a4a1a"'' --minus-style ''syntax "#5c1717"'' '
```

## Pre-deploy behavior check
`git diff HEAD | delta --dark --paging=never --plus-style 'syntax "#1a4a1a"' --minus-style 'syntax "#5c1717"'`
emits added-line backgrounds `48;2;26;74;26` (`#1a4a1a`) and removed-line
backgrounds `48;2;92;23;23` (`#5c1717`) with syntax foreground colors preserved.

## Warnings / unresolved risks
- Final look (shade contrast on the user's palette) can only be judged after the
  switch; if the user dislikes the shades, only the two hex values change.
- None otherwise.

## Awaiting
Human approval of the deployment command before switching.

## Approval — deployment
- **Approved by:** jpporta
- **Granted:** "Approve switch (Recommended)" (questionnaire selection)
- **Date:** 2026-09-15
- **Scope:** `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
