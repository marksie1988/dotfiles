alias nrb='npm run build'
alias sha256='shasum -a 256'
alias rand32='openssl rand -base64 32'

# Easier navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Git Aliases
alias g="git"
alias gs='git status -s'
alias gf='git fetch --prune'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gps='git push'
alias gpsh='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gcb='git checkout -b'
alias grs='git reset'
alias grsh='git reset --hard'
alias gcm='git add -A && git commit -m'
alias undo='git reset HEAD~1 --mixed'
alias gr='git remote -v'
alias ssha='eval $(ssh-agent) && ssh-add'
alias gum='git fetch upstream && git merge upstream/master'

# Automtion
alias k="kubectl"
alias h="helm"
alias tf="terraform"
alias a="ansible"
alias ap="ansible-playbook"
alias code="open -a 'Visual Studio Code'"

alias tg="terragrunt"

# vim / nano alias
alias vi="hx"
alias nano="hx"

# ALIAS COMMANDS
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias tree="eza --tree --icons"
alias grep='grep --color'

# IP Information
alias pubip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Show human friendly numbers and colors
alias df='df -h'
alias du='du -h -d 2'

# Tmux
alias t='tmux'
alias ta='tmux a'

alias shrug="echo '¯\_(ツ)_/¯'"
alias neofetch='neofetch --ascii_colors 2 7 --colors 2 7 2 2 7 7 2'
