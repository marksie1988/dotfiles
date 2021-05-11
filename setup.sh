install() {
    echo -n "Checking required apps installed"

    if [ -x "$(command -v apt-get)" ]; then
		sudo apt install $1 -y
    elif [ -x "$(command -v yum)" ]; then
 		sudo yum install -y $1
	elif [ -x "$(command -v brew)" ]; then
		brew install $1
	elif [ -x "$(command -v pkg)" ]; then
		sudo pkg install $1
	elif [ -x "$(command -v pacman)" ]; then
		sudo pacman -S $1
	else
		echo "I'm not sure what your package manager is! Please install $1 on your own and run this deploy script again. Tests for package managers are in the deploy script you just ran starting at line 4. Feel free to make a pull request at https://github.com/marksie1988/dotfiles-new :)" 
	fi 

}

check_for_software() {
	echo "Checking to see if $1 is installed"
	if ! [ -x "$(command -v $1)" ]; then
		install $1
	else
		echo "$1 is installed."
	fi
}

check_default_shell() {
	if [ -z "${SHELL##*fish*}" ] ;then
			echo "Default shell is fish."
	else
		echo -n "Default shell is not fish. Do you want to chsh -s \$(which fish)? (y/n)"
		old_stty_cfg=$(stty -g)
		stty raw -echo
		answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
		stty $old_stty_cfg && echo
		if echo "$answer" | grep -iq "^y" ;then
			chsh -s $(which fish)
		else
			echo "Warning: Your configuration won't work properly. If you exec fish, it'll exec tmux which will exec your default shell which isn't fish."
		fi
	fi
}

check_for_software fish
echo
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
echo
check_for_software neovim
echo
check_for_software peco
echo 
check_for_software exa
echo
check_default_shell
echo
fisher install jethrokuan/z
echo

mkdir ~/old-dotfiles
cp -rf ~/.vimrc ~/old-dotfiles/.vimrc.old
cp -rf ~/.config/fish ~/old-dotfiles/.config/fish.old
cp -rf ~/.tmux.conf ~/old-dotfiles/.tmux.conf.old
cp -rf ~/.gitconfig ~/old-dotfiles/.gitconfig.old

cp -rf `ls -A ~/dotfiles-new/.* | grep -v ".git"` ~/

echo
echo "Please log out and log back in for default shell to be initialized."