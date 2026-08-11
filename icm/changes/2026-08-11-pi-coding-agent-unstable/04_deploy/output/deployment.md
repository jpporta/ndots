# Deployment — `pi-coding-agent` from nixpkgs-unstable

## Command run
None. The plan listed `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos` and a follow-up `home-manager switch --flake ~/ndots#jpporta-deck`. Neither was issued as part of this change. The user's stated position: the local switch had already been performed before the change record caught up, and pushing to `origin/main` is the deployment boundary.

## State at record time
- Working tree clean; `HEAD` is `2f0489a` ("updates") containing the two-file diff from `02_implement/output/implementation.md`.
- Branch `main` is up to date with `origin/main`. No commits are pending push.
- `which pi` → `/etc/profiles/per-user/jpporta/bin/pi` → `/nix/store/ig3fiihiz12y0n91611ygqjng4h4q2m5-pi-coding-agent-0.84.1/bin/pi`.
- `pi -v` → `0.84.1`.

## Observed behavior
- pi runs at the unstable version expected from the plan.
- No `/compat` import errors observed during this session — consistent with `pi-ai ≥ 0.80.0` being bundled.
- Extensions (`pi-subagents`, `pi-web-access`) were not exercised in this session; their post-bump load status is unverified.

## Deck host
No action taken. `jpporta-deck` was already on `nixos-unstable` via `nixpkgs-deck`, so net behavior there is unchanged. Re-running `home-manager switch --flake ~/ndots#jpporta-deck` is safe but not required by this change.

## Failures
None observed.

## Rollback
Per the plan, revert the two files (`flake.nix`, `modules/home-manager/pi/default.nix`) and re-run `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`. If the extension workarounds (`pi-subagents@0.34.0`, `pi-web-access@0.10.7`) had been removed in a follow-up by this point, reinstall them first; for the current commit they are still in place.

## Follow-ups (not part of this change)
- Drop the extension version pins once the new pi-ai is confirmed to satisfy the `/compat` consumer.
- Consider collapsing `nixpkgs-deck` and the new `nixpkgs-unstable` into a single input if both pinning to `nixos-unstable` is intentional.