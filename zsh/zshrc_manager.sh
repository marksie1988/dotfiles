time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

# Run tmux if exists
#if command -v tmux>/dev/null; then
#	if [ "$DISABLE_TMUX" = "true" ]; then
#		echo "DISABLE_TMUX=true"
#	else
#		[ -z $TMUX ] && exec tmux
#	fi
#else
#	echo "tmux not installed. Run ./deploy to configure dependencies"
#fi

#echo "Checking for new dotfiles release."
#current = git -C ~/dotfiles/.git describe --tags
#hash = git -C ~/dotfiles/.git --work-tree=../ rev-list --tags='v*' --max-count=1 2> /dev/null
#latest = git -C ~/dotfiles/.git --work-tree=../ describe --tags $hash
#
#echo "Current: "$current" Latest:" $latest
#
#({
#    git fetch -q} &> /dev/null)
#
#if [ $({cd ~/dotfiles} &> /dev/null && git rev-list HEAD...origin/master | wc -l) = 0 ]
#then
#	echo "Already up-to-date."
#else
#	echo "Updates Detected:"
#	({cd ~/dotfiles} &> /dev/null && git log ..@{u} --pretty=format:%Cred%aN:%Creset\ %s\ %Cgreen%cd)
#	echo "Setting up..."
#	({cd ~/dotfiles} &> /dev/null && git pull -q && git submodule update --init --recursive)
#fi

source ~/zsh/zshrc.sh