# Validation — `pi-coding-agent` from nixpkgs-unstable

## Commands run
- `pi -v` → `0.84.1`

That is the only check performed. The plan also proposed `nix flake check`, dry builds for both hosts, and a `nix eval` to confirm the resolved version. None of those were run.

## Result
- Resolved pi is `0.84.1`, well above the prior `0.75.4` from `nixos-26.05` and above the `pi-ai ≥ 0.80.0` threshold needed by the `@earendil-works/pi-ai/compat` subpath. The motivation for the switch is satisfied.
- Store path in use: `/nix/store/ig3fiihiz12y0n91611ygqjng4h4q2m5-pi-coding-agent-0.84.1/bin/pi`. Confirms the binary in the user profile is the unstable build, not a leftover stable one.

## Gaps vs the plan
- No `nix flake check` — schema/lock drift, if any, was not surfaced.
- No dry build for `jpporta-nixos` or `jpporta-deck`. The deck path was never re-resolved under the new `nixpkgs-unstable` input.
- No `nix eval` confirming the package actually sources from `inputs.nixpkgs-unstable` rather than `pkgs`. The store-path evidence above makes this very likely but does not prove it from the flake side.
- No check that the pinned extensions (`pi-subagents@0.34.0`, `pi-web-access@0.10.7`) still load. The original motivation was to drop the workarounds; that follow-up was not exercised.

## Unresolved risk
Thin validation. A flake-lock or extra-special-args mistake would not be caught by `pi -v` alone. Acceptable here because the change is small, the store path matches the unstable version, and the user opted to skip the heavier checks.

## Next
Stage 04 (`deploy`) — see `04_deploy/output/deployment.md`. No formal switch command is being issued as part of this change.