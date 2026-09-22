# Plan — Extract sdcv + `dict` script into a Home Manager module

Date: 2026-09-09
Status: approved

## Approval — plan
- **Approved by:** jpporta
- **Granted:** "Approve plan (Recommended)" (questionnaire selection)
- **Date:** 2026-09-09 18:34
- **Scope:** the plan as written in this file; permission to proceed to implementation.

## Target
- Host: `jpporta-nixos` Home Manager configuration.
- Scope: new module `modules/home-manager/dict/default.nix` + import/enable in `hosts/jpporta-nixos/home.nix`.
- Shared module impact: `modules/home-manager/` is only imported by `jpporta-nixos`; `writter-deck` has its own module set and is unaffected.

## Current behavior
- `sdcv` is installed as a bare entry in `home.packages` (`hosts/jpporta-nixos/home.nix`, line ~162).
- The `dict` command is an unmanaged plain file at `~/.local/bin/dict` (not a Nix store symlink):

  ```bash
  #!/usr/bin/env bash
  # Offline dictionary lookup via sdcv, renders HTML articles to plain text
  [ $# -eq 0 ] && { echo "usage: dict <word>"; exit 1; }
  sdcv -n "$@" 2>/dev/null |
    sed -e 's/^Found \(.*\)$/Found \1<br>/' \
        -e 's/^-->\(.*\)$/<b>\1<\/b><br>' |
    pandoc -f html -t plain --wrap=none
  ```

- Its dependencies today: `sdcv` (from home.packages), `pandoc` and `sed` (pandoc installed via `modules/home-manager/arch-packages`; sed from the base system).

## Desired behavior
1. New module `modules/home-manager/dict/default.nix` with a `custom.dict.enable` option that, when enabled:
   - installs `pkgs.sdcv`;
   - creates the `dict` script declaratively with `pkgs.writeShellApplication`, using the exact same script text and flags (no behavior change), with `runtimeInputs = [ sdcv pandoc gnused ]` so all dependencies are pinned and on PATH.
2. `hosts/jpporta-nixos/home.nix`:
   - removes the bare `sdcv` entry from `home.packages`;
   - adds `../../modules/home-manager/dict` to `imports` and `dict.enable = true;` to the `custom` block.

## Behavior-preservation notes
- The script text is copied verbatim; `writeShellApplication` only adds pinned `PATH` and `set -eu -o pipefail` defaults. The pipeline's `2>/dev/null` and `exit 1` on no-args behave as before (the exit-code path runs before any set -e effect matters).
- `sed` is explicitly pinned to `gnused` (matches current behavior; the script uses GNU `sed` syntax).

## One-time post-deploy cleanup (outside configuration)
`~/.local/bin/dict` currently shadows the Nix-provided `dict` because `~/.local/bin` precedes `~/.nix-profile/bin` in `home.sessionPath`. After the first successful switch, delete the unmanaged file: `rm ~/.local/bin/dict`. Until then, the old script still runs — safe, no behavior change.

## Affected files
- `modules/home-manager/dict/default.nix` — new module (~25 lines).
- `hosts/jpporta-nixos/home.nix` — imports list, `custom` block, `home.packages` list.

## Validation
- `nix run home-manager -- switch -n --flake ~/ndots#jpporta-nixos` (dry run) or `nix build` evaluation proves it builds without switching.
- After an approved switch: `type dict` resolves to the Nix profile (after the cleanup step) and `dict <word>` produces the same formatted output as before.

## Deployment
After plan, implementation, and validation approvals:
`home-manager switch --flake ~/ndots#jpporta-nixos` (the host's usual Home Manager switch command).

## Risks and rollback
- Risk: `writeShellApplication`'s shellcheck/strict mode flags a construct in the copied script. Mitigation: the script is simple; verify with a dry build.
- Risk: stale unmanaged `~/.local/bin/dict` keeps shadowing the managed one. Mitigation: explicit cleanup step above; the old script is functionally identical in the meantime.
- Rollback: set `custom.dict.enable = false;` (or remove the import) and switch; the module contributes nothing when disabled.

## Human gate
Approve this plan before any configuration file is edited.

---

# Addendum — colorized output (iteration 2)

Date: 2026-09-09
Status: approved

## Request
Add color to the `dict` output: colored list numbers, section headers, and other
elements to improve readability. User: "Can you try something?"

## Approval — color addendum
- **Approved by:** jpporta
- **Granted:** "Approve as-is (Recommended)" (questionnaire selection), after reviewing a
  /tmp prototype demo of the exact scheme below
- **Date:** 2026-09-09 18:40
- **Scope:** apply the prototyped color scheme to `modules/home-manager/dict/default.nix`.

## Scheme (as prototyped and demonstrated)
| element | style |
|---|---|
| `Found N items…` line | dim gray (ANSI 2) |
| dict name + headword lines (former `-->` lines, marked with an `@@` sentinel) | bold magenta (1;35) |
| pronunciation lines (`UK: /…/`) | cyan (36) |
| section headers (standalone single capitalized word, e.g. Noun/Verb/Symbol) | bold cyan (1;36) |
| number list markers (`1.`, `2.`, …) | bold yellow (1;33) |
| lettered/roman list markers (`a.`, `i.`, …) | dim (2) |

## Behavior guarantees
- Coloring runs only when stdout is a TTY (`[ -t 1 ]`); piped output is byte-identical to
  the previous script's output.
- Lookup semantics unchanged; the color pass is a post-`pandoc` `sed` rendering step.
- No-args usage message and exit code unchanged.

## Affected files
- `modules/home-manager/dict/default.nix` — script `text` only; options/import/wiring unchanged.

## Validation
- Rebuild `nixosConfigurations.jpporta-nixos.config.system.build.toplevel`.
- Prototype was exercised for: TTY output (via `script`), piped output (no escapes),
  multi-entry results, no-args usage.
