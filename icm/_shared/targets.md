# Configuration targets

## jpporta-nixos system
- Scope: NixOS system services, boot, hardware, networking, and system packages.
- Source: `hosts/jpporta-nixos/configuration.nix` and `modules/nixos/`.
- Build and switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.

## jpporta-nixos user environment
- Scope: Home Manager packages, programs, and desktop configuration on the NixOS host.
- Source: `hosts/jpporta-nixos/home.nix` and `modules/home-manager/`.
- Build and switch: `sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos`.

## jpporta-deck
- Scope: Home Manager configuration for the writer deck.
- Source: `hosts/writter-deck/home.nix` and shared `modules/home-manager/` modules.
- Build and switch: `home-manager switch --flake ~/ndots#jpporta-deck`.

## Host selection
Read `flake.nix` and the selected host entry point before editing. A shared Home Manager module can affect both machines; state that impact in the change plan.
