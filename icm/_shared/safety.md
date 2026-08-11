# Configuration safety rules

## Required gates
1. Investigate affected source files and write a plan before editing.
2. A person approves the plan before edits begin.
3. A person reviews the configuration diff before validation.
4. Validate the selected target before a switch.
5. A person explicitly approves the switch command.
6. Record post-switch behavior, including failures and rollback action if needed.

## Boundaries
- Never store secret values in this repository or change records.
- `pass` remains the secret source for scripts until a dedicated secret-management change is approved.
- Do not deploy to a host other than the target named in the approved plan.
- Do not import external dotfiles directly; translate one reviewed concern at a time into the current Nix structure.
