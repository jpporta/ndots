{
  pkgs,
  lib,
  inputs,
  ...
}:

let
  whisperModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin";
    hash = "sha256-ZNGCtEC5jVIDxPm9VBVE2ExgUZbE97hF36EfsjWU0eI=";
  };
  whisperCpp = pkgs.whisper-cpp.override { vulkanSupport = true; };
in
{
  systemd.user.services = {
    lan-mouse = {
      description = "Lan Mouse daemon";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.lan-mouse}/bin/lan-mouse daemon";
        Restart = "on-failure";
        RestartSec = 1;
      };
      wantedBy = [ "graphical-session.target" ];
    };

    power-profile-hypridle = {
      description = "Hypridle using the active power-profile config";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hypridle}/bin/hypridle -c %h/.config/hypr/hypridle-active.conf";
        Restart = "on-failure";
        RestartSec = 3;
      };
      wantedBy = [ "graphical-session.target" ];
    };

    alarm-scheduler = {
      description = "Scheduler for terminal alarms and timers";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "start-alarm-scheduler" ''
          exec alarm-scheduler
        ''}";
        Restart = "on-failure";
        RestartSec = 3;
      };
      wantedBy = [ "graphical-session.target" ];
    };

    whisper-server = {
      description = "whisper.cpp inference server for dictation";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${whisperCpp}/bin/whisper-server -m ${whisperModel} --port 8080 -l auto";
        Restart = "on-failure";
        RestartSec = 5;
      };
      wantedBy = [ "default.target" ];
    };

    ntfy-notify = {
      description = "ntfy push notification subscriber";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "start-ntfy-notify" ''
          username="$(${pkgs.rbw}/bin/rbw get --field username ntfy.joaoporta.com 2>/dev/null || true)"
          password="$(${pkgs.rbw}/bin/rbw get ntfy.joaoporta.com 2>/dev/null || true)"
          if [ -n "$username" ] && [ -n "$password" ]; then
            export NTFY_USER="$username:$password"
          fi
          exec ${pkgs.ntfy-sh}/bin/ntfy subscribe --from-config
        ''}";
        Restart = "on-failure";
        RestartSec = 10;
      };
      wantedBy = [ "graphical-session.target" ];
    };
  };

  # Make steam desktop item for pipewire available
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "steam-pipewire";
      desktopName = "Steam (Pipewire)";
      exec = "steam -pipewire %U";
      icon = "steam";
      type = "Application";
      categories = [ "Game" ];
      mimeTypes = [
        "x-scheme-handler/steam"
        "x-scheme-handler/steamlink"
      ];
    })
  ];
}
