{
  config,
  lib,
  pkgs,
  ...
}:

# Declares the SSH and GPG identities this host should have. Private key
# material and passphrases never enter the Nix store: the flake only records the
# public details, and the `setup-keys` command generates the keys interactively
# (prompting for passphrases) the first time it is run.
let
  cfg = config.custom.keys;
  home = config.users.users.${cfg.user}.home;

  sshKeyPath = "${home}/.ssh/id_${cfg.ssh.type}";

  gpgUserId =
    "${cfg.gpg.name}"
    + lib.optionalString (cfg.gpg.comment != null) " (${cfg.gpg.comment})"
    + " <${cfg.gpg.email}>";

  setupKeys = pkgs.writeShellApplication {
    name = "setup-keys";
    runtimeInputs = [
      pkgs.openssh
      pkgs.gnupg
    ];
    text = ''
      if [ "$(id -un)" != ${lib.escapeShellArg cfg.user} ]; then
        echo "setup-keys must be run as ${cfg.user}" >&2
        exit 1
      fi

      export GPG_TTY
      GPG_TTY=$(tty)

      # SSH key
      if [ -f ${lib.escapeShellArg sshKeyPath} ]; then
        echo "SSH key already exists at ${sshKeyPath}, skipping."
      else
        mkdir -p ${lib.escapeShellArg "${home}/.ssh"}
        chmod 700 ${lib.escapeShellArg "${home}/.ssh"}
        ssh-keygen \
          -t ${lib.escapeShellArg cfg.ssh.type} \
          -C ${lib.escapeShellArg cfg.ssh.comment} \
          -f ${lib.escapeShellArg sshKeyPath}
        # Store the passphrase in the macOS Keychain so the agent can unlock it.
        /usr/bin/ssh-add --apple-use-keychain ${lib.escapeShellArg sshKeyPath}
      fi

      # GPG key
      if gpg --list-secret-keys ${lib.escapeShellArg "<${cfg.gpg.email}>"} >/dev/null 2>&1; then
        echo "GPG secret key for ${cfg.gpg.email} already exists, skipping."
      else
        mkdir -p ${lib.escapeShellArg "${home}/.gnupg"}
        chmod 700 ${lib.escapeShellArg "${home}/.gnupg"}
        gpg --quick-generate-key \
          ${lib.escapeShellArg gpgUserId} \
          ${lib.escapeShellArg cfg.gpg.algorithm} \
          ${lib.escapeShellArg cfg.gpg.usage} \
          ${lib.escapeShellArg cfg.gpg.expire}
      fi

      echo
      echo "SSH public key:"
      cat ${lib.escapeShellArg "${sshKeyPath}.pub"}
      echo
      echo "GPG key:"
      gpg --list-secret-keys --keyid-format long ${lib.escapeShellArg "<${cfg.gpg.email}>"}
    '';
  };
in
{
  options.custom.keys = {
    enable = lib.mkEnableOption "declarative SSH and GPG key setup";

    user = lib.mkOption {
      type = lib.types.str;
      description = "User that owns the keys.";
    };

    ssh = {
      type = lib.mkOption {
        type = lib.types.enum [
          "ed25519"
          "ecdsa"
          "rsa"
        ];
        description = "SSH key type passed to `ssh-keygen -t`.";
      };
      comment = lib.mkOption {
        type = lib.types.str;
        description = "SSH key comment passed to `ssh-keygen -C`.";
      };
    };

    gpg = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Real name of the GPG user ID.";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Email of the GPG user ID.";
      };
      comment = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional comment of the GPG user ID.";
      };
      algorithm = lib.mkOption {
        type = lib.types.str;
        example = "ed25519";
        description = "Algorithm passed to `gpg --quick-generate-key` (e.g. ed25519, rsa4096).";
      };
      usage = lib.mkOption {
        type = lib.types.str;
        example = "sign";
        description = "Usage passed to `gpg --quick-generate-key` (e.g. sign, cert, default).";
      };
      expire = lib.mkOption {
        type = lib.types.str;
        example = "2y";
        description = "Expiration passed to `gpg --quick-generate-key` (e.g. 1y, 2y, never).";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # The gpg-agent launchd user agent requires a primary user.
    system.primaryUser = lib.mkDefault cfg.user;
    programs.gnupg.agent.enable = true;

    environment.systemPackages = [ setupKeys ];

    # Keys are created interactively, so activation only reminds when missing.
    system.activationScripts.postActivation.text = ''
      if [ ! -f ${lib.escapeShellArg sshKeyPath} ] \
        || ! sudo -H -u ${lib.escapeShellArg cfg.user} ${pkgs.gnupg}/bin/gpg --list-secret-keys ${lib.escapeShellArg "<${cfg.gpg.email}>"} >/dev/null 2>&1; then
        echo "SSH/GPG keys for ${cfg.user} are missing, run: setup-keys"
      fi
    '';
  };
}
