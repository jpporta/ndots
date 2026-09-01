{
  lib,
  config,
  pkgs,
  ...
}:
{

  options.custom = {
    lazygit.enable = lib.mkEnableOption "enable lazygit with delta pager";
  };

  config = lib.mkIf config.custom.lazygit.enable {
    programs.lazygit = {
      enable = true;
      settings = {
        git = {
          paging = {
            colorArg = "always";
            pager = "delta --paging=never";
          };
        };
        gui = {
          showRandomTip = false;
        };
      };
    };
  };
}
