time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

echo "Checking for new dotfiles release."
CURRENT=yadm describe --tags
GETHASH=yadm --work-tree=../ rev-list --tags='v*' --max-count=1 2> /dev/null
LATEST=yadm --work-tree=../ describe --tags $GETHASH

echo "Current: "$CURRENT" Latest:" $LATEST

({yadm fetch -q} &> /dev/null)

if [ $(yadm rev-list HEAD...origin/master | wc -l) = 0 ]
then
	echo "Already up-to-date."
else
	echo "Updates Detected:"
	(yadm log ..@{u} --pretty=format:%Cred%aN:%Creset\ %s\ %Cgreen%cd)
	echo "Pulling Updates..."
	(yadm pull -q && yadm submodule update --init --recursive)
fi

source ~/zsh/zshrc.sh
