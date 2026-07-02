{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Encrypted Drives
  boot.initrd.luks.devices = {
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
  boot.initrd.secrets = {
	"/storage.key" = "/etc/secrets/storage.key";
  };
  # Mount Points
  fileSystems."/mnt/work" = {
	device = "/dev/mapper/cryptstorage-nvme";
	fsType = "ext4";
	options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };
  fileSystems."/mnt/documents" = {
	device = "/dev/mapper/cryptstorage-ssd";
	fsType = "ext4";
	options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };
  fileSystems."/mnt/storage" = {
	device = "/dev/mapper/cryptstorage-hd";
	fsType = "ext4";
	options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };

  # Networking
  networking.hostName = "jpporta-nixos";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  # User
  users.users.jpporta = {
    isNormalUser = true;
    description = "jpporta";
    extraGroups = [ "wheel" "networkmanager" "audio" "video"];
    shell = pkgs.zsh;
  };

nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;
  programs.hyprland.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;

  xdg.portal = {
	enable = true;
	extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    	vim 
	git
    	wget
	curl
	htop
	kitty
	alacritty
	wofi
	waybar
	ollama-rocm
  ];

   programs.steam.enable = true;
   programs.gamemode.enable = true;          # + pkgs.gamescope
   virtualisation.docker.enable = true;      # docker, buildx
   virtualisation.virtualbox.host.enable = true;
services.pulseaudio.enable = false;   # make sure the old one is off
security.rtkit.enable = true;         # lets pipewire get realtime priority

services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;                # apps expecting pulseaudio still work
  jack.enable = true;                  # only if you use jack apps (reaper, etc.)
  wireplumber.enable = true;
};
services.keyd = {
  enable = true;
  keyboards.default = {
    ids = [ "*" ];               # or specific vendor:product ids
    settings = {
      main = {
        capslock = "overload(control, esc)";  # translate your default.conf here
      };
    };
  };
};
   services.postgresql.enable = true;
   services.redis.servers."".enable = true;  # valkey/redis
   services.syncthing.enable = true;         # (or user service in home-manager)

   hardware.bluetooth.enable = true;         # bluez
   networking.firewall.enable = true;        # replaces ufw
   zramSwap.enable = true;                   # replaces zram-generator
boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
boot.kernelModules = [ "v4l2loopback" ];
boot.extraModprobeConfig = ''
  options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
'';

programs.obs-studio = {
  enable = true;
  enableVirtualCamera = true;   # sets up the udev/module glue for you
  plugins = with pkgs.obs-studio-plugins; [
    obs-pipewire-audio-capture   # capture individual app audio on wayland
    obs-backgroundremoval        # green-screen without a green screen
    obs-vkcapture                # game capture for vulkan/opengl on wayland
    wlrobs                       # wlroots screen capture (not for hyprland — use pipewire portal)
  ];
};
  
  # OpenSSH
  services.openssh.enable = true;



  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}

