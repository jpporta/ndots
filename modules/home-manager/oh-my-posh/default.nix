{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{

  options.custom = {
    oh-my-posh.enable = lib.mkEnableOption "enable oh-my-posh prompt decorator";
  };

  config = lib.mkIf config.custom.oh-my-posh.enable {
    programs.oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      settings = builtins.fromJSON (builtins.readFile ./oh-my-posh.omp.json);
    };
  };

}
