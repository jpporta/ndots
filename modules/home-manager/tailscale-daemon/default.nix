{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.tailscale-daemon;

  # The writter-deck is a non-NixOS host that can't create a real tailscale0
  # interface (missing TUN drivers). Userspace networking avoids that need.
  #
  # Layout:
  #   - Socket:    %t/tailscaled/tailscaled.sock     (per-session tmpfs)
  #   - State:     $HOME/.local/state/tailscale/...  (persistent)
  #
  # In systemd specifiers:
  #   %t  → $XDG_RUNTIME_DIR (=/run/user/$UID)        — works in systemd 249+
  #   %S  → $XDG_CONFIG_HOME (! NOT $XDG_STATE_HOME) — works in systemd 249+
  #
  # Because %S points at the wrong place, we hard-code the persistent state
  # path under $HOME/.local/state/, which is the XDG_STATE_HOME default.
  homeDir   = config.home.homeDirectory;
  stateDir  = "${homeDir}/.local/state/tailscale";
  stateFile = "${stateDir}/tailscaled.state";

  # Becomes "$XDG_RUNTIME_DIR/tailscaled/tailscaled.sock" at runtime.
  socketFile = "%t/tailscaled/tailscaled.sock";
in
{
  options.custom.tailscale-daemon = {
    enable = lib.mkEnableOption ''
      Tailscale daemon (tailscaled) running as a systemd user service with
      userspace networking. For non-NixOS hosts without TUN device drivers.
    '';

    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        If true, run `tailscale up --accept-routes` automatically on first
        start. Otherwise you'll need to authenticate manually once.
      '';
    };

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to accept DNS settings from the coordination server.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create the persistent state dir up front so the systemd service can
    # write to it immediately.
    home.activation.createTailscaleDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.escapeShellArg stateDir}
      run chmod 0700 ${lib.escapeShellArg stateDir}
    '';

    # Export the socket path (systemd-249-expanded) so any tool (systray,
    # scripts) picks the user-scope daemon automatically. Note: this
    # contains a literal `%t` which systemd will expand when the daemon
    # or its consumers run.
    home.sessionVariables.TAILSCALED_SOCKET = "/run/user/$(id -u)/tailscaled/tailscaled.sock";

    home.packages = [
      pkgs.tailscale

      # Wrapper so the CLI client can find the user-scope socket without flags.
      (pkgs.writeShellApplication {
        name = "ts";
        runtimeInputs = [ pkgs.tailscale ];
        text = ''
          exec tailscale --socket="/run/user/$(id -u)/tailscaled/tailscaled.sock" "$@"
        '';
      })
    ];

    systemd.user.services.tailscaled = {
      Unit = {
        Description = "Tailscale daemon (userspace networking, no TUN device)";
        # No "After=default.target" — it would deadlock since default.target
        # is what brings us up. Just wait for the runtime dir to exist.
        RequiresMountsFor = [ "%t" ];
        # Survive transient network blips / flap.
        StartLimitIntervalSec = 60;
        StartLimitBurst = 5;
      };
      Service = {
        Type = "notify";
        ExecStart = lib.escapeShellArgs [
          "${pkgs.tailscale}/bin/tailscaled"
          "--tun=userspace-networking"
          "--state=${stateFile}"
          "--socket=${socketFile}"
        ];
        # systemd-managed runtime dir:
        #   $XDG_RUNTIME_DIR/tailscaled  (RuntimeDirectory, mode 0700)
        # State is in $HOME/.local/state/tailscale and managed by us, not
        # via StateDirectory, so we don't need to fight protectHome.
        RuntimeDirectory = "tailscaled";
        RuntimeDirectoryMode = "0700";
        Restart = "on-failure";
        RestartSec = 5;
        # Light sandboxing. systemd user services can't drop capabilities
        # the way the system unit can, so we keep restrictions to a
        # conservative subset that doesn't fight journald.
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "%t/tailscaled" "${stateDir}" ];
      };
      Install.WantedBy = [ "default.target" "graphical-session.target" ];
    };

    # One-shot: authenticate on first start if not already logged in.
    # Idempotent: tailscale up is a no-op once you're logged in.
    systemd.user.services.tailscale-up = {
      Unit = {
        Description = "Tailscale: authenticate and connect";
        After = [ "tailscaled.service" ];
        Requires = [ "tailscaled.service" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.escapeShellArgs ([
          "${pkgs.tailscale}/bin/tailscale"
          "--socket=${socketFile}"
          "up"
          (if cfg.acceptRoutes then "--accept-routes" else "--no-accept-routes")
          (if cfg.acceptDns then "--accept-dns=true" else "--accept-dns=false")
        ]);
        # Don't fail the whole stack if auth isn't completed yet.
        SuccessExitStatus = [ 0 1 ];
      };
      Install.WantedBy = [ "default.target" "graphical-session.target" ];
    };
  };
}
