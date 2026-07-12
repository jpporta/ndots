{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/nixos/hyprland
    ../../modules/nixos/steam
    ../../modules/nixos/awsvpn
    ../../modules/nixos/tailscale
  ];

  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd = {
      kernelModules = [ "amdgpu" ];
      # Encrypted Drives
      luks.devices = {
        "cryptstorage-nvme" = {
          device = "/dev/disk/by-uuid/6331fbf8-5f21-4e72-b196-f31788f61d28";
          keyFile = "/storage.key";
          allowDiscards = true;
        };
        "cryptstorage-ssd" = {
          device = "/dev/disk/by-uuid/8f275b47-c2fd-4b80-80e2-9dfba3279607";
          keyFile = "/storage.key";
          allowDiscards = true;
        };
        "cryptstorage-hd" = {
          device = "/dev/disk/by-uuid/ef1bc263-b241-48c6-a93d-1a2497c1fa1d";
          keyFile = "/storage.key";
        };
      };
      secrets = {
        "/storage.key" = "/etc/secrets/storage.key";
      };
    };
  };
  # Mount Points
  fileSystems = {
    "/mnt/work" = {
      device = "/dev/mapper/cryptstorage-nvme";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=10s"
      ];
    };
    "/mnt/documents" = {
      device = "/dev/mapper/cryptstorage-ssd";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=10s"
      ];
    };
    "/mnt/storage" = {
      device = "/dev/mapper/cryptstorage-hd";
      fsType = "ext4";
      options = [
        "nofail"
        "x-systemd.device-timeout=10s"
      ];
    };
  };

  # Networking
  networking = {
    hostName = "jpporta-nixos";
    networkmanager.enable = true;
    nameservers = [ "192.168.0.200" ];
  };

  # Locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
  };

  # User
  users.users.jpporta = {
    isNormalUser = true;
    description = "jpporta";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "docker"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtBfMUaNtpUYOi0dFsGsAv/ypw535+SouH7fn8eYDvr writterdeck"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Refactored Config
  custom = {
    hyprland.enable = true;
    steam.enable = true;
    tailscale.enable = true;
  };

  ##------------------------------
  programs = {
    zsh.enable = true;
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    wofi
    waybar
    ollama-rocm
    glib
    gsettings-desktop-schemas
  ];

  virtualisation.docker.enable = true; # docker, buildx
  virtualisation.virtualbox.host.enable = true;

  services = {
    resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNSOverTLS = "opportunistic";
          DNSSEC = "false"; # delegate DNSSEC to Pi-hole / its upstream
          FallbackDNS = [ "1.1.1.1#cloudflare-dns.com" ]; # only if Pi-hole is unreachable
        };
      };
    };
    pulseaudio.enable = false; # make sure the old one is off
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true; # apps expecting pulseaudio still work
      jack.enable = true; # only if you use jack apps (reaper, etc.)
      wireplumber.enable = true;
    };
    keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ]; # or specific vendor:product ids
        settings = {
          main = {
            capslock = "overload(control, esc)"; # translate your default.conf here
          };
        };
      };
    };
    postgresql.enable = true;
    redis.servers."".enable = true; # valkey/redis
    syncthing = {
      enable = true;
      user = "jpporta";
      group = "users";
      dataDir = "/home/jpporta";
      configDir = "/home/jpporta/.config/syncthing";
    };
  };

  security.rtkit.enable = true; # lets pipewire get realtime priority

  # TODO: remove later. Required by Teleo old tools
  systemd.services.docker.environment.DOCKER_MIN_API_VERSION = "1.24";

  hardware.bluetooth.enable = true; # bluez
  networking.firewall.enable = true; # replaces ufw
  zramSwap.enable = true; # replaces zram-generator

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true; # sets up the udev/module glue for you
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture # capture individual app audio on wayland
      obs-backgroundremoval # green-screen without a green screen
      obs-vkcapture # game capture for vulkan/opengl on wayland
      wlrobs # wlroots screen capture (not for hyprland — use pipewire portal)
    ];
  };

  programs.awsVpnClient.enable = true;
  programs.dconf.enable = true;

  # OpenSSH: reachable through the trusted Tailscale interface, but not opened
  # broadly on every network interface by the firewall.
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "jpporta" ];
    };
  };
  programs.mosh = {
    enable = true;
    openFirewall = false;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
