# Changes — one reviewed configuration change
One job: hold active and completed change records.

## Inputs
- Template: `../_templates/change/`.
- References: `../_shared/targets.md` and `../_shared/safety.md`.
- Do NOT load: other change folders unless explicitly comparing a prior solution.

## Process
1. Copy `../_templates/change/` to `YYYY-MM-DD-change-name/`.
2. Replace the placeholder name in the copied files.
3. Execute numbered stages in order; leave every output as an editable Markdown file.

## Outputs
- `YYYY-MM-DD-change-name/` with one completed output per stage.

## Status
- No `01_investigate/output/plan.md`: not investigated.
- Plan only: awaiting plan approval.
- `02_implement/output/implementation.md`: awaiting diff approval or validation.
- `03_validate/output/validation.md`: awaiting deployment approval.
- `04_deploy/output/deployment.md`: deployed and behavior checked.

## Human check
Confirm the folder name and latest output accurately represent the change before reporting its status.
