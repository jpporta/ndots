{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.custom = {
    leaf.enable = lib.mkEnableOption "enable leaf - terminal Markdown previewer";
  };

  config = lib.mkIf config.custom.leaf.enable {
    home.packages = [
      (pkgs.rustPlatform.buildRustPackage {
        pname = "leaf-markdown-viewer";
        version = "1.28.2";

        src = pkgs.fetchFromGitHub {
          owner = "RivoLink";
          repo = "leaf";
          rev = "1.28.2";
          hash = "sha256-WX9C4gWNPCHWFsHN4xFmShv6dJyYAVgr9xMw5JtoFHI=";
        };

        cargoLock.lockFile = ./Cargo.lock;

        meta = {
          description = "Terminal Markdown previewer with a GUI-like experience";
          homepage = "https://leaf.rivolink.mg";
          license = lib.licenses.mit;
          mainProgram = "leaf";
        };
      })
    ];
  };
}
