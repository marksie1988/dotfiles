time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }
printf '%.s─' $(seq 1 $(tput cols))
echo " Checking for new dotfiles release..."

current() {
    yadm describe --tags
}
hash(){
	yadm --work-tree=../ rev-list --tags='v*' --max-count=1 2> /dev/null
}
latest() {
    yadm --work-tree=../ describe --tags $(hash)
}
echo "Current: $(current) Latest: $(latest)"

({yadm fetch -q} &> /dev/null)

if [ $(yadm rev-list HEAD...origin/master | wc -l) = 0 ]
then
	echo " Already up-to-date."
else
	echo " Updates Detected:"
	(yadm log ..@{u} --pretty=format:%Cred%aN:%Creset\ %s\ %Cgreen%cd)
	echo " Pulling Updates..."
	(yadm pull -q && yadm submodule update --init --recursive)
fi
printf '%.s─' $(seq 1 $(tput cols))
source ~/zsh/zshrc.sh
