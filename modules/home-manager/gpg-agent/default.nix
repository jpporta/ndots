{
  config,
  lib,
  pkgs,
  ...

}:

let
  cfg = config.custom.gpg-agent;

  # gpg-agent with SSH support lets `ssh-add ~/.ssh/id_ed25519` cache
  # the key: pinentry prompts once for the passphrase, then serves the
  # unlocked key to any SSH client that points at SSH_AUTH_SOCK.
  #
  # The agent exposes its SSH-emulation socket at
  #   $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
  # via the upstream gpg-agent-ssh.socket unit that ships with
  # gnupg. We do NOT redeclare these sockets via
  # `systemd.user.sockets.*` because the user unit search path
  # shadows the upstream file, and our generated copy would be
  # missing the `Service=gpg-agent.service` directive, breaking
  # socket activation. Instead we enable the upstream units through
  # the home-manager activation script.
in
{
  options.custom.gpg-agent = {
    enable = lib.mkEnableOption ''
      GnuPG agent with SSH support, so passphrase-protected SSH keys
      can be unlocked once via pinentry and reused for the session.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnupg
      pinentry-tty
    ];

    # Drop the agent config into ~/.gnupg/gpg-agent.conf. gpg-agent
    # picks it up on first launch.
    home.file.".gnupg/gpg-agent.conf" = {
      text = ''
        # Tailscale / ndots gpg-agent config
        enable-ssh-support
        pinentry-program ${lib.getExe pkgs.pinentry-tty}
        default-cache-ttl 1800
        default-cache-ttl-ssh 1800
        max-cache-ttl 7200
        max-cache-ttl-ssh 7200
      '';
    };

    # Make sure ~/.gnupg exists with the right perms before anything
    # else tries to use it. gpg-agent refuses to start if its config
    # dir is too permissive.
    home.activation.setupGpgDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p $HOME/.gnupg
      run chmod 0700 $HOME/.gnupg
    '';

    # Export the SSH agent socket path. The agent's SSH-emulation
    # socket lives at $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh; we
    # can't use systemd's %t in a session variable, so we expand
    # $XDG_RUNTIME_DIR at shell init.
    home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";

    # Enable the upstream gpg-agent socket units (gpg-agent.socket,
    # gpg-agent-ssh.socket, gpg-agent-extra.socket,
    # gpg-agent-browser.socket) and reload the user systemd manager
    # so the new wants/ links take effect immediately.
    #
    # This is a no-op on subsequent runs because enable just creates
    # the symlink idempotently.
    home.activation.enableGpgAgentSockets = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
      for u in gpg-agent.socket gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket; do
        ${pkgs.systemd}/bin/systemctl --user enable "$u" >/dev/null 2>&1 || true
      done
      ${pkgs.systemd}/bin/systemctl --user daemon-reload >/dev/null 2>&1 || true
      ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent >/dev/null 2>&1 || true
    '';
  };
}
