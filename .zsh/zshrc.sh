# NVM lazy load
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  alias nvm='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && nvm'
  alias node='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && node'
  alias npm='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && npm'
fi

# Fix for arrow-key searching
# start typing + [Up-Arrow] - fuzzy find history forward
if [[ "${terminfo[kcuu1]}" != "" ]]; then
	autoload -U up-line-or-beginning-search
	zle -N up-line-or-beginning-search
	bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# start typing + [Down-Arrow] - fuzzy find history backward
if [[ "${terminfo[kcud1]}" != "" ]]; then
	autoload -U down-line-or-beginning-search
	zle -N down-line-or-beginning-search
	bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# History
# --
#
mkdir -p ~/.cache/zsh/
HISTFILE=~/.cache/zsh/history
HISTSIZE=100000
SAVEHIST=100000
setopt inc_append_history # To save every command before it is executed
setopt share_history # setopt inc_append_history

# Default Editor
# ---
#
export EDITOR=hx
export KUBE_EDITOR=hx

# Key Bindings
# ---
#
source ~/.zsh/keybindings.sh

# Alias
# ---
#
source ~/.zsh/aliases.sh

# Functions
# ---
#
source ~/.zsh/functions.sh


# Distribution Icon
# ---
#
source ~/.zsh/distribution.sh

# Plugins
# ---
#
source ~/.zsh/plugins.sh

# Exports / Path updates
# ---
#
source ~/.zsh/exports.sh

# fzf keybindings and completion
# ---
#
[[ -f ~/.zsh/fzf.sh ]] && source ~/.zsh/fzf.sh

# Shell integrations (atuin, zoxide, direnv)
# ---
#
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# Load Starship
eval "$(starship init zsh)"

# Auto-attach tmux only when opted in via TMUX_AUTOSTART=1
if [[ "$TMUX_AUTOSTART" == "1" ]] && command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  tmux attach || exec tmux
fi
