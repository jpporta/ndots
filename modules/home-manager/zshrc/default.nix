{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  options.custom = {
    zsh = {
      enable = lib.mkEnableOption "enable zsh shell";
      fastfetch = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to invoke fastfetch on zsh init.
        '';
      };
    };
  };

  config = lib.mkIf config.custom.zsh.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "jj" ];
        theme = "";
      };

      shellAliases = {
        tx = "tmuxinator";
        n = "nvim --listen /tmp/nvim$(echo $RANDOM | md5sum | cut -c1-8).sock";
        ls = "eza --icons --group-directories-first --color=always";
        man = "batman";
        ":q" = "exit";
        so = "source ~/.zshrc";
        zki = "zk edit --interactive --notebook-dir=~/Documents/Notes";
        enc = "openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt";
        backup = "packup && rm ~/Documents/packup* && mv ~/packup* ~/Documents/ && rsync --archive --update --copy-links ~/Documents 192.168.3.200:/home/jpporta/ --info=progress2";
        gn = "git commit -m \"$(date)\"";
        nixs = "cd ~/nixos-config && git add . && sudo nixos-rebuild switch --flake ~/nixos-config#jpporta-nixos";
        nix-search = "nix --extra-experimental-features \"nix-command flakes\" search nixpkgs";
        nix-garbage = "sudo nix-collect-garbage -d && sudo nixos-rebuild switch";
        nix-update = "sudo nix-channel --update && sudo nixos-rebuild switch";
        hms = "cd ~/nixos-config && git add . && home-manager switch --flake . ";
        s = "sesh connect $(sesh list | fzf)";
      };

      initContent = lib.mkIf config.custom.zsh.fastfetch ''
        fastfetch
      '';
    };
  };
}
