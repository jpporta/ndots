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
      enableZshIntegration = true;
      settings = {
        git = {
          pagers = [
            {
              pager = "delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
              colorArg = "always";
            }
          ];
          diffRenderers = [
            {
              command = ''delta --dark --paging=never --plus-style 'syntax "#1a4a1a"' --minus-style 'syntax "#5c1717"' '';
            }
          ];
        };
        gui = {
          showRandomTip = false;
        };
      };
    };
  };
}
