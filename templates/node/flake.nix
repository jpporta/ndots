{
  description = "Node.js dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
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
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Pin the Node major here: nodejs_20, nodejs_22, nodejs_24, ...
          nodejs = pkgs.nodejs_22;
        in
        {
          default = pkgs.mkShell {
            packages = [
              nodejs
              pkgs.pnpm
            ];
          };
        }
      );
    };
}
