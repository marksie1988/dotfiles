time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }
printf '%.s─' $(seq 1 $(tput cols))

echo "Checking dependencies are installed..."
if ! [ -x "$(command -v yadm)" ]; then
  echo "Installing yadm..."
  sudo apt install yadm -y
fi
if ! [ -x "$(command -v zsh)" ]; then
  echo "Installing zsh..."
  sudo apt install zsh -y
fi
if ! [ -x "$(command -v curl)" ]; then
  echo "Installing curl..."
  sudo apt install curl -y
fi
if ! [ -x "$(command -v unzip)" ]; then
  echo "Installing unzip..."
  sudo apt install unzip -y
fi
if ! [ -x "$(command -v wget)" ]; then
  echo "Installing wget..."
  sudo apt install wget -y
fi


starship_install() {
	cd /tmp
	curl -s https://api.github.com/repos/starship/starship/releases/latest \
	| grep browser_download_url \
	| grep x86_64-unknown-linux-gnu \
	| cut -d '"' -f 4 \
	| wget -qi -
	tar xvf starship-*.tar.gz
	sudo mv /tmp/starship /usr/local/bin/
	rm -rf /tmp/starship*
	starship -V
}
if ! [ -x "$(command -v starship)" ]; then
  	echo "Installing Starship..."
	starship_install
else
	starship_latest() {
		curl -s https://api.github.com/repos/starship/starship/releases/latest | grep tag_name | cut -d '"' -f 4 | cut -d "v" -f 2
	}
	starship_current() {
		starship -V | grep starship | cut -d ' ' -f 2
	}
	if [ $(starship_latest) != $(starship_current) ]; then
		echo "Upgrading Starship..."
		starship_install
	fi
fi

exa_install() {
	cd /tmp
	curl -s https://api.github.com/repos/ogham/exa/releases/latest \
	| grep browser_download_url \
	| grep linux-x86_64-v \
	| cut -d '"' -f 4 \
	| wget -qi -
	unzip exa-*.zip -d /tmp/exa
	sudo mv /tmp/exa/bin/exa /usr/local/bin/
	mkdir -p ~/zsh/plugins/exa
	mv /tmp/exa/completions/exa.zsh ~/zsh/plugins/exa/
	rm -rf /tmp/exa*
}
if  ! [ -x "$(command -v exa)" ]; then
  	echo "Installing exa..."
	exa_install
else
	exa_latest() {
		curl -s https://api.github.com/repos/ogham/exa/releases/latest | grep tag_name | cut -d '"' -f 4
	}
	exa_current() {
		exa --version | grep v | cut -d " " -f 1
	}
	if [ $(exa_latest) != $(exa_current) ]; then
		echo "Upgrading exa..."
		exa_install
	fi
fi

echo " Checking for new dotfiles release..."

current() {
    yadm describe --tags
}
latest() {
	yadm fetch --tags
    yadm describe --tags --abbrev=0 origin/master
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
	echo "Reloading profile..."
	source ~/.zshrc
	echo "Done"
fi
# Check submodules are all installed and updated
cd ~
yadm submodule update --init --recursive -q

printf '%.s─' $(seq 1 $(tput cols))
source ~/zsh/zshrc.sh
