time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }
printf '%.s─' $(seq 1 $(tput cols))

echo "Checking software is installed"
if ! [ -x "$(command -v yadm)" ]; then
  sudo apt install yadm -y
fi
if ! [ -x "$(command -v zsh)" ]; then
  sudo apt install zsh -y
fi

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
	(yadm pull -q)
fi
# Check submodules are all installed and updated
yadm submodule update --init --recursive -q



printf '%.s─' $(seq 1 $(tput cols))
source ~/zsh/zshrc.sh
