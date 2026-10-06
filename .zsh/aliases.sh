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
alias gp='git pull'
alias gpr='git pull --rebase'
alias gps='git push'
alias gpsh='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gcb='git checkout -b'
alias grs='git reset'
alias gcm='git add -A && git commit -m'
alias undo='git reset HEAD~1 --mixed'
alias gresethard='git reset --hard'
alias gr='git remote -v'
alias ssha='eval $(ssh-agent) && ssh-add'
alias gum='git fetch upstream && git merge upstream/master'
alias lg='lazygit'
# Force a dotfiles update check (bypasses the 24h fetch marker)
alias dfup='rm -f /tmp/.yadm_fetch_done && exec zsh'

# Automtion
alias k="kubectl"
alias h="helm"
alias tf="tofu"
alias tfp="tofu plan"
alias tfa="tofu apply"
alias a="ansible"
alias ap="ansible-playbook"

## use the below because mac and ubuntu do it different
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias code="open -a 'Visual Studio Code'"
else 
  if ! command -v code &> /dev/null; then
    if [ -x /snap/bin/code ]; then
      alias code="/snap/bin/code"
    elif [ -x /usr/bin/code ]; then
      alias code="/usr/bin/code"
    fi
  fi
fi


# vim / nano alias
alias vi="nvim"
alias nano="nvim"

# ALIAS COMMANDS
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias tree="eza --tree --icons"
alias grep='grep --color'

# IP Information
alias pip="dig +short myip.opendns.com @resolver1.opendns.com"
alias lip="ipconfig getifaddr en0"
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
