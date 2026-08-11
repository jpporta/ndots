{ lib, config, pkgs, inputs, ... }:

{
  options.custom = {
    pi.enable = lib.mkEnableOption "enable pi - pi.dev coding agent";
  };

  config = lib.mkIf config.custom.pi.enable {
    home.packages = [
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent
    ] ++ (with pkgs; [
      worktrunk
      sesh
      sl
      signal-cli
    ]);
  };
}
