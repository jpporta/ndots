# Shared references — stable configuration rules
One job: hold facts and constraints used by every change.

## Inputs
- Maintained facts about targets, deployment, safety, and external sources.

## Process
Update a reference only when its underlying stable fact changes.

## Outputs
- Reusable Markdown references consumed by change stages.

## Human check
Verify commands and source paths against the current flake before changing them.
