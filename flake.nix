{
  description = "jpporta's NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-deck = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-deck = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-deck";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awsvpnclient = {
      url = "github:ymatsiuk/awsvpnclient";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      nixosConfigurations.jpporta-nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/jpporta-nixos/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              extraSpecialArgs = { inherit inputs; };
              users.jpporta = import ./hosts/jpporta-nixos/home.nix;
            };
          }
        ];
      };

      homeConfigurations.jpporta-deck = inputs.home-manager-deck.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs-deck.legacyPackages.aarch64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./hosts/writter-deck/home.nix
        ];
      };
    };
}
