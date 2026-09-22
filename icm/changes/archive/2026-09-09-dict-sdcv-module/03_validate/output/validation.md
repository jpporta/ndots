# Validation — dict-sdcv-module

Date: 2026-09-09

## Result

Validation passed. Both iterations (module extraction + colorized output) build and behave
as planned when exercised from the built system closure.

## Commands

```sh
git diff --check
nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel -o /tmp/dict-test-result
```

Both passed (shellcheck inside `writeShellApplication` runs as part of the build).

## Behavior checks (from the built result, pre-deploy)

| check | result |
|---|---|
| TTY output colored per approved scheme (via `script` pty) | ✅ |
| Piped output byte-clean, no ANSI escapes | ✅ |
| `dict` (no args) → `usage: dict <word>`, exit 1 | ✅ |
| `dict zzzzqqq` (no match) → exit 0 (matches old script) | ✅ |
| Multi-entry results render with colors | ✅ |
| `sdcv` binary present in user env | ✅ |
| `git diff --check` | ✅ |

## Deployment status

Not deployed. Approved switch command (after deployment approval):

```sh
home-manager switch --flake ~/ndots#jpporta-nixos
# or the host's usual full switch:
sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos
```

Post-deploy note: the old unmanaged `~/.local/bin/dict` is already gone, so no shadowing
cleanup is needed.
