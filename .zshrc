# Profiling
if [[ -n "$ZSH_PROFILE" ]]; then
  zmodload zsh/zprof
fi

# Load local environment variables
if [[ -f ~/.env.local ]]; then
  source ~/.env.local
fi

# Add completions to fpath
fpath=(~/.zsh/completions $fpath)

source ~/.zsh/zshrc_manager.sh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# Load local environment
if [[ -f "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

if [[ -n "$ZSH_PROFILE" ]]; then
  zprof
fi