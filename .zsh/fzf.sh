#!/bin/zsh

# fzf keybindings + completion, cross-platform fallbacks
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    # fzf >= 0.48 ships its own shell integration
    source <(fzf --zsh)
  elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    # Debian/Ubuntu apt package path (older fzf)
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && \
      source /usr/share/doc/fzf/examples/completion.zsh
  elif [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    # Homebrew fallback for older fzf
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && \
      source /opt/homebrew/opt/fzf/shell/completion.zsh
  fi

  # Tokyo Night palette to match starship/helix/tmux/k9s
  export FZF_DEFAULT_OPTS="\
--color=bg+:#283457,bg:#16161e,spinner:#ff9e64,hl:#7aa2f7 \
--color=fg:#c0caf5,header:#7aa2f7,info:#e0af68,pointer:#ff9e64 \
--color=marker:#ff9e64,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7aa2f7 \
--height=40% --layout=reverse --border"

  # Use ripgrep for fzf's file source when available
  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi
