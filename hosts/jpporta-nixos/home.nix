{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Shared home-manager modules
    ../../modules/home-manager/arch-packages
    ../../modules/home-manager/calendar
    ../../modules/home-manager/oh-my-posh
    ../../modules/home-manager/zshrc
    ../../modules/home-manager/alacritty
    ../../modules/home-manager/bat
    ../../modules/home-manager/fastfetch
    ../../modules/home-manager/hyprland
    ../../modules/home-manager/hypridle
    ../../modules/home-manager/hyprlock
    ../../modules/home-manager/hyprpaper
    ../../modules/home-manager/awww
    ../../modules/home-manager/hyprsunset
    ../../modules/home-manager/darkman
    ../../modules/home-manager/wlogout
    ../../modules/home-manager/opencode
    ../../modules/home-manager/cedilla
    ../../modules/home-manager/dictation
    ../../modules/home-manager/nvim
    ../../modules/home-manager/pi
    ../../modules/home-manager/tmux
    ../../modules/home-manager/openspec

    inputs.zen-browser.homeModules.beta
  ];

  home = {
    username = "jpporta";
    homeDirectory = "/home/jpporta";
    stateVersion = "26.05";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  custom = {
    jpporta-calendars.enable = true;

    oh-my-posh.enable = true;
    zsh.enable = true;
    alacritty.enable = true;
    bat.enable = true;
    fastfetch.enable = true;
    opencode.enable = true;

    hyprland.enable = true;
    hypridle.enable = true;
    hyprlock.enable = true;
    hyprpaper.enable = false;
    awww = {
      enable = true;
      transition = {
        fps = 240;
        step = 90;
        duration = "1.5";
      };
    };

    hyprsunset.enable = true;
    wlogout.enable = true;

    darkman.enable = true;

    cedilla.enable = true;
    dictation = {
      enable = true;
      modelHash = "sha256-ZNGCtEC5jVIDxPm9VBVE2ExgUZbE97hF36EfsjWU0eI=";
    };

    nvim.enable = true;
    pi.enable = true;
    tmux.enable = true;
    openspec.enable = true;
  };

  home.packages =
    let
      mediaplayerPython = pkgs.python3.withPackages (ps: with ps; [ pygobject3 ]);
    in
    with pkgs;
    [
      playerctl
      (pkgs.writeShellScriptBin "mediaplayer-python" ''
        export GI_TYPELIB_PATH=${pkgs.playerctl}/lib/girepository-1.0''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}
        exec ${mediaplayerPython}/bin/python3 "$@"
      '')

      eza
      fastfetch
      nodejs
      firefox
    ];

  programs = {
    zen-browser.enable = true;
    git = {
      enable = true;
      settings = {
        user = {
          name = "João Pedro Pin Porta";
          email = "jpedro.porta@gmail.com"; # must match the uid on the gpg key

        };
        gpg.program = "gpg";
        commit.gpgSign = true;
        tag.gpgSign = true;
      };
      signing = {
        key = "7BA72FF4FA933219";
        signByDefault = true;
      };
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };
    gpg.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-rofi;
    enableSshSupport = true; # only if you use gpg keys as ssh keys
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };

  services.swaync.enable = true;
}
