{ config, pkgs, lib, ... }:

{
  imports = [ ./arch-packages.nix ];

  home.username = "jpporta";
  home.homeDirectory = "/home/jpporta";
  home.stateVersion = "26.05";

  # from your `export PATH=...` lines
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

home.packages = [
    pkgs.eza              
    pkgs.fastfetch        
    pkgs.bat-extras.batman
    pkgs.nodejs           
    pkgs.firefox
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "";
    };

    shellAliases = {
      tx = "tmuxinator";
      n = "nvim --listen /tmp/nvim$(echo $RANDOM | md5sum | cut -c1-8).sock";
      ls = "eza --icons --group-directories-first --color=always";
      man = "batman";
      ":q" = "exit";
      so = "source ~/.zshrc";
      opencode = "OPENCODE_ENABLE_EXA=1 opencode";
      zki = "zk edit --interactive --notebook-dir=~/Documents/Notes";
      enc = "openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt";
      backup = "packup && rm ~/Documents/packup* && mv ~/packup* ~/Documents/ && rsync --archive --update --copy-links ~/Documents 192.168.3.200:/home/jpporta/ --info=progress2";
      gn = "git commit -m \"$(date)\"";
      nixs = "cd ~/nixos-config && git add . && sudo nixos-rebuild switch --flake ~/nixos-config#jpporta-nixos";
      s = "sesh $(sesh list | fzf)";
    };

    initContent = ''
      fastfetch
    '';
  };

  programs.bat.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd" "cd" ];
  };
programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./oh-my-posh.omp.json);
  };

programs.gpg.enable = true;

services.gpg-agent = {
  enable = true;
  pinentry.package = pkgs.pinentry-gtk2;   # must match what you installed
  enableSshSupport = true;                  # only if you use gpg keys as ssh keys
  defaultCacheTtl = 3600;
  maxCacheTtl = 86400;
};
}
