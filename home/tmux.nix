{ ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-t"; # was: unbind C-b; set -g prefix C-t
    keyMode = "vi";
    terminal = "xterm-256color";
    historyLimit = 64096;
    escapeTime = 10;

    # Remaining .tmux.conf verbatim (Tokyo Night theme + custom bindings).
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
      set-option -g repeat-time 0

      # send prefix to client inside window
      bind-key -n C-a send-prefix

      # Reload settings (home-manager writes the config under XDG)
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
      # Open current directory
      bind o run-shell "open #{pane_current_path}"
      bind -r e kill-pane -a

      # vim-like pane switching
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

      # Moving window
      bind-key -n C-S-Left swap-window -t -1 \; previous-window
      bind-key -n C-S-Right swap-window -t +1 \; next-window

      # Resizing pane
      bind -r C-k resize-pane -U 5
      bind -r C-j resize-pane -D 5
      bind -r C-h resize-pane -L 5
      bind -r C-l resize-pane -R 5

      set-option -g status-justify "left"

      # look'n feel — Tokyo Night
      set-option -g status-fg "#7DCFFF"
      set-option -g status-bg "#24283B"
      set -g pane-active-border-style fg="#ff9e64",bg=default
      set -g window-style fg="#A9B1DC",bg=default
      set -g window-active-style fg="#7AA2F7",bg=default

      # default statusbar colors
      set-option -g status-style bg="#24283B",fg="#E0AF68",default
      # default window title colors
      set-window-option -g window-status-style fg="#565f89",bg="#16161e",dim
      # active window title colors
      set-window-option -g window-status-current-style fg="#ff9e64",bg=default,bright
      # pane border
      set-option -g pane-border-style fg="#24283B"
      set-option -g pane-active-border-style fg="#E0AF68",bg="#24283B"
      # message text
      set-option -g message-style bg="#24283B",fg="#ff9e64"
      # pane number display
      set-option -g display-panes-active-colour "#7AA2F7"
      set-option -g display-panes-colour "#ff9e64"
      # clock
      set-window-option -g clock-mode-colour "#73DACA"

      # allow the title bar to adapt to whatever host you connect to
      set -g set-titles on
      set -g set-titles-string "#T"
    '';
  };
}
