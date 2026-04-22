autoload -Uz compinit

ANTIDOTE_DIR="${ZDOTDIR:-$HOME}/.zsh/antidote"
PLUGINS_LIST="${ZDOTDIR:-$HOME}/.zsh/.zsh_plugins.txt"
PLUGINS_CACHE="${ZDOTDIR:-$HOME}/.zsh/.zsh_plugins.zsh"

# Bootstrap antidote on first run.
if [[ ! -d "$ANTIDOTE_DIR" ]]; then
  echo "Cloning antidote..."
  git clone --depth 1 https://github.com/mattmc3/antidote "$ANTIDOTE_DIR" >/dev/null 2>&1
fi

source "$ANTIDOTE_DIR/antidote.zsh"

# Rebuild the plugin bundle when the list changes.
if [[ ! -f "$PLUGINS_CACHE" || "$PLUGINS_LIST" -nt "$PLUGINS_CACHE" ]]; then
  antidote bundle <"$PLUGINS_LIST" >"$PLUGINS_CACHE"
fi

source "$PLUGINS_CACHE"

compinit
