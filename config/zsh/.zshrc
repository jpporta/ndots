# ---------------------------------------------------------
# Environment & PATH
# ---------------------------------------------------------
if [ "$(uname)" = "Darwin" ]; then
  # Homebrew casks install GUI apps in /Applications; shell commands such as
  # `kitty` are exposed by Homebrew's prefix (usually /opt/homebrew/bin).
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  export BROWSER="open"
else
  export BROWSER="zen-beta"
fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
export EDITOR="nvim"

# GPG TTY
export GPG_TTY="${GPG_TTY:-$(tty 2>/dev/null || echo '')}"
if command -v gpg-connect-agent >/dev/null 2>&1; then
  gpg-connect-agent --quiet updatestartuptty /bye > /dev/null 2>&1
fi

# ---------------------------------------------------------
# History settings
# ---------------------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

set_opts=(
  HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
  NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
  NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
)
for opt in "${set_opts[@]}"; do
  setopt "$opt" 2>/dev/null
done
unset opt set_opts

# ---------------------------------------------------------
# Oh-My-Zsh & Plugins
# ---------------------------------------------------------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [ -d "$ZSH" ]; then
  plugins=(git jj rbw)
  source "$ZSH/oh-my-zsh.sh"
fi

# ---------------------------------------------------------
# Completions & Keybindings
# ---------------------------------------------------------
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey ' ' magic-space

# Inside tuios panes, Ctrl+h/j/k/l move the tuios focus (Neovim does the same
# at the edge of its splits, see nvim lua/jpporta/tuios.lua)
if [ "$TUIOS_ENV" = "1" ]; then
  for key direction in h left j down k up l right; do
    eval "_tuios-focus-$direction() { tuios focus-window --direction $direction >/dev/null 2>&1 }"
    zle -N "_tuios-focus-$direction"
    bindkey "^${(U)key}" "_tuios-focus-$direction"
  done
  unset key direction
fi

if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)"
fi

if command -v herdr >/dev/null 2>&1; then
  eval "$(command herdr completions zsh)"
fi

# Inside Herdr panes, restore Wayland environment variables and Kitty graphics capability
if [ -n "$HERDR_ENV" ]; then
  export KITTY_WINDOW_ID=1

  if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
    for sock in "$XDG_RUNTIME_DIR"/wayland-<->(N); do
      if [ -S "$sock" ]; then
        export WAYLAND_DISPLAY="$(basename "$sock")"
        break
      fi
    done
  fi

  if [ -z "$DISPLAY" ] && [ -n "$WAYLAND_DISPLAY" ]; then
    export DISPLAY=:0
  fi

  if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ] && [ -d "$XDG_RUNTIME_DIR/hypr" ]; then
    for sig in "$XDG_RUNTIME_DIR/hypr"/*(N); do
      if [ -d "$sig" ]; then
        export HYPRLAND_INSTANCE_SIGNATURE="$(basename "$sig")"
        break
      fi
    done
  fi
fi

# ---------------------------------------------------------
# Shell Integrations
# ---------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# oh-my-posh prompt
if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -f ~/.config/oh-my-posh/theme-current.json ]; then
    eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/theme-current.json)"
  elif [ -f ~/.config/oh-my-posh/config.json ]; then
    eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.json)"
  fi
fi

# Kitty shell integration
if test -n "$KITTY_INSTALLATION_DIR"; then
  export KITTY_SHELL_INTEGRATION="no-rc"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration 2>/dev/null
  kitty-integration 2>/dev/null
  unfunction kitty-integration 2>/dev/null
fi

# ---------------------------------------------------------
# Functions & Aliases
# ---------------------------------------------------------
function lg() {
  export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
  command lazygit "$@"
  if [ -f "$LAZYGIT_NEW_DIR_FILE" ]; then
    cd "$(cat "$LAZYGIT_NEW_DIR_FILE")"
    rm -f "$LAZYGIT_NEW_DIR_FILE" > /dev/null
  fi
}

alias -- :q="exit"
alias -- tx="tmuxinator"
alias -- n='nvim --listen /tmp/nvim$(od -An -N4 -tx /dev/urandom 2>/dev/null | tr -d " " || echo $RANDOM).sock'
alias -- ls="eza --icons --group-directories-first --color=always"
alias -- man="batman"
alias -- so="source ~/.zshrc"
alias -- zki="zk edit --interactive --notebook-dir=~/Documents/Notes"
alias -- enc="openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt"
alias -- backup="packup && rm ~/Documents/packup* && mv ~/packup* ~/Documents/ && rsync --archive --update --copy-links ~/Documents 192.168.3.200:/home/jpporta/ --info=progress2"
alias -- gn='git commit -m "$(date)"'
alias -- nixs="cd ~/ndots && git add . && sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos"
alias -- darwins="cd ~/ndots && git add . && darwin-rebuild switch --flake ~/ndots#\$(scutil --get LocalHostName)"
alias -- nix-search="nix --extra-experimental-features 'nix-command flakes' search nixpkgs"
alias -- nix-garbage="sudo nix-collect-garbage -d && sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos"
alias -- nix-update="sudo nix-channel --update && sudo nixos-rebuild switch --flake ~/ndots#jpporta-nixos"
alias -- s="sesh connect \$(sesh list | fzf)"
alias -- rot90="wlr-randr --output HDMI-A-1 --transform 90"
alias -- rot0="wlr-randr --output HDMI-A-1 --transform normal"
alias -- rotl="wlr-randr --output HDMI-A-1 --transform 270"
alias -- rot180="wlr-randr --output HDMI-A-1 --transform 180"
alias -- ts="tailscale --socket=/tmp/ts-$UID/tailscaled.sock"
alias -- ts-status="ts status"
alias -- ts-ping="ts ping -c 3 jpporta-nixos"
alias -- spf="superfile"
alias -- granola="nix run /mnt/work/nix-shells/granola"
alias -- c="claude"

# ---------------------------------------------------------
# Syntax Highlighting & Autosuggestions (from profiles if available)
# ---------------------------------------------------------
for sh_plugin in \
  /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  [ -f "$sh_plugin" ] && source "$sh_plugin"
done

# Fastfetch on interactive startup
if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# UtilityOS: use libkrun for podman machines
export CONTAINERS_MACHINE_PROVIDER="libkrun"
