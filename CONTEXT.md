# ndots configuration workspace
One job: keep machine configuration and its reviewed change process together.

## Form
This is an umbrella ICM. `hosts/` and `modules/` are the configuration product; `icm/` is the reusable process for changing it.

## Scope
- Managed now: `jpporta-nixos` NixOS and Home Manager, plus `jpporta-deck` Home Manager.
- Reference only: `/home/jpporta/dotfiles`.
- Deferred: secrets management and homelab configuration.

## Status
Status is derived from the newest output file within each `icm/changes/*/` change folder. A deployment is complete only when `04_deploy/output/deployment.md` records behavior verification.

## Human gates
1. Review `01_investigate/output/plan.md` before implementation.
2. Review the configuration diff before validation.
3. Approve the switch command before deployment.
4. Review the observed behavior after deployment.
