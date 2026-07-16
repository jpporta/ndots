{
  config,
  pkgs,
  lib,
  ...
}:

let
  mainFont = "Berkeley Mono Nerd Font Mono";
  fontSize = 14;

  # Cage has no IPC for querying its active XKB group. This deck-only build
  # writes that group to CAGE_XKB_STATE_FILE for the tmux indicator below.
  cageWithLayoutState = pkgs.cage.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./cage-xkb-state.patch ];
  });

  keyboardLayout = pkgs.writeShellApplication {
    name = "keyboard-layout";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      state_file="''${CAGE_XKB_STATE_FILE:-$runtime_dir/writter-deck-keyboard-layout}"
      layout=0

      if [[ -r "$state_file" ]]; then
        IFS= read -r layout < "$state_file" || true
      fi

      case "$layout" in
        0) printf 'US' ;;
        1) printf 'PT' ;;
        *) printf '?' ;;
      esac
    '';
  };
in
{
  imports = [
    ../../modules/home-manager/oh-my-posh
    ../../modules/home-manager/zshrc
    ../../modules/home-manager/bat
    ../../modules/home-manager/cedilla
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
      extraConfig = ''
        # Cage does not expose the XKB group through Wayland. The deck-only
        # Cage patch updates the state file consumed by this status segment.
        set -g status-interval 1
        set -ag status-right "#[fg=#89b4fa] KBD:#(${keyboardLayout}/bin/keyboard-layout)"
      '';
    };
    cedilla = {
      enable = true;
      # Foot/libxkbcommon handles ~/.XCompose directly; the deck has no NixOS
      # fcitx5 service at /run/current-system/sw.
      startFcitx5 = false;
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
    cageWithLayoutState
    keyboardLayout
    foot
    wlr-randr
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
        # Auto-launch cage + foot when logging in on tty1 (skip over SSH).
        # If cage exits, you drop back to the login shell on tty1 instead
        # of being stuck in a restart loop.
        if [ "$(tty 2>/dev/null)" = "/dev/tty1" ] \
           && [ -z "$WAYLAND_DISPLAY" ] \
           && [ -z "$CAGE_RUNNING" ]; then
          export CAGE_RUNNING=1
          export WLR_RENDERER=pixman
          export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
          export XKB_DEFAULT_LAYOUT="us,us"
          export XKB_DEFAULT_VARIANT=",intl"
          export XKB_DEFAULT_OPTIONS="grp:alt_shift_toggle"
          export CAGE_XKB_STATE_FILE="$XDG_RUNTIME_DIR/writter-deck-keyboard-layout"
          rm -f "$CAGE_XKB_STATE_FILE"
          exec ${cageWithLayoutState}/bin/cage -- ${pkgs.foot}/bin/foot
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
