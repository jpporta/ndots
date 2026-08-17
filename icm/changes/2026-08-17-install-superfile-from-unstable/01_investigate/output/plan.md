# Plan — install Superfile from nixpkgs unstable

## Target
- Host: `jpporta-nixos` user environment.
- Source: `hosts/jpporta-nixos/home.nix`, which is evaluated by the NixOS flake output and Home Manager.
- Impact: only `jpporta-nixos`; the shared `modules/home-manager/arch-packages` module is not changed, so `jpporta-deck` is unaffected.

## Current state and diagnosis
- `superfile` is present twice in the `jpporta-nixos` Home Manager package set:
  - `modules/home-manager/arch-packages/default.nix` contains `superfile` under `with pkgs;`, which is the stable package set.
  - `hosts/jpporta-nixos/home.nix` contains `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.superfile`.
- Both derivations have the same `superfile-1.3.3/bin/superfile` path, so Home Manager's `buildEnv` rejects the conflicting paths. The reported error confirms this exact duplicate-package cause.
- The previous plan incorrectly treated the working tree as if the stable entry had already been removed. It had not been removed.
- The current worktree contains unrelated edits and an existing ICM change for SLK; those must not be mixed into this change.

## Proposed change
- Remove the stable `superfile` entry from `modules/home-manager/arch-packages/default.nix`.
- Keep the explicit unstable `superfile` entry in `hosts/jpporta-nixos/home.nix` using `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.superfile`.
- Do not change the flake inputs or update the lock file as part of this request.

## Validation
- Format/check the changed Nix files.
- Evaluate `.#nixosConfigurations.jpporta-nixos.config.home-manager.users.jpporta.home.packages` and confirm only one `superfile` package remains and that its store path comes from `nixpkgs-unstable`.
- Build the target without switching: `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel`.
- Only after a successful build, retry the approved switch command.

## Deployment
After validation and explicit human approval of the exact command:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback
- Risk: an unstable package may introduce dependency or evaluation changes. The target build should catch evaluation/build failures before deployment.
- Rollback: do not switch if validation fails; if switched and behavior is wrong, use the prior NixOS generation via `sudo nixos-rebuild switch --rollback` and revert this source change.

## Human gate
Approve this plan before any configuration edit. The plan intentionally excludes the pre-existing flake, host, module, Neovim, and ICM changes unrelated to this request.
