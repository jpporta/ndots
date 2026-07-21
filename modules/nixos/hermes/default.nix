{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.custom.hermes;
in
{
  options.custom.hermes.enable = lib.mkEnableOption "Hermes Agent CLI";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      inputs.hermes-agent.packages.${pkgs.system}.default
    ];
  };
}
