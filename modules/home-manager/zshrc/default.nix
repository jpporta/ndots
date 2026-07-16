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
        nixs = "cd ~/ndots && git add . && sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos";
        nix-search = "nix --extra-experimental-features \"nix-command flakes\" search nixpkgs";
        nix-garbage = "sudo nix-collect-garbage -d && sudo nixos-rebuild switch";
        nix-update = "sudo nix-channel --update && sudo nixos-rebuild switch";
        hms = "cd ~/ndots && git add . && home-manager switch --flake .#jpporta-deck";
        s = "sesh connect $(sesh list | fzf)";
        rot90 = "wlr-randr --output HDMI-A-1 --transform 90";
        rot0 = "wlr-randr --output HDMI-A-1 --transform normal";
        rotl = "wlr-randr --output HDMI-A-1 --transform 270";
        rot180 = "wlr-randr --output HDMI-A-1 --transform 180";
        # Tailscale shortcuts (writter-deck only really needs these, but
        # they don't hurt anyone else either). `ts` is the wrapper that
        # points the CLI at the user-scope socket from the tailscale-daemon
        # module.
        ts-status = "ts status";
        ts-ping = "ts ping -c 3 jpporta-nixos";
      };

      initContent = ''
        ${lib.optionalString config.custom.zsh.fastfetch "fastfetch"}
        # Auto-rotate screen to portrait when running inside cage/foot
        # on the writer-deck. Skipped over SSH and other non-Wayland sessions.
        if [ -n "$WAYLAND_DISPLAY" ] && [ -n "$CAGE_RUNNING" ] && [ "$ROTATED" != "1" ]; then
          export ROTATED=1
          wlr-randr --output HDMI-A-1 --transform 90 >/dev/null 2>&1
        fi
      '';
    };
  };
}
