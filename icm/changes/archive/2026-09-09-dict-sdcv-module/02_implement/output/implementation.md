# Implementation — dict-sdcv-module

Date: 2026-09-09
Status: implemented — awaiting diff review and validation.

## Changes

| path | change |
|---|---|
| `modules/home-manager/dict/default.nix` | new module: `custom.dict.enable`; installs `pkgs.sdcv` and the `dict` script via `pkgs.writeShellApplication` |
| `hosts/jpporta-nixos/home.nix` | import `../../modules/home-manager/dict`; add `dict.enable = true;` to the `custom` block; remove bare `sdcv` from `home.packages` |

## Script content

The `dict` script text is copied verbatim from `~/.local/bin/dict` (only the shebang line is
dropped; `writeShellApplication` provides it). Dependencies are pinned through
`runtimeInputs = [ sdcv gnused pandoc ]`. `gnused` is chosen explicitly to keep the GNU `sed`
syntax used by the original.

## Intentional deviations from the plan

- None. (One intermediate typo — an undefined `sdcv-pkg` binding — was caught and fixed
  during the edit; the final file uses `pkgs.sdcv`.)

## Final diff

`git diff hosts/jpporta-nixos/home.nix` shows exactly three edits (import, enable, package
removal); the module is a new untracked file.

## Runtime note (unchanged)

The unmanaged `~/.local/bin/dict` still shadows the Nix-provided one until removed
(`rm ~/.local/bin/dict`) after the first switch; the plan documents this as a one-time
post-deploy cleanup.

---

# Iteration 2 — colorized output

Date: 2026-09-09
Status: implemented — awaiting review/validation.

## Changes
| path | change |
|---|---|
| `modules/home-manager/dict/default.nix` | script `text` only: TTY detection (`[ -t 1 ]`), `@@` sentinel on entry-header lines, post-`pandoc` colorizing `sed -E` pass; `coreutils` added to `runtimeInputs` for `cat` |

## Color scheme (as approved, from the /tmp prototype demo)
- `Found N items…` → dim gray; entry headers (dict name + headword) → bold magenta;
  pronunciation lines (`UK: /…/`) → cyan; section headers (Noun/Verb/Symbol…) → bold cyan;
  number markers → bold yellow; lettered/roman markers → dim.

## Intentional deviations from the original script
- One deliberate exit-code fix: `{ sdcv … || true; }` wraps the sdcv call so `pipefail`
  doesn't propagate sdcv's exit 2 on no-match — the old script's exit code came from
  `pandoc` (0), and the new script now matches that. Verified: `dict zzzzqqq` → exit 0.

## Validation exercised (via built result)
- TTY output colored (via `script` pty); piped output byte-clean (no escapes);
  no-args → `usage: dict <word>`, exit 1; no-match → exit 0 (matches old behavior);
  multi-entry results render correctly; shellcheck passes inside `writeShellApplication`.
