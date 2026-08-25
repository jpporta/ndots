{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  # Default prompt colors, used when the theme-switcher has not written its runtime
  # fragment yet (fresh shell before the first switch). The switcher fills the same
  # __C_*__ placeholders with the active base16 palette (oh-my-posh has no include).
  template = builtins.readFile ./oh-my-posh.omp.json;
  settings = builtins.fromJSON (lib.replaceStrings
    [ "__C_ACCENT__" "__C_PATH__" "__C_GIT__" "__C_NODE__" "__C_RAM__" "__C_ERR__" ]
    [ "#ffbb93" "#a75d31" "#f3e1da" "#ecc3b0" "#d5d096" "#ffb8af" ]
    template);
in {
  options.custom = {
    oh-my-posh.enable = lib.mkEnableOption "enable oh-my-posh prompt decorator";
  };

  config = lib.mkIf config.custom.oh-my-posh.enable {
    programs.oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      inherit settings;
    };
  };
}