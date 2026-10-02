# Plan — install leaf, ghgrab, tuxedo, and kew on jpporta-nixos

## Target
- Host: `jpporta-nixos` user environment only.
- Source: `hosts/jpporta-nixos/home.nix` (imports `modules/home-manager/arch-packages`, which is shared with `jpporta-deck` and therefore must not be edited).
- New file: `modules/home-manager/leaf/default.nix` (a new module, imported only by `hosts/jpporta-nixos/home.nix`, so `jpporta-deck` is unaffected).

## Program research
| Program | What it is | Availability |
|---|---|---|
| `leaf` | RivoLink terminal Markdown previewer (https://leaf.rivolink.mg, github.com/RivoLink/leaf), Rust, v1.28.2 | NOT in nixpkgs. Note: nixpkgs `leaf` is an unrelated, removed "system fetch" package — do not use it. |
| `ghgrab` | Terminal tool to search and download files from GitHub, v2.0.1 | nixpkgs stable and unstable both have 2.0.1. |
| `tuxedo` | Keyboard-driven TUI for todo.txt (webstonehq/tuxedo) | nixpkgs stable: absent; flake input `nixpkgs-unstable`: 2026.7.1. |
| `kew` | Terminal music player | nixpkgs stable 4.0.0; unstable 4.2.7. |

## Proposed change
1. Create `modules/home-manager/leaf/default.nix` — a `custom.leaf.enable` option packaging `leaf-markdown-viewer` 1.28.2 with `rustPlatform.buildRustPackage` from the GitHub release tag `1.28.2` (`cargoLock.lockFile` from the repo's `Cargo.lock`, source hash `sha256-WX9C4gWNPCHWFsHN4xFmShv6dJyYAVgr9xMw5JtoFHI=`). No git dependencies in the lock file, so no `outputHashes` needed.
2. Import the new module in `hosts/jpporta-nixos/home.nix` and set `custom.leaf.enable = true`.
3. In `hosts/jpporta-nixos/home.nix` `home.packages`, add:
   - `ghgrab` (stable nixpkgs)
   - `kew` (stable nixpkgs)
   - `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tuxedo` (following the existing `superfile` pattern)
   - the `leaf` package from the new module's output.

## Pre-flight verification already done
- `leaf-markdown-viewer` 1.28.2 builds successfully from GitHub with `rustPlatform.buildRustPackage` (trial build in /tmp produced a working `leaf 1.28.2` binary).
- `nixpkgs#ghgrab.version` = 2.0.1; `nixpkgs#kew.version` = 4.0.0; flake `nixpkgs-unstable#tuxedo.version` = 2026.7.1.

## Out of scope
- Existing uncommitted work in the tree (dict module, home.nix edits, waydroid/dict change records) is left untouched; this change adds only the lines described above.
- No flake input changes, no lock-file updates, no shared-module edits.

## Validation
- `nix fmt` / format check on changed files.
- Evaluate that the four binaries resolve: `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel` (build without switching), then confirm `leaf --version`, `ghgrab --version`, `tuxedo --version`, `kew --version` paths exist in the built closure.

## Deployment
After validation and explicit human approval of the exact command:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

## Risks and rollback
- Risk: `leaf` is packaged locally here, so it will not receive nixpkgs updates automatically; updating means bumping the `rev`/version in the new module.
- Risk: `tuxedo` comes from unstable; the toplevel build catches evaluation/build failures before switching.
- Risk: `kew` uses audio (PipeWire/ALSA); on this host PipeWire is already configured, so no system change is expected.
- Rollback: if behavior is wrong after the switch, `sudo nixos-rebuild switch --rollback` and revert the source change.

## Human gate
Approve this plan before any configuration edit.

## Approval — plan
- **Approved by:** jpporta (conversation owner)
- **Granted:** "approved, please implement"
- **Date:** 2026-09-17 15:36
- **Scope:** the investigate-stage plan for installing leaf, ghgrab, tuxedo, and kew on jpporta-nixos only
