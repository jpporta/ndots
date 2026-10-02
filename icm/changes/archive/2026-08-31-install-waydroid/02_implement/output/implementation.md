# Implementation — Install Waydroid on jpporta-nixos

Date: 2026-08-31
Status: awaiting diff review
Plan: `../../01_investigate/output/plan.md` (approved by user)

## Changes made

1. **New file** `modules/nixos/waydroid/default.nix`
   - Declares `custom.waydroid.enable` (`mkEnableOption`), same pattern as the other `modules/nixos/*` modules.
   - When enabled: `virtualisation.waydroid.enable = true;` and `virtualisation.waydroid.package = pkgs.waydroid-nftables;` (newer-kernel variant per NixOS Wiki).

2. **Edited** `hosts/jpporta-nixos/configuration.nix` (2 added lines)
   - `imports`: added `../../modules/nixos/waydroid`
   - `custom` block: added `waydroid.enable = true;`

## Changed paths
- `modules/nixos/waydroid/default.nix` (new, 20 lines)
- `hosts/jpporta-nixos/configuration.nix` (+2)

## Deviations from plan
None.

## Notes
- The `themes/dracula_wallpapers` submodule shows as modified in `git diff --stat`; pre-existing, unrelated to this change, untouched.
- Runtime steps after deploy (per plan, not configuration): `sudo waydroid init -s GAPPS -f`, `sudo systemctl start waydroid-container`, `waydroid session start`, `waydroid show-full-ui`.

## Diff
```
diff --git a/hosts/jpporta-nixos/configuration.nix b/hosts/jpporta-nixos/configuration.nix
@@ -18,6 +18,7 @@
     ../../modules/nixos/wake-on-lan
     ../../modules/nixos/hermes
     ../../modules/nixos/ollama
+    ../../modules/nixos/waydroid
   ];
@@ -135,6 +136,7 @@
     tailscale.enable = true;
     wake-on-lan.enable = true;
     hermes.enable = true;
+    waydroid.enable = true;
     keyd = {
```
Plus new file `modules/nixos/waydroid/default.nix` (see working tree).

## Human gate
Review the source diff and this record before validation.
