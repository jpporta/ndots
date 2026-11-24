{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.programs.awsVpnClient;
  awsvpnclientPkg = inputs.awsvpnclient.defaultPackage.${pkgs.stdenv.hostPlatform.system};
in
{
  options.programs.awsVpnClient = {
    enable = lib.mkEnableOption "AWS Client VPN with SAML (ymatsiuk/awsvpnclient flake)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ awsvpnclientPkg ];
  };
}
