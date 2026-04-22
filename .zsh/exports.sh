# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# Ensure user-local bin is on PATH (used by lazygit / starship / bat symlink on Linux)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

export GPG_TTY=$(tty)
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"