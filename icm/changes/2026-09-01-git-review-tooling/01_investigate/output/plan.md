# Plan — git review tooling (delta, tig, lazygit config)

## Approval — plan
- **Approved by:** jpporta
- **Granted:** "forget about shuire, but install everything else, delta + tig + lazygit config"
- **Date:** 2026-09-01
- **Scope:** plan as written, with shuire removed from scope (deviation noted in implementation.md).

## Goal

Improve the terminal git-review experience for auditing AI-generated atomic commits:

- `lazygit` already installed — add config (delta pager, quiet tips).
- Install `delta` (diff pager used by lazygit) — currently not installed.
- Install `tig` (read-only history browser) — currently not installed.
- Install `shuire` — **removed from scope at plan approval** (upstream repo gone; user opted out).

## Target

- Host: **jpporta-nixos** user environment (Home Manager).
- Sources: `hosts/jpporta-nixos/home.nix`, new module `modules/home-manager/lazygit/default.nix`.
- Build/switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.

## Current behavior

- `lazygit`, `git`, `gh` come from the shared module `modules/home-manager/arch-packages/default.nix` (also used by `writter-deck`). No lazygit config exists (`programs.lazygit` unset anywhere).
- `programs.git` is configured in `hosts/jpporta-nixos/home.nix`; no pager setting.
- `delta`, `tig`, `shuire` absent.
- `shuire` upstream GitHub repo is gone (404); it is distributed via npm as `shuire` with per-platform binary packages (`shuire-linux-x64` 0.2.0). The prebuilt binary is dynamically linked and needs `autoPatchelfHook` + `stdenv.cc.cc.lib`. Verified working locally with a test build.

## Proposed change

1. **New module `modules/home-manager/lazygit/default.nix`** following the `bat` module pattern:
   - `custom.lazygit.enable` option.
   - `programs.lazygit.enable = true` with settings:
     ```yaml
     git:
       paging:
         colorArg: always
         pager: delta --paging=never
     gui:
       showRandomTip: false
     ```
2. **`hosts/jpporta-nixos/home.nix`**:
   - import `../../modules/home-manager/lazygit`, enable via `custom.lazygit.enable = true;`
   - add `delta` and `tig` to `home.packages` (host-local, not the shared arch-packages module).
3. **Impact on other hosts**: none. The new module is opt-in and only enabled on jpporta-nixos; `arch-packages` is untouched.

## Validation

1. `nix flake check` / build succeeds: `sudo nixos-rebuild build --flake ~/ndots#jpporta-nixos` (dry run before switch).
2. `lazygit` starts in a git repo and diffs render via delta.
3. `tig` opens the log view.

## Risks & rollback

- Low risk: additive packages + one new opt-in module. No existing module modified except `home.nix` (import + package list entries).
- Rollback: `sudo nixos-rebuild switch --rollback`, or `git revert` the change commit.
- Removal path (user-requested follow-up): whichever tools go unused get deleted in a later change; delta and tig are purely additive so removal is a two-line diff.

## Explicitly deferred

- Removing any existing tooling ("remove what is not being used") — separate later change once a trial period has passed.
