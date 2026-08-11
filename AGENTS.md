# ndots
NixOS and Home Manager configuration with an ICM change process.

## Where things live
| Path | What it holds |
|---|---|
| `flake.nix` | Host outputs and development shell |
| `hosts/` | Host-specific NixOS and Home Manager configuration |
| `modules/` | Reusable NixOS and Home Manager modules |
| `icm/` | Change process, references, templates, and change records |
| `openspec/` | Previous change process; retained during the ICM trial |
| `tooling/` | Existing development tooling |

## Route by request
| If the request concerns | Read first | Then stop at |
|---|---|---|
| starting or continuing a configuration change | `icm/changes/CONTEXT.md` | the required human gate |
| NixOS system configuration | `icm/_shared/targets.md` | human-approved deployment |
| Home Manager configuration | `icm/_shared/targets.md` | human-approved deployment |
| importing an old dotfile | `icm/_shared/external-sources.md` | approved change plan |
| current change status | `icm/changes/CONTEXT.md` | report stage outputs that exist |
| process rules | `icm/CONTEXT.md` | the applicable contract |

## One rule
Do not edit configuration, run a deployment, or import external dotfiles until the prior stage output has been reviewed by a person.
