# Adds sudo to start of line
zle -N add_sudo
bindkey "^s" add_sudo


# git_prepare function (git add, git commit and git push)
zle -N git_prepare
bindkey "^g" git_prepare

# git_root function (rot of current workspace)
zle -N git_root
bindkey "^h" git_root

# Bind home / end
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line

# Bind Delete Key
bindkey "^[[3~" delete-char

# Arrow key history search is set up in zshrc.sh via terminfo
