{ lib, config, pkgs, ... }:
{
  options.custom = {
    dev-orchestrator.enable = lib.mkEnableOption "enable dev-orchestrator — OpenSpec + OpenCode dev→QA loop with git worktrees";
  };

  config = lib.mkIf config.custom.dev-orchestrator.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "dev-orchestrator";
        runtimeInputs = with pkgs; [ git ];
        text = builtins.readFile ../../../tooling/dev-orchestrator;
      })
    ];
  };
}
