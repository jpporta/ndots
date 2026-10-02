# Plan: install `slk` Slack TUI on `jpporta-nixos`

## Target
- Host: `jpporta-nixos` (`hosts/jpporta-nixos/home.nix`), the NixOS system's Home Manager user environment on `x86_64-linux`.
- The target imports the shared `modules/home-manager/arch-packages` module, but that module is only used by `jpporta-nixos` in the current flake, so the proposed package addition affects no other configured host.

## Current state
- `slk` is not present in the `jpporta-nixos` Home Manager package list.
- The official `pkgs.slack` desktop package is already present in the shared `arch-packages` module. This request is for the separate `gammons/slk` terminal Slack client/TUI.
- The requested `slk` is `gammons/slk`, a Go-based terminal Slack client/TUI. Its upstream flake exports `packages.slk` and supports `x86_64-linux`.
- `slk` obtains workspace authentication from a signed-in Slack desktop app. Installing the binary does not itself authenticate it; first-run setup may require an existing supported Slack desktop session or another upstream-supported setup path.

## Desired behavior
After an approved NixOS/Home Manager switch on `jpporta-nixos`, the `slk` executable is available to user `jpporta` on the host's `PATH`.

## Proposed edit
1. Add a `slk` flake input pointing at `github:gammons/slk` in `flake.nix`.
2. Pass the input through the existing `extraSpecialArgs` used by `jpporta-nixos` Home Manager.
3. Add `inputs.slk.packages.${pkgs.system}.default` to `hosts/jpporta-nixos/home.nix`.

No secrets, Slack tokens, desktop configuration, or authentication files will be added to the repository.

## Validation
- Evaluate/build the target configuration:
  `nix build --no-link --print-out-paths .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel`
- Confirm the package is included and the executable exists from the built closure, without running a switch.

## Deployment
Only after validation and explicit approval, run:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback
- Upstream `slk` is a moving flake input; pinning the flake lock makes the installed revision reproducible, but upstream may change its package interface or build requirements.
- The upstream package builds Go code and may take time or fail if its current source is incompatible with the pinned nixpkgs revision.
- Authentication/session setup is separate from installation and may not work without a Slack desktop session.
- Rollback: revert the `slk` input/package additions and run the same approved NixOS switch; the previous NixOS generation remains available through the boot menu or `nixos-rebuild switch --rollback` if needed.
