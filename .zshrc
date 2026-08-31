# Profiling
if [[ -n "$ZSH_PROFILE" ]]; then
  zmodload zsh/zprof
fi

# Load local environment variables
# ~/.env.local is gitignored. Use it for machine-specific secrets / overrides, e.g.:
#   export OPENAI_API_KEY=...
#   export ANTHROPIC_API_KEY=...
#   export GITHUB_TOKEN=...
# Sourced early so later configs can read the values, but note that $PATH additions
# from .zsh/exports.sh have not been applied yet at this point.
if [[ -f ~/.env.local ]]; then
  source ~/.env.local
fi

# Repair fpath before anything autoloads.
#
# `brew shellenv` exports FPATH, so a long-lived shell freezes the version-pinned
# /opt/homebrew/Cellar/zsh/<version>/share/zsh/functions into the environment of
# every child. After `brew upgrade zsh` that directory is gone, and because zsh
# prefers an inherited FPATH over its compiled-in default it never re-adds the
# real one - so add-zsh-hook, is-at-least and colors fail to load and antidote's
# plugins spew "function definition file not found".
#
# Drop entries that no longer exist, then guarantee the current functions dir is
# present. /opt/homebrew/share/zsh/functions is a symlink into the active Cellar,
# so this keeps working across future zsh upgrades.
fpath=($^fpath(N-/))
[[ -d /opt/homebrew/share/zsh/functions ]] && fpath+=(/opt/homebrew/share/zsh/functions)

# Add completions to fpath
fpath=(~/.zsh/completions $fpath)
typeset -U fpath

source ~/.zsh/zshrc_manager.sh "$@"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# Load local environment
if [[ -f "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

# mise activates per-project tool versions from a mise.toml at the repo root,
# and exports any [env] it declares. Guarded so the shell still starts cleanly
# on a machine without it. Must come before zoxide: mise installs a chpwd hook
# too, and zoxide's needs to run last.
command -v mise >/dev/null && eval "$(mise activate zsh)"

# zoxide must be initialised last, after everything else (including the gcloud
# completion above) so its chpwd/precmd hook runs last and its doctor check
# stays quiet. Keep this at the very end of the file.
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

if [[ -n "$ZSH_PROFILE" ]]; then
  zprof
fi