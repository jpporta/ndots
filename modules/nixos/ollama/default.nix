{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.ollama;
in
{
  options.custom.ollama.enable = lib.mkEnableOption "Ollama LLM server (ROCm)";

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
    };
    environment.systemPackages = [ pkgs.ollama-rocm ];
  };
}