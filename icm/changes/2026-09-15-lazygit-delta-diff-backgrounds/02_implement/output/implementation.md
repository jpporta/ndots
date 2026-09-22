# Implementation — Visible diff line backgrounds in lazygit via delta

Date: 2026-09-15

## Plan reference
`../01_investigate/output/plan.md` (approved 2026-09-15; shades: muted #1a4a1a / #5c1717).

## Changed paths
- `modules/home-manager/lazygit/default.nix` — `settings.git.diffRenderers[0].command`
  changed from `delta --dark --paging=never` to
  `delta --dark --paging=never --plus-style 'syntax "#1a4a1a"' --minus-style 'syntax "#5c1717"'`.

## Diff against prior state
```diff
-              command = "delta --dark --paging=never";
+              command = ''delta --dark --paging=never --plus-style 'syntax "#1a4a1a"' --minus-style 'syntax "#5c1717"' '';
```
This is the only source change; no other files touched.

## Behavior
- Added lines: syntax-highlighted foreground over visible dark green background
  `#1a4a1a` (verified prototype output: `48;2;26;74;26` + syntax fg codes).
- Removed lines: syntax-highlighted foreground over visible dark red background
  `#5c1717` (prototype: `48;2;92;23;23` + syntax fg codes).
- Word-level change emphasis and delta headers unchanged; no side-by-side mode,
  so lazygit staging/hunk selection remains compatible.

## Deviations from plan
None.
