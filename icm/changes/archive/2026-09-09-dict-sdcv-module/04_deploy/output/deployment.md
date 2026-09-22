# Deployment — dict-sdcv-module

Date: 2026-09-09

## Status

Deployed and behavior confirmed by the owner.

## Approval — deployment

- **Approved by:** jpporta
- **Granted:** "working perfectly, please archive the change all success"
- **Date:** 2026-09-09 18:55
- **Scope:** confirms the switch was applied and the post-deploy behavior is correct.

## Command run

```sh
home-manager switch --flake ~/ndots#jpporta-nixos
```

(run by the owner; not executed by this change record)

## Behavior observed (owner-confirmed)

- `dict <word>` renders the sdcv article as plain text with the approved color scheme on a
  TTY (dim found-line, bold magenta entry headers, cyan pronunciation, bold cyan section
  headers, bold yellow number markers, dim lettered/roman markers).
- Piped output stays plain (no ANSI escapes); usage and exit codes match the original script.
- `sdcv` is installed via the module; the bare entry is gone from `home.packages`.

## Rollback

Set `custom.dict.enable = false;` (or remove the module import) in
`hosts/jpporta-nixos/home.nix` and switch again; the module contributes nothing when
disabled. The prior generation is also bootable/selectable as usual.
