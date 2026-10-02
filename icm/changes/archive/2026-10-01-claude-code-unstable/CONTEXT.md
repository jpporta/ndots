# Change: Install claude-code from unstable with unfree allowed
One job: provide a four-stage, human-reviewed change record for claude-code installation via nixpkgs-unstable overlay.

## Inputs
- Shared targets: `../../_shared/targets.md`.
- Safety rules: `../../_shared/safety.md`.

## Process
1. Copied template to `icm/changes/2026-10-01-claude-code-unstable/`.
2. Work through `01_investigate/` to `04_deploy/` in order.
3. Preserve all output files as the record of the change.

## Outputs
- A complete reviewed record alongside the applied configuration change.

## Human check
Review each numbered stage output before starting the next one.
