{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.custom.tmux = {
    enable = lib.mkEnableOption "enable tmux - terminal multiplexer";

    defaultShell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zsh;
      defaultText = lib.literalExpression "pkgs.zsh";
      description = ''
        Shell used by tmux for new windows and panes. Resolved to its
        store path so it works the same on NixOS and non-NixOS hosts.
      '';
      example = lib.literalExpression "pkgs.bash";
    };

    defaultTerminal = lib.mkOption {
      type = lib.types.str;
      default = "tmux-256color";
      description = "Default terminal type reported to applications inside tmux.";
    };

    catppuccinFlavor = lib.mkOption {
      type = lib.types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "mocha";
      description = "Catppuccin flavor used by the tmux theme plugin.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines appended verbatim to ~/.config/tmux/tmux.conf.";
    };
  };

  config = lib.mkIf config.custom.tmux.enable {
    home.packages = with pkgs; [
      tmux
    ];

    xdg.configFile."tmux/tmux.conf".text = ''
      ##### Terminal & Color Support #####

      # Kitty = truecolor
      set -g default-terminal "${config.custom.tmux.defaultTerminal}"
      set -ga terminal-overrides ",*:Tc"

      # Key line:
      set -g pane-border-style "bg=default"
      set -g pane-active-border-style "bg=default"
      set -g status-style "bg=default"
      set -g window-style "bg=default"
      set -g window-active-style "bg=default"
      set -g default-shell ${config.custom.tmux.defaultShell}/bin/${
        config.custom.tmux.defaultShell.meta.mainProgram or (lib.getName config.custom.tmux.defaultShell)
      }
      set -g extended-keys on
      set -g extended-keys-format csi-u

      # Reduce escape sequence delay (fixes lag in nvim/zsh)
      set -sg escape-time 0

      # Prefix to C-a
      # set -g prefix C-a
      # unbind C-b
      # bind-key C-a send-prefix

      # Mouse follow
      set -g mouse on

      # Split with better keys
      # unbind %
      # bind | split-window -h -c "#{pane_current_path}"
      # unbind '"'
      # bind - split-window -v -c "#{pane_current_path}"

      # Easy config reload
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf

      # Move between panes with tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'

      # No automatic window renaming
      set-option -g allow-rename off

      # Bell
      set -g visual-activity off
      set -g visual-bell off
      set -g visual-silence off
      setw -g monitor-activity off
      set -g bell-action none

      # Status bar
      set -g status-position top
      set -g status-justify left

      # Start index on 1
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Resize panes
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      bind -r H resize-pane -L 5
      bind -r m resize-pane -Z
      # Resize dragging
      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse

      # Vim motions
      set-window-option -g mode-keys vi

      # Selection
      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

      set -g @plugin "dweidner/tmux-theme"
      set -g @plugin 'tmux-plugins/tmux-yank'
      set -g @plugin 'tmux-plugins/tmux-cpu'
      set -g @plugin 'tmux-plugins/tmux-battery'
      set -g @plugin 'catppuccin/tmux#v2.1.1' # See https://github.com/catppuccin/tmux/tags for additional tags
      set -g @plugin 'b0o/tmux-autoreload'
      set -g @plugin 'tmux-plugins/tpm'

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Catppuccin config
      set -g @catppuccin_status_background none
      set -g @catppuccin_flavor '${config.custom.tmux.catppuccinFlavor}'
      set -g @catppuccin_window_status_style "basic"

      set -g status-right-length 100
      set -g status-left ""
      set -g status-left-length 200
      set -g status-right "#{E:@catppuccin_status_application}"
      set -agF status-right "#{E:@catppuccin_status_cpu}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"
      set -agF status-right "#{E:@catppuccin_status_battery}"


      # Neovim delay fix
      set -sg escape-time 0

      # Tmux keep session
      set-option -g detach-on-destroy off

      # Focus events
      set-option -g focus-events on
      bind-key z resize-pane -Z \; if-shell "tmux list-panes -F '#F' | grep -q Z" "set -g status off" "set -g status on"

      # Clipboard
      set -g set-clipboard on

      run '~/.tmux/plugins/tpm/tpm'
    ''
    + config.custom.tmux.extraConfig;
  };
}
