{
  pkgs,
  inputs,
  ...
}:

# Nix-managed CLI tools and apps shared by every Mac. Prefer adding things here;
# fall back to Homebrew (./homebrew.nix) only for casks, macOS-only tools, or
# packages that are missing/broken in nixpkgs on darwin.
{
  environment.systemPackages =
    (with pkgs; [
      # Core utilities & Stow
      stow # symlinks ~/ndots/config/<pkg> into $HOME
      git
      gh # GitHub CLI
      lazygit # git TUI
      delta # syntax-highlighting pager for git diffs
      curl
      wget
      htop
      tree
      unzip
      zip
      tldr # simplified man pages
      jq # JSON processor
      ripgrep # fast grep (rg)
      fd # fast find
      localsend # AirDrop-like file sharing with Linux/Android

      # Messaging
      slack
      whatsapp-for-mac

      # Editors & Shell
      neovim
      vim
      tmux
      zoxide # smarter cd (z)
      fzf # fuzzy finder
      eza # modern ls
      bat # cat with syntax highlighting
      oh-my-posh # prompt theme engine
      notion-app

      # Dev languages & tools
      go
      cargo
      rustc
      nodejs
      pnpm
      python3
      tree-sitter
      stylua # Lua formatter
      lua5_2
      luarocks
      pandoc # document converter

      # Security & CLI
      gnupg
      pinentry_mac # GUI passphrase prompt for gpg-agent
      rbw # Bitwarden CLI

      # Containers & local dev stack
      podman # daemonless container runtime (uses libkrun via krunkit)
      docker-compose # compose engine used by `podman compose`
      mkcert # local CA + locally trusted TLS certs for dev domains
      uv # fast Python package/project manager
    ])
    ++ [
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent
    ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
