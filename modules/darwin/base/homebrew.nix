{ config, ... }:

# Homebrew is used only for what nix can't (or shouldn't) provide on macOS:
# GUI apps (casks), tools missing from nixpkgs on darwin, and zsh plugins that
# config/zsh/.zshrc sources from the Homebrew prefix.
#
# Inventory taken from `brew leaves` / `brew list --cask` on velozient-mac.
# Also installed via brew there, but intentionally NOT declared because nix
# already provides them (./packages.nix): neovim, stow, uv,
# docker-compose, mkcert, pi-coding-agent, slack.
{
  homebrew = {
    enable = true;
    user = config.system.primaryUser;

    # This list is the source of truth: on every switch, brew formulae and
    # casks that are not declared here (or in the host file) are uninstalled.
    # Install by hand only for quick experiments; declare anything you keep.
    onActivation.cleanup = "uninstall";

    # Homebrew requires explicit trust before installing from third-party taps.
    taps = [
      {
        name = "nikitabobko/tap"; # AeroSpace window manager
        trusted = true;
      }
    ];

    brews = [
      # ---- Shell ----
      "zsh-syntax-highlighting" # fish-like syntax highlighting for zsh
      "zsh-autocomplete" # real-time type-ahead completion for zsh
      "zsh-autosuggestions" # fish-like autosuggestions from history

      # ---- Terminal multiplexers / TUIs ----
      "herdr" # agent multiplexer that lives in the terminal
      "tuios" # terminal UI "OS" / multiplexer
      "tuicr" # code review TUI with vim keybindings
      "tuxedo" # keyboard-driven todo.txt TUI
      "sl" # steam locomotive when you mistype `ls`

      # ---- Dev tooling ----
      "golang" # Go toolchain (nix also ships `go`; kept for brew-built tools)
      "nixfmt" # Nix formatter (used by nvim formatter)
      "eslint_d" # eslint daemon for fast editor linting
      "prettierd" # prettier daemon for fast editor formatting
      "resterm" # TUI client for .http/.rest files (HTTP, GraphQL, gRPC)

      # ---- Cloud & containers ----
      "awscli" # AWS command-line interface
      # podman comes from Homebrew, not nix: nixpkgs' podman only searches its own
      # libexec for machine helpers, so it can't find krunkit/vfkit on macOS.
      "podman" # daemonless container runtime; machines run on libkrun (CONTAINERS_MACHINE_PROVIDER)
      "krunkit" # libkrun/HVF VM launcher for podman machines (homebrew/core, not the slp/krun tap)
    ];

    casks = [
      # ---- Desktop & input ----
      "aerospace" # i3-like tiling window manager (config/aerospace)
      "karabiner-elements" # low-level keyboard remapping

      # ---- Terminal & browser ----
      "kitty" # GPU terminal emulator (config/kitty)
      "zen" # Firefox-based browser

      # ---- Utilities ----
      "handy" # speech-to-text
      "betterdisplay" # display scaling / management

      # ---- AI ----
      "claude" # Claude desktop app
      "claude-code" # Claude Code CLI
      "t3-code" # minimal GUI for AI coding agents

      # ---- Dev apps ----
      "beekeeper-studio" # SQL editor / database manager

      # ---- Media ----
      "spotify"
    ];
  };
}
