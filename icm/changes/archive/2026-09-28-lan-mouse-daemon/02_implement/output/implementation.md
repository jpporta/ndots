# Implementation — configure lan-mouse daemon and firewall on jpporta-nixos

## Applied Changes

### 1. `hosts/jpporta-nixos/configuration.nix`
Opened UDP port 4242 in the NixOS firewall:
```nix
  networking.firewall = {
    enable = true; # replaces ufw
    allowedUDPPorts = [ 4242 ];
  };
```

### 2. `hosts/jpporta-nixos/home.nix`
1. Added `lan-mouse` from `inputs.nixpkgs-unstable` to `home.packages`:
```nix
    ++ [
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse
      ...
    ];
```
2. Defined `systemd.user.services.lan-mouse` to run the daemon automatically in the graphical session:
```nix
  systemd.user.services.lan-mouse = {
    Unit = {
      Description = "Lan Mouse daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse}/bin/lan-mouse daemon";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
```

### 3. `modules/home-manager/hyprland/default.nix`
Added `sensitivity = -0.5` in Hyprland's input settings to allow high hardware mouse DPI while keeping host cursor speed comfortable.

## Deviations from Plan
None.
