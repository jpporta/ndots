# Implementation — install claude-code from unstable with unfree allowed

## Applied Changes

### 1. `hosts/jpporta-nixos/configuration.nix`
- Removed invalid `nixpkgs-unstable.config.allowUnfree = true;`.
- Added Nixpkgs overlay defining `unstable` using `inputs.nixpkgs-unstable` with `config.allowUnfree = true`:

```nix
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
```

### 2. `hosts/jpporta-nixos/home.nix`
- Updated the package set to reference `pkgs.unstable.*`:

```nix
    ++ [
      pkgs.unstable.lan-mouse
      pkgs.unstable.superfile
      pkgs.unstable.tuxedo
      pkgs.unstable.claude-code
    ];
```

## Source Diff (relative to HEAD)
```diff
diff --git a/hosts/jpporta-nixos/configuration.nix b/hosts/jpporta-nixos/configuration.nix
index 5c9e0d1..f3cd150 100644
--- a/hosts/jpporta-nixos/configuration.nix
+++ b/hosts/jpporta-nixos/configuration.nix
@@ -290,6 +290,15 @@
     openFirewall = false;
   };
   nixpkgs.config.allowUnfree = true;
+  nixpkgs.overlays = [
+    (final: prev: {
+      unstable = import inputs.nixpkgs-unstable {
+        system = prev.stdenv.hostPlatform.system;
+        config.allowUnfree = true;
+      };
+    })
+  ];
+
   system.stateVersion = "26.05";
 
 }
diff --git a/hosts/jpporta-nixos/home.nix b/hosts/jpporta-nixos/home.nix
index 084977b..ff92580 100644
--- a/hosts/jpporta-nixos/home.nix
+++ b/hosts/jpporta-nixos/home.nix
@@ -175,19 +175,20 @@
       gnome.gvfs
       sunshine
       unrar
-      claude-code
       ghgrab
       kew
       aria2
       kind
+      gnome-bluetooth
       (inputs.slk.packages.${pkgs.system}.default.overrideAttrs (_: {
         doCheck = false;
       }))
     ]
     ++ [
-      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse
-      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.superfile
-      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.tuxedo
+      pkgs.unstable.lan-mouse
+      pkgs.unstable.superfile
+      pkgs.unstable.tuxedo
+      pkgs.unstable.claude-code
     ];
 
   programs = {
@@ -251,7 +252,9 @@
     };
     Service = {
       Type = "simple";
-      ExecStart = "${inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse}/bin/lan-mouse daemon";
+      ExecStart = "${
+        inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse
+      }/bin/lan-mouse daemon";
       Restart = "on-failure";
       RestartSec = 1;
     };
```

## Notes on Working Tree State
The `home.nix` diff relative to HEAD includes `gnome-bluetooth` and formatting in the `lan-mouse` systemd unit which were already present in the user's staged changes prior to this change.
No duplicate packages exist for `superfile` (verified absent from `modules/home-manager/arch-packages/default.nix`).
