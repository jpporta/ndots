{ lib
, config
, pkgs
, ...
}:
{

  options.custom = {
    zoxide.enable = lib.mkEnableOption "enable zoxide - a modern replacement for cd";
  };

  config = lib.mkIf config.custom.zoxide.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
  };
}
    
