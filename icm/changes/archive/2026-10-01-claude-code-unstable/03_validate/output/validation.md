# Validate — prove the target builds

## Validation Execution

### Command
```bash
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link
```

### Result
**Passed** (Exit status 0).
The `jpporta-nixos` system toplevel closure and Home Manager environment built successfully:
- Nixpkgs overlay for `unstable` loaded with `config.allowUnfree = true`.
- Derivation `/nix/store/65lbs8g0p3ysj1323m30rvpwsfbv3v40-claude-code-2.1.283.drv` built successfully to output path `/nix/store/yza50r609vpkrx4sdhk5lanz7fv08j4h-claude-code-2.1.283`.
- Home Manager path derivation `/nix/store/qxnni8l8m4n6awsn6jsyqscvaqw13vzm-home-manager-path.drv` built with no file collision.
- Binary execution check:
  ```bash
  /nix/store/yza50r609vpkrx4sdhk5lanz7fv08j4h-claude-code-2.1.283/bin/claude --version
  # Output: 2.1.283 (Claude Code)
  ```

### Unresolved Risk / Considerations
- Deployment (`nixos-rebuild switch`) activates the new system profile and user environment, which requires explicit human authorization.

## Proposed Deployment Command
```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```
(or `nixs`)
Awaiting human approval before running.
