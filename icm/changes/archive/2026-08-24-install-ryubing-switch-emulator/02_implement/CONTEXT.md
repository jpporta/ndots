# Implement — make the approved edit
One job: apply only the approved configuration change.

## Inputs
- Working: `../01_investigate/output/plan.md`.
- Reference: `../../../_shared/targets.md`, `../../../_shared/safety.md`.
- Do NOT load: unrelated changes or unapproved external configuration.

## Process
1. Verify the plan is approved.
2. Edit the exact configuration sources named in the plan.
3. Inspect the final diff and record changed paths, behavior, and intentional deviations from the plan.

## Outputs
- `implementation.md` -> `output/`.

## Human check
Review the source diff and `output/implementation.md` before validation.
