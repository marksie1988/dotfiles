time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }
printf '%.s─' $(seq 1 $(tput cols))

# Detect the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  INSTALL_CMD="brew install"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  INSTALL_CMD="sudo apt install -y"
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi


# List of commands and corresponding package names
packages=(yadm zsh curl unzip wget jq)

# Function to check and install a command if it doesn't exist
install_if_missing() {
  local pkg=$1

  if ! command -v "$pkg" > /dev/null; then
    echo "Installing $pkg..."
    $INSTALL_CMD "$pkg"
  fi
}

echo "Checking dependencies are installed..."
# Loop through the list of packages and install if missing
for pkg in "${packages[@]}"; do
  install_if_missing "$pkg"
done

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
	starship_installed() {
		starship -V | grep starship | cut -d ' ' -f 2
	}
	if [ "$starship_installed" != "$starship_latest" ]; then
		echo "Upgrading Starship..."
		starship_install
	fi
fi

# Import EZA instaler function & execure
source ~/.zsh/installers/eza.sh
install_eza

echo " Checking for new dotfiles release..."

yadm fetch --tags 2>/dev/null

local_tag() {
    yadm describe --tags --abbrev=0
}
remote_tag() {
	yadm describe --tags --abbrev=0 origin/master
}
echo "Local: $(local_tag) Latest: $(remote_tag)"



if [ "$(yadm rev-list -n 1 $(local_tag))" != "$(yadm rev-list -n 1 $(remote_tag))" ]; then
	echo " Updates Detected:"
	(yadm log ..@{u} --pretty=format:%Cred%aN:%Creset\ %s\ %Cgreen%cd)
	echo " Pulling Updates..."
	(yadm pull -q)
	echo "Reloading profile..."
	source ~/.zshrc
	echo "Done"
else
	echo " Already up-to-date."
fi

printf '%.s─' $(seq 1 $(tput cols))
source ~/.zsh/zshrc.sh
