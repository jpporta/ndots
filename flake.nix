{
  description = "jpporta's NixOS and nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awsvpnclient = {
      url = "github:ymatsiuk/awsvpnclient";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent.url = "github:NousResearch/hermes-agent";
    slk.url = "github:gammons/slk";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      darwin,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      nixosConfigurations.jpporta-nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/jpporta-nixos/configuration.nix
        ];
      };

      # Work Mac
      darwinConfigurations.velozient-mac = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/velozient-mac/default.nix
        ];
      };

      # Personal Mac (engineering)
      darwinConfigurations.jpporta-mac = inputs.darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/jpporta-mac/default.nix
        ];
      };

      # `nix flake init -t ~/ndots#node` in a project, then `direnv allow`
      templates.node = {
        path = ./templates/node;
        description = "Node.js dev shell (direnv + nix-direnv)";
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              nil # Nix LSP — your Neovim will pick it up via direnv
              statix # linter, optional
            ];
          };
        }
      );
    };
}
