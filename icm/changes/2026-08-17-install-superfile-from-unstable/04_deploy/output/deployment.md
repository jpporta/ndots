# Deployment — install Superfile from nixpkgs unstable

## Approved command
```text
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

## Outcome
The command was attempted after validation, but could not run in this non-interactive session:

```text
sudo: a terminal is required to read the password; either use the -S option or configure an askpass helper
sudo: a password is required
```

No deployment occurred. The system was not changed and no rollback was needed.

## Required manual action
Run the approved command from an interactive terminal:

```bash
cd ~/ndots
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

After it completes, verify that Superfile is available:

```bash
command -v superfile
superfile --version
```

Record the result here after the interactive switch.
