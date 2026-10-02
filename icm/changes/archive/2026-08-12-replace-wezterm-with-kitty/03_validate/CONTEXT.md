# Validate — prove the target builds
One job: run the approved pre-deployment checks and record their result.

## Inputs
- Working: `../01_investigate/output/plan.md`, `../02_implement/output/implementation.md`.
- Reference: `../../../_shared/targets.md`, `../../../_shared/safety.md`.
- Do NOT deploy: use a build/check command first when the target supports it.

## Process
1. Run the plan's validation command for the selected target.
2. Record the command, result, warnings, and unresolved risk.
3. If validation fails, return to implementation and update its record.

## Outputs
- `validation.md` -> `output/`.

## Human check
Read `output/validation.md` and explicitly approve the deployment command before deployment.
