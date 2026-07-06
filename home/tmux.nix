{ ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-t"; # was: unbind C-b; set -g prefix C-t
    keyMode = "vi";
    terminal = "xterm-256color";
    historyLimit = 64096;
    escapeTime = 10;

    # Remaining .tmux.conf verbatim (Rose Pine Moon theme + custom bindings).
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

      # look'n feel - Rose Pine Moon
      set-option -g status-fg "#9ccfd8"
      set-option -g status-bg "#2a273f"
      set -g pane-active-border-style fg="#ea9a97",bg=default
      set -g window-style fg="#908caa",bg=default
      set -g window-active-style fg="#3e8fb0",bg=default

      # default statusbar colors
      set-option -g status-style bg="#2a273f",fg="#f6c177",default
      # default window title colors
      set-window-option -g window-status-style fg="#6e6a86",bg="#232136",dim
      # active window title colors
      set-window-option -g window-status-current-style fg="#ea9a97",bg=default,bright
      # pane border
      set-option -g pane-border-style fg="#2a273f"
      set-option -g pane-active-border-style fg="#f6c177",bg="#2a273f"
      # message text
      set-option -g message-style bg="#2a273f",fg="#ea9a97"
      # pane number display
      set-option -g display-panes-active-colour "#3e8fb0"
      set-option -g display-panes-colour "#ea9a97"
      # clock
      set-window-option -g clock-mode-colour "#9ccfd8"

      # allow the title bar to adapt to whatever host you connect to
      set -g set-titles on
      set -g set-titles-string "#T"
    '';
  };
}
