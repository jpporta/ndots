# Deploy — switch and verify behavior
One job: perform an approved switch and record observable behavior.

## Inputs
- Working: `../03_validate/output/validation.md` and approved deployment command.
- Reference: `../../../_shared/targets.md`, `../../../_shared/safety.md`.
- Do NOT deploy: a different host or an unapproved command.

## Process
1. Confirm human approval of the exact switch command.
2. Run it only for the selected target.
3. Verify the behavior promised by the plan.
4. Record the command, outcome, observed behavior, and rollback action if needed.

## Outputs
- `deployment.md` -> `output/`.

## Human check
Read `output/deployment.md`; if behavior is wrong, begin a corrective change rather than silently altering the record.
