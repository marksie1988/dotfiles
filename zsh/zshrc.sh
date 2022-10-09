# NVM lazy load
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  alias nvm='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && nvm'
  alias node='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && node'
  alias npm='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && npm'
fi

# Fix Interop Error that randomly occurs in vscode terminal when using WSL2
fix_wsl2_interop() {
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${i}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${i}_interop
        fi
    done
}

# Default Editor
# ---
#
export EDITOR=hx
export KUBE_EDITOR=hx

# Key Bindings
# ---
#
source ~/zsh/keybindings.sh

# Alias
# ---
#
source ~/zsh/aliases.sh

# Functions
# ---
#
source ~/zsh/functions.sh


# Distribution Icon
# ---
#
source ~/zsh/distribution.sh

# Load Starship
eval "$(starship init zsh)"
