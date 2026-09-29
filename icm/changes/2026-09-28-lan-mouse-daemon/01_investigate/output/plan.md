# Plan — configure lan-mouse daemon and firewall on jpporta-nixos

## Target
- Host: `jpporta-nixos` (NixOS system configuration and Home Manager user environment).
- System source: `hosts/jpporta-nixos/configuration.nix` (firewall port opening).
- User source: `hosts/jpporta-nixos/home.nix` (lan-mouse package from unstable, systemd user service).
- Desktop source: `modules/home-manager/hyprland/default.nix` (mouse sensitivity tuning for host cursor).

## Scope & Impact
- Target is exclusively `jpporta-nixos`.
- Verified: `hosts/writter-deck/` uses `cage` kiosk compositor and does not import `hyprland` or `configuration.nix`; it is completely unaffected.
- Existing unrelated working tree changes (such as `modules/home-manager/nvim/nvim/lua/jpporta/snippets.lua`) are preserved and strictly excluded from this change record.

## Proposed Changes
1. **Firewall (`hosts/jpporta-nixos/configuration.nix`)**:
   Set `networking.firewall.allowedUDPPorts = [ 4242 ];`.
   - Protocol: UDP only.
   - Security: In lan-mouse 0.11.0, communication uses mutual DTLS authentication. Packets from unauthorized fingerprints are rejected at the crypto handshake layer.

2. **Package (`hosts/jpporta-nixos/home.nix`)**:
   Ensure `inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse` is in `home.packages`.
   - Reason: Provides `lan-mouse` v0.11.0 matching the macOS client with DTLS support.

3. **Background Daemon Service (`hosts/jpporta-nixos/home.nix`)**:
   Add `systemd.user.services.lan-mouse`:
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

4. **Hyprland Pointer Sensitivity (`modules/home-manager/hyprland/default.nix`)**:
   Set `sensitivity = -0.5` under input settings.
   - Purpose: Allows increasing physical mouse DPI (e.g., to 2400+ DPI) so cursor movements across to the macOS client are fast and responsive, while keeping local Linux cursor speed balanced.

## Validation Approach
1. Build the target toplevel system derivation without switching:
   `nix build .#nixosConfigurations.jpporta-nixos.config.system.build.toplevel --no-link`
2. Verify that the Nix syntax and types evaluate cleanly without errors.

## Deployment Command
Executed only upon explicit human approval:
`sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`

Post-switch verification:
- `systemctl --user status lan-mouse`
- `sudo iptables -S | grep 4242` or `sudo nft list ruleset | grep 4242`
- Launch `lan-mouse` GUI to verify connection and mutual fingerprint exchange.

## Rollback
Revert the additions in `hosts/jpporta-nixos/configuration.nix`, `hosts/jpporta-nixos/home.nix`, and `modules/home-manager/hyprland/default.nix`, then rebuild with `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos` or switch back to the prior generation via `sudo nixos-rebuild --rollback`.
