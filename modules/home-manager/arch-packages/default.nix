{ pkgs, inputs, ... }:

{
  home.packages =
    (with inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
      herdr
    ])
    ++ (with pkgs; [
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

      go
      cargo
      php
      julia
      imagemagick
      ghostscript
      ripgrep

      kubectl
      kubernetes-helm
      k9s
      docker-compose
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
      liberation_ttf
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
    ]);
}
