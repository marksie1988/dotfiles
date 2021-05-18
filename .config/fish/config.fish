set fish_greeting ""

set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias v nvim
command -qv nvim && alias vim nvim

set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH

# NodeJS
set -gx PATH node_modules/.bin $PATH

# Go
set -g GOPATH $HOME/go
set -gx PATH $GOPATH/bin $PATH

# Get the commit for the latest release.
echo "Check for new dotfiles release"
set -l cur (command git -C ~/dotfiles/.git describe --tags)
set -l hash (command git -C ~/dotfiles/.git --work-tree=../ rev-list --tags='v*' --max-count=1 2> /dev/null)
set -l latest (command git -C ~/dotfiles/.git --work-tree=../ describe --tags $hash)
echo "Current: "$cur" Latest:" $latest

if [ $cur != $latest ]
	# Checkout the release.
	echo "Checking out new release"
	command git -C ~/dotfiles/.git --work-tree=../ checkout --quiet tags/$latest
	cp -rf ~/dotfiles/(ls -A ~/dotfiles | grep -v ".git") ~/
	source ~/.config/fish/config.fish
else
	echo "Already up-to-date"
end

# NVM
function __check_rvm --on-variable PWD --description 'Do nvm stuff'
  status --is-command-substitution; and return

  if test -f .nvmrc; and test -r .nvmrc;
    nvm use
  else
  end
end

switch (uname)
  case Darwin
    source (dirname (status --current-filename))/config-osx.fish
  case Linux
    # Do nothing
  case '*'
    source (dirname (status --current-filename))/config-windows.fish
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
  source $LOCAL_CONFIG
end

source (dirname (status --current-filename))/shellder.fish
