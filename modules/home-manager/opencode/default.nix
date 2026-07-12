{ lib, config, ... }:
{

  options.custom = {
    opencode.enable = lib.mkEnableOption "enable opencode - LLM Harness";
  };

  config = lib.mkIf config.custom.opencode.enable {
    programs.opencode = {
      enable = true;
      settings = {
        plugin = [
          "@dietrichgebert/ponytail"
        ];
      };
    };
  };
}
