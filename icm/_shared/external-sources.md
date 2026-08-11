# External configuration sources

## dotfiles repository
- Path: `/home/jpporta/dotfiles`.
- Role: read-only inspiration and source material, not an active configuration source.
- Use: inspect only the files relevant to an approved change plan, then re-express the desired behavior through `hosts/` or `modules/`.
- Do not: copy the repository wholesale, introduce a second source of truth, or move its files without a separate approved migration change.

## Deferred sources
- Homelab configuration is outside this workspace until a future approved host-onboarding change.
