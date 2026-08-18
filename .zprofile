
eval "$(/opt/homebrew/bin/brew shellenv)"

# brew shellenv exports FPATH. An exported FPATH is inherited by every child
# process, so a) the list accumulates duplicates through nested shells, and
# b) the version-pinned /opt/homebrew/Cellar/zsh/<version>/share/zsh/functions
# entry is frozen into the environment. After `brew upgrade zsh` that path no
# longer exists, and because zsh prefers an inherited FPATH over its compiled-in
# default it never re-adds the real one - so compinit, _main_complete and
# bashcompinit fail with "function definition file not found".
# Untie it from the environment; fpath still works normally within the shell.
typeset +x FPATH
typeset -U fpath

# Created by `pipx` on 2025-04-30 15:14:40
export PATH="$PATH:/Users/stevenmarks/.local/bin"
