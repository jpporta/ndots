{ ... }:

# Personal Mac used for engineering. Same toolset as velozient-mac via
# modules/darwin/base; only identity differs.
#
# First-time setup on a fresh Mac:
#   1. Install nix (Determinate or upstream installer) and Homebrew.
#   2. Set the hostname so darwin-rebuild picks this config by default:
#        sudo scutil --set HostName jpporta-mac
#        sudo scutil --set LocalHostName jpporta-mac
#   3. git clone https://github.com/jpporta/ndots ~/ndots
#   4. sudo nix run nix-darwin -- switch --flake ~/ndots#jpporta-mac
#   5. setup-keys        # generates SSH + GPG keys (prompts for passphrases)
#   6. cd ~/ndots/config && stow -t ~ zsh git nvim kitty aerospace lazygit \
#        oh-my-posh karabiner tmux bat direnv herdr tuicr
#      Do NOT stow gnupg on Macs: nix-darwin writes ~/.gnupg/gpg-agent.conf
#      (pinentry-mac) and ~/.config/git/host.gitconfig (email + signing key).
#      (karabiner must not pre-exist in ~/.config so stow links the whole dir;
#       Karabiner rewrites karabiner.json atomically and would break a file link)
#   7. Open Karabiner-Elements once and grant Input Monitoring / Login Items
#      so karabiner_grabber starts (caps lock = esc on tap, ctrl on hold).
{
  imports = [
    ../../modules/darwin/base
  ];

  networking.hostName = "jpporta-mac";
  networking.computerName = "jpporta-mac";

  custom.keys = {
    ssh.comment = "Main SSH key for jpporta's personal Mac";
    gpg = {
      email = "jpedro.porta@gmail.com";
      comment = "Main GPG key for jpporta's personal Mac";
    };
  };
}
