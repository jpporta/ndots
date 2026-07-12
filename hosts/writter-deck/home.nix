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
    # Shared home-manager modules
    ../../modules/home-manager/arch-packages
    ../../modules/home-manager/oh-my-posh
    ../../modules/home-manager/zshrc
    ../../modules/home-manager/alacritty
    ../../modules/home-manager/bat
    ../../modules/home-manager/fastfetch
    ../../modules/home-manager/hyprland
    ../../modules/home-manager/hyprlock
    ../../modules/home-manager/hyprpaper
    ../../modules/home-manager/awww
    ../../modules/home-manager/hyprsunset
    ../../modules/home-manager/darkman
    ../../modules/home-manager/wlogout
    ../../modules/home-manager/opencode
    ../../modules/home-manager/swaync
    ../../modules/home-manager/nvim
    ../../modules/home-manager/pi
    ../../modules/home-manager/tmux
  ];

  home = {
    username = "jpporta";
    homeDirectory = "/home/jpporta";
    stateVersion = "26.11";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  custom = {
    zsh = {
      enable = true;
      fastfetch = false;
    };
    tmux.enable = true;
    oh-my-posh.enable = true;
    pi.enable = true;
    nvim.enable = true;

    hyprland.enable = true;
    hyprlock.enable = true;
    hyprpaper.enable = false;
    hyprsunset.enable = true;
    wlogout.enable = true;
    darkman.enable = true;
    awww.enable = true;
    opencode.enable = true;
    alacritty.enable = true;
    bat.enable = true;
    fastfetch.enable = true;
    swaync.enable = true;
  };

  home.packages = with pkgs; [
    cage
    foot
    git
    ripgrep
    fd
    mosh
    fastfetch
    stow
    tmux
  ];

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
        scrollback.lines = 10000;
        cursor.style = "beam";
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
          hostname = "192.168.0.100";
          user = "jpporta";
          serverAliveInterval = 30;
        };
      };
    };
  };

  services.syncthing.enable = true;

  home.sessionVariables.TERMINAL = "foot";
}
