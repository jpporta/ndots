# Deployment — scratchpad-terminal

Date: 2026-08-13

## Status

The requester confirmed that the corrected configuration is applied and working perfectly. No deployment command was run by this change record.

## Behavior

The scratchpad terminal opens successfully with the corrected key binding and behaves as intended.

## Rollback

If the deployed configuration behaves incorrectly, revert the change to `modules/home-manager/hyprland/default.nix` and reapply the host configuration, or boot the prior NixOS generation.
