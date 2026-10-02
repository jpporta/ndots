# Implementation — git review tooling

Plan approved 2026-09-01 (see `01_investigate/output/plan.md` approval section). Scope: delta, tig, lazygit config. Shuire removed from scope per approval.

## Changed paths

1. **`modules/home-manager/lazygit/default.nix`** (new)
   - `custom.lazygit.enable` option, following the `bat` module pattern.
   - `programs.lazygit`: enable + settings (`git.paging.pager = "delta --paging=never"`, `colorArg = "always"`, `gui.showRandomTip = false`).
   - Note: `programs.lazygit.enable` installs lazygit itself; `arch-packages` also lists it for both hosts — duplicate store paths are harmless and `arch-packages` was left untouched (writter-deck keeps its lazygit).

2. **`hosts/jpporta-nixos/home.nix`**
   - Added `../../modules/home-manager/lazygit` to imports.
   - Added `lazygit.enable = true;` to `custom`.
   - Added `delta` and `tig` to `home.packages`.

## Deviations from plan

- None beyond the approved shuire removal.

## Validation performed so far

- `nixfmt` run on both files (via `nix develop`).
- `nix build .#nixosConfigurations...system.build.toplevel` succeeds.
- `nix eval` confirms: `programs.lazygit.enable = true`, lazygit settings JSON matches plan, `delta` and `tig` present in `home.packages`.
- Tree was pre-dirty (waydroid, nvim, themes changes staged by earlier work); those files were not touched by this change.
- Change folder + new module staged with `git add` (flake requires files to be git-tracked to evaluate; nothing committed).

## Next

Awaiting human review of the source diff and this file before `03_validate`.
