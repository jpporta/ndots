# Investigate — define the safe change
One job: establish the target, current behavior, affected files, risks, and proposed change.

## Inputs
- Working: the user request and relevant current configuration files.
- Reference: `../../../_shared/targets.md`, `../../../_shared/safety.md`.
- Optional reference: `../../../_shared/external-sources.md`.
- Do NOT load: unrelated host files or external dotfiles not named by the request.

## Process
1. Identify the target and whether shared modules affect another host.
2. Read every likely affected source and relevant callers/imports.
3. Write the desired behavior, exact files, validation approach, deployment command, risks, and rollback path.

## Outputs
- `plan.md` -> `output/`.

## Human check
Read, edit, and approve `output/plan.md` before any configuration edit.
