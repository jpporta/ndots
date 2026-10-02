# Validate — build and derivation verification

## Validation Execution

### 1. Build Verification
Command:
```bash
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link
```
Result: **Success** (built all 8 derivations without errors).

### 2. Service Unit Inspection
Inspected `/nix/store/70icii48wg0i99w9jd66bd3q0dqn4b4w-lan-mouse.service`:
```ini
[Install]
WantedBy=graphical-session.target

[Service]
ExecStart=/nix/store/f5zag9q2aqqv030cn9j989blnzmvjfw5-lan-mouse-0.11.0/bin/lan-mouse daemon
Restart=on-failure
RestartSec=1
Type=simple

[Unit]
After=graphical-session.target
Description=Lan Mouse daemon
PartOf=graphical-session.target
```
Verified that the binary executes cleanly:
```bash
/nix/store/f5zag9q2aqqv030cn9j989blnzmvjfw5-lan-mouse-0.11.0/bin/lan-mouse --version
# Output: lan-mouse 0.11.0
```

### 3. Unresolved Risks
- DTLS mutual key authorization: Upon the first connection between the host and MacBook, each machine must authorize the other's fingerprint.
- Running switch command requires `sudo` privileges.

## Proposed Deployment Command
```bash
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```
Awaiting human approval before running this command.
