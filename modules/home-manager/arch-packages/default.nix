{ pkgs, ... }:

let
  claude-code = pkgs.symlinkJoin {
    name = "claude-code-wrapped";
    paths = [ pkgs.claude-code ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude \
        --suffix PATH : ${pkgs.lib.makeBinPath [ pkgs.python3 ]}
    '';
  };
in
{
  home.packages = with pkgs; [
    # ---- shell & core CLI ----
    tree
    worktrunk
    zoxide
    fzf
    eza
    fd
    bc
    wget
    which
    entr
    stow
    bat-extras.batman
    bat-extras.batgrep
    bat-extras.batdiff
    bat-extras.batpipe
    bat-extras.batwatch
    bat-extras.prettybat
    fastfetch
    tldr
    superfile
    silicon
    expect
    jq
    killall
    gnupg
    pinentry-gtk2
    # nitch

    # ---- editors & dev tooling ----
    tree
    ffmpeg
    chromium
    neovim
    vim
    tree-sitter
    stylua
    lua5_1
    luarocks
    ruby
    git
    gh
    lazygit
    tmux
    sesh
    serie
    gcc
    gnumake
    pandoc
    typst
    tectonic
    mkcert
    sqlc
    rainfrog
    unzip

    # Languages
    go
    cargo
    php
    julia
    eslint_d
    golangci-lint
    rust-analyzer
    imagemagick
    ghostscript
    ripgrep
    gopls
    typescript-language-server
    nixfmt

    # ---- cloud / infra ----
    awscli2
    kubectl
    kubernetes-helm
    k9s
    kind
    opentofu
    hasura-cli
    docker-compose
    platformio
    claude-code
    jujutsu

    # ---- hyprland / wayland desktop ----
    hyprshot
    waybar
    wofi
    wlogout
    rofi
    quickshell
    grim
    slurp
    wl-clipboard
    wl-color-picker
    swayimg
    wev
    wiremix
    matugen
    dmenu-wayland
    udiskie
    networkmanagerapplet
    pywal16
    # swaync

    # ---- theming & fonts ----
    adw-gtk3
    bibata-cursors
    papirus-icon-theme
    papirus-folders
    rose-pine-hyprcursor
    nwg-look
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
    libsForQt5.qtstyleplugin-kvantum

    # ---- GUI apps ----
    obsidian
    obs-cmd
    qbittorrent
    zathura
    mpv
    yt-dlp
    libreoffice-fresh
    evolution
    slack
    spotify
    zoom-us
    localsend
    feishin
    darktable
    gthumb
    kdePackages.kdenlive
    shotcut
    video-trimmer
    kdePackages.dolphin
    thunar
    gnome-calendar
    gnome-clocks
    gnome-weather
    pass
    bluetuith
    cameractrls
    gphoto2
    gnuplot
    pnpm
    hyprshutdown
    sl
    p7zip

    # surfshark-client -> no package; use their generic linux app or wireguard configs
    # tidaler, awww, hyprpwcenter, hyprshutdown
  ];
}
