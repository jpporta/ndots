# Implementation — fix herdr 0.9.1 linker failure and vboxnet0 switch ordering

## Applied Changes

### 1. `modules/home-manager/arch-packages/default.nix`
Overrode `herdr` from `nixpkgs-unstable` to append `-C link-arg=-Wl,--no-eh-frame-hdr` to `RUSTFLAGS` in `env`:

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
```

### 2. `hosts/jpporta-nixos/configuration.nix`
Configured `vboxnet0` systemd service with `stopIfChanged = false` and `restartIfChanged = false`:
```nix
  virtualisation.docker.enable = true; # docker, buildx
  virtualisation.virtualbox.host.enable = true;

  # Prevent vboxnet0 from being stopped/restarted on switch, which breaks network-addresses-vboxnet0
  systemd.services.vboxnet0 = {
    stopIfChanged = false;
    restartIfChanged = false;
  };
```

## Source Diff
```diff
diff --git a/hosts/jpporta-nixos/configuration.nix b/hosts/jpporta-nixos/configuration.nix
index db3c82d..ef88421 100644
--- a/hosts/jpporta-nixos/configuration.nix
+++ b/hosts/jpporta-nixos/configuration.nix
@@ -167,6 +167,12 @@
   virtualisation.docker.enable = true; # docker, buildx
   virtualisation.virtualbox.host.enable = true;
 
+  # Prevent vboxnet0 from being stopped/restarted on switch, which breaks network-addresses-vboxnet0
+  systemd.services.vboxnet0 = {
+    stopIfChanged = false;
+    restartIfChanged = false;
+  };
+
   custom.ollama.enable = true;
 
   services = {
diff --git a/modules/home-manager/arch-packages/default.nix b/modules/home-manager/arch-packages/default.nix
index 1d087c8..00d8927 100644
--- a/modules/home-manager/arch-packages/default.nix
+++ b/modules/home-manager/arch-packages/default.nix
@@ -3,7 +3,12 @@
 {
   home.packages =
     (with inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
-      herdr
+      (herdr.overrideAttrs (old: {
+        env = (old.env or { }) // {
+          RUSTFLAGS =
+            (old.env.RUSTFLAGS or old.RUSTFLAGS or "") + " -C link-arg=-Wl,--no-eh-frame-hdr";
+        };
+      }))
     ])
     ++ (with pkgs; [
       # ---- shell & core CLI ----
```

## Deviations from Plan
Added `systemd.services.vboxnet0` settings to address switch-to-configuration exit code 4 caused by transient device removal.
