{
  config,
  pkgs,
  lib,
  ...
}:

let
  mainFont = "Berkeley Mono Nerd Font Mono";
  fontSize = 14;
in
{
  imports = [
    ../../modules/home-manager/oh-my-posh
    ../../modules/home-manager/zshrc
    ../../modules/home-manager/bat
    ../../modules/home-manager/opencode
    ../../modules/home-manager/nvim
    ../../modules/home-manager/pi
    ../../modules/home-manager/tmux
    ../../modules/home-manager/eza
    ../../modules/home-manager/zoxide
    ../../modules/home-manager/tailscale-daemon
  ];

  home = {
    username = "jpporta";
    homeDirectory = "/home/jpporta";
    stateVersion = "26.11";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  nixpkgs.config.allowUnfree = true;

  custom = {
    zsh = {
      enable = true;
      fastfetch = false;
    };
    tmux = {
      enable = true;
    };
    oh-my-posh.enable = true;
    pi.enable = true;
    nvim.enable = true;
    eza.enable = true;
    bat.enable = true;
    zoxide.enable = true;
    tailscale-daemon = {
      enable = true;
      acceptRoutes = true;
    };
  };

  home.packages = with pkgs; [
    cage
    foot
    git
    ripgrep
    fd
    mosh
    fastfetch
    lazygit
    stow
    tmux
  ];
  # `tailscale`/`ts` shell helpers come from the tailscale-daemon module.

  # Non-NixOS host: fixes locales, ld paths, XDG desktop entries
  targets.genericLinux.enable = true;

  # ---- fonts ----
  fonts.fontconfig.enable = true;

  home.file."my-fonts" = {
    source = ./fonts;
    target = ".local/share/fonts/custom";
    recursive = true;
  };

  programs = {
    home-manager.enable = true;
    foot = {
      enable = true;
      server.enable = false;
      settings = {
        main = {
          shell = "${pkgs.zsh}/bin/zsh --login";
          term = "xterm-256color";
          font = "${mainFont}:size=${toString fontSize}";
          font-bold = "${mainFont}:size=${toString fontSize}";
          pad = "12x12";
        };
        mouse = {
          hide-when-typing = "yes";
        };
        scrollback.lines = 10000;
        cursor.style = "block";
        colors-dark = {
          alpha = 1.0;
          background = "282828";
          foreground = "ebdbb2";
          regular0 = "282828";
          regular1 = "cc241d";
          regular2 = "98971a";
          regular3 = "d79921";
          regular4 = "458588";
          regular5 = "b16286";
          regular6 = "689d6a";
          regular7 = "a89984";
          bright0 = "928374";
          bright1 = "fb4934";
          bright2 = "b8bb26";
          bright3 = "fabd2f";
          bright4 = "83a598";
          bright5 = "d3869b";
          bright6 = "8ec07c";
          bright7 = "ebdbb2";
        };
        key-bindings = {
          font-increase = "Control+plus Control+equal";
          font-decrease = "Control+minus";
          font-reset = "Control+0";
        };
      };
    };

    bash = {
      enable = true;
      profileExtra = ''
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
          export WLR_RENDERER=pixman
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          exec cage -- foot
        fi
      '';
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };

        "pc" = {
          hostname = "jpporta-nixos";
          user = "jpporta";
          serverAliveInterval = 30;
        };

        "pc-lan" = {
          hostname = "192.168.0.100";
          user = "jpporta";
          serverAliveInterval = 30;
        };
        "pc-ts" = {
          hostname = "jpporta-nixos.taild23e4.ts.net";
          user = "jpporta";
          serverAliveInterval = 30;
        };
      };
    };
  };

  services.syncthing.enable = true;
  services.tailscale-systray.enable = true;

  home.sessionVariables.TERMINAL = "foot";
}
