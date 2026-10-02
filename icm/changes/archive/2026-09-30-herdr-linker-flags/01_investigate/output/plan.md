# Plan — fix herdr 0.9.1 linker failure during system upgrade

## Target
- Host: `jpporta-nixos` (Home Manager packages).
- Source: `modules/home-manager/arch-packages/default.nix`.

## Problem Statement
Following `nix flake update`, `nixpkgs-unstable` updated `herdr` to version `0.9.1` and the toolchain to GCC 16.2 / Binutils 2.46.
When building `herdr`, `rustc` invokes `ld.bfd` (binutils 2.46) to link against the vendored `libghostty-vt` (compiled with Zig 0.16).
During the creation of `.eh_frame_hdr`, `ld.bfd` detects overlapping Frame Description Entry (FDE) ranges between Zig and Rust object files and fails with:
```
ld.bfd: .eh_frame_hdr refers to overlapping FDEs
ld.bfd: final link failed: bad value
collect2: error: ld returned 1 exit status
```

## Trade-off Analysis: `.eh_frame_hdr`
- `.eh_frame` contains the Call Frame Information (CFI) necessary for unwinding the call stack (used in C++ exception handling, Rust panics, and backtrace generation).
- `.eh_frame_hdr` is an optional binary search table for `.eh_frame` that optimizes lookup time from linear $O(n)$ to logarithmic $O(\log n)$ during an unwind.
- Passing `-Wl,--no-eh-frame-hdr` skips emitting this lookup header table, but keeps `.eh_frame` intact in the final binary. The unwinder simply falls back to sequential traversal of `.eh_frame` if unwinding is needed. This is completely safe for CLI/TUI utilities like `herdr`.

## Scope & Impact
- Target: `jpporta-nixos` user environment.
- Impact on other hosts: None. `modules/home-manager/arch-packages` is imported only by `hosts/jpporta-nixos/home.nix`.
- Pre-existing git status: `flake.lock` has staged updates from the user's `nix flake update`.

## Proposed Change
In `modules/home-manager/arch-packages/default.nix`, override `herdr` from `nixpkgs-unstable` to pass `-C link-arg=-Wl,--no-eh-frame-hdr` via `RUSTFLAGS`:
```nix
  home.packages =
    (with inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
      (herdr.overrideAttrs (old: {
        env = (old.env or { }) // {
          RUSTFLAGS =
            (old.env.RUSTFLAGS or old.RUSTFLAGS or "") + " -C link-arg=-Wl,--no-eh-frame-hdr";
        };
      }))
    ])
    ++ (with pkgs; [
      # ...
    ]);
```
Note: Because `herdr` sets `__structuredAttrs = true`, `RUSTFLAGS` must be set inside the `env` attribute set, preserving any existing `old.env.RUSTFLAGS` or `old.RUSTFLAGS`.

## Validation Approach
1. Build the system configuration toplevel derivation without linking or switching:
   `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`
2. Verify that `herdr` builds cleanly and the entire toplevel configuration succeeds.
3. Test executing `herdr --version` from the built store path to confirm binary health.

## Deployment Command
Executed only upon explicit human approval:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`
(or via user alias `nixs`)

## Rollback Path
Remove the `overrideAttrs` block in `modules/home-manager/arch-packages/default.nix` to restore the original package reference.

## Approval — Plan
- **Approved by:** jpporta
- **Granted:** "please implement using the first strategy"
- **Date:** 2026-09-30 19:02
- **Scope:** Option 1 — override herdr in modules/home-manager/arch-packages/default.nix with `-C link-arg=-Wl,--no-eh-frame-hdr`.
