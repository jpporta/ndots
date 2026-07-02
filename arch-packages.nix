{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ---- shell & core CLI ----
zsh zoxide fzf eza fd bat bc wget which entr stow
    bat-extras.batman bat-extras.batgrep bat-extras.batdiff
    bat-extras.batpipe bat-extras.batwatch bat-extras.prettybat
    fastfetch tldr
    superfile silicon expect 
    jq killall gnupg pinentry-gtk2
    # nitch 

    # ---- editors & dev tooling ----
    neovim vim tree-sitter stylua lua5_1 luarocks ruby
    git gh lazygit tmux sesh serie
    gcc gnumake pandoc typst tectonic
    mkcert sqlc rainfrog

    # ---- cloud / infra ----
    awscli2 kubectl kubernetes-helm k9s kind opentofu hasura-cli
    docker-compose platformio opencode

    # ---- hyprland / wayland desktop ----
    hypridle hyprlock hyprpaper hyprsunset hyprshot
    waybar wofi wlogout rofi quickshell
    grim slurp wl-clipboard wl-color-picker swayimg wev wiremix
    matugen dmenu-wayland udiskie networkmanagerapplet
    pywal16
# swaync 

    # ---- theming & fonts ----
    adw-gtk3 bibata-cursors papirus-icon-theme papirus-folders
    rose-pine-hyprcursor nwg-look
    nerd-fonts.jetbrains-mono noto-fonts-color-emoji
    libsForQt5.qtstyleplugin-kvantum

    # ---- GUI apps ----
    kitty alacritty
    obsidian obs-cmd qbittorrent
    zathura mpv yt-dlp libreoffice-fresh evolution
    slack spotify zoom-us localsend feishin
    darktable gthumb kdePackages.kdenlive shotcut video-trimmer
    kdePackages.dolphin thunar
    gnome-calendar gnome-clocks gnome-weather
    khal vdirsyncer pass bluetuith cameractrls
    gphoto2 gnuplot

    # zen-browser      -> flake: github:0xc000022070/zen-browser-flake
    # surfshark-client -> no package; use their generic linux app or wireguard configs
    # tidaler, awww, hyprpwcenter, hyprshutdown, aur-scanner -> AUR-only, port manually
  ];
}

# ---------------------------------------------------------------------------
# SYSTEM-LEVEL (goes in configuration.nix on NixOS, NOT home.nix):
#
#   programs.hyprland.enable = true;          # + xdg-desktop-portal-hyprland

#   programs.steam.enable = true;
#   programs.gamemode.enable = true;          # + pkgs.gamescope
#   virtualisation.docker.enable = true;      # docker, buildx
#   virtualisation.virtualbox.host.enable = true;
#   services.pipewire = { enable = true; pulse.enable = true; jack.enable = true; };
#   services.keyd.enable = true;              # port /etc/keyd/default.conf manually!
#   services.postgresql.enable = true;
#   services.redis.servers."".enable = true;  # valkey/redis
#   services.syncthing.enable = true;         # (or user service in home-manager)
#   services.ollama = { enable = true; acceleration = "rocm"; };

#   services.gnome.gnome-keyring.enable = true;
#   security.polkit.enable = true;            # + polkit_gnome agent in hyprland exec-once
#   networking.networkmanager.enable = true;

#   hardware.bluetooth.enable = true;         # bluez
#   networking.firewall.enable = true;        # replaces ufw
#   zramSwap.enable = true;                   # replaces zram-generator
#   boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
#
# Dropped (Arch plumbing, no nix equivalent needed): base, base-devel, linux*,
# amd-ucode, linux-firmware, yay, pacman-contrib, packup, reflector, refind,
# efibootmgr, edk2-shell, xorg/xf86 drivers, iwd, wpa_supplicant, cronie,
# debugedit, fakeroot, patch, cpio, execstack, bind, ethtool, alsa-utils,
# btrfs-progs, smartmontools, clamav, sudo, opencl-mesa, vulkan-radeon.
# ---------------------------------------------------------------------------
