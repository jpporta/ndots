# Validate — prove the target builds

## Validation Execution

### Command
```bash
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link
```

### Result
**Passed** (Exit status 0).
The `jpporta-nixos` system toplevel closure built successfully:
- `herdr-0.9.1` linked and built without error when passing `-Wl,--no-eh-frame-hdr`.
- `vboxnet0.service` includes `X-StopIfChanged=false` and `X-RestartIfChanged=false`.
- Binary sanity check: `/nix/store/ngn1w6whq15rcayhdgpprify8yjcr3is-herdr-0.9.1/bin/herdr --version` prints `herdr 0.9.1`.

### Unresolved Risk / Considerations
- Deployment (switch) reconfigures live services and requires human authorization.

## Proposed Deployment Command
```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```
(or `nixs`)
Awaiting human approval before running.
