#!/bin/sh
#
# this script should be run via curl:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/marksie1988/dotfiles-new/master/install.sh)"
# or via fetch:
#   sh -c "$(fetch -o - https://raw.githubusercontent.com/marksie1988/dotfiles-new/master/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the ditfiles repository:
#   DOTFILES=~/.dotfiles sh install.sh
#
# Respects the following environment variables:
#   DOTFILES     - path to the dotfiles repository folder (default: $HOME/dotfiles)
#   REPO    - name of the GitHub repo to install from (default: marksie1988/dotfiles)
#   REMOTE  - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH  - branch to check out immediately after install (default: master)
#
# Other options:
#   CHSH       - 'no' means the installer will not change the default shell (default: yes)
#   RUNFISH     - 'no' means the installer will not run fish after the install (default: yes)
#
# You can also pass some argumeyesnts to the install script to set some these options:
#   --skip-chsh: has the same behavior as setting CHSH to 'no'
#   --unattended: sets both CHSH and RUNFISH to 'no'
# For example:
#   sh install.sh --unattended
# or:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
#
set -e

# Track if $DOTFILES was provided
custom_dotfiles=${DOTFILES:+yes}

# Default settings
DOTFILES=${DOTFILES:~/dotfiles}
REPO=${REPO:-marksie1988/dotfiles}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}


# Other options
CHSH=${CHSH:-yes}
RUNFISH=${RUNFISH:-yes}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

fmt_error() {
	printf '%sError: %S%S\n' "$BOLD$RED" "$*" "$RESET" >&2
}

fmt_underline() {
  printf '\033[4m%s\033[24m\n' "$*"
}

fmt_code() {
  # shellcheck disable=SC2016 # backtic in single-quote
  printf '`\033[38;5;247m%s%s`\n' "$*" "$RESET"
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

setup_dotfiles() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	echo "${BLUE}Cloning dotfiles..${RESET}"

	command_exists git || {
		fmt_error "git is not installed"
		exit 1
	}

	ostype=$(uname)
	if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -q msysgit; then
		fmt_error "Windows/MSYS Git is not supported on Cygwin"
		fmt_error "Make sure the Cygwin git package is installed and is first on the \$PATH"
		exit 1
	fi

	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch "$BRANCH" "$REMOTE" "$DOTFILES" || {
		fmt_error "git clone of dotfiles repo failed"
		exit 1
  	}

  echo
}

setup_fish() {
  # Keep most recent old .config/fish at .config/fish-pre-dotfiles, and older ones
  # with datestamp of installation that moved them aside, so we never actually
  # destroy a user's original fish config
  echo "${BLUE}Looking for an existing fish config...${RESET}"

  # Must use this exact name so uninstall.sh can find it
  OLD_FISHCONF=~/.config/fish-pre-dotfiles
  if [ -d ~/.config/fish ] || [ -h ~/.config/fish ]; then
	echo "${YELLOW}Found ~/.config/fish.${RESET} ${GREEN}Keeping...${RESET}"
	return
  
	if [ -d "$OLD_FISHCONF" ]; then
	  OLD_OLD_FISHCONF="${OLD_FISHCONF}-$(date +%Y-%m-%d_%H-%M-%S)"
	  if [ -e "$OLD_OLD_FISHCONF" ]; then
		fmt_error "$OLD_OLD_FISHCONF exists. Can't back up ${OLD_FISHCONF}"
		fmt_error "re-run the installer again in a couple of seconds"
		exit 1
	  fi
	  mv "$OLD_FISHCONF" "${OLD_OLD_FISHCONF}"

	  echo "${YELLOW}Found old ~/.config/fish-pre-dotfiles." \
		"${GREEN}Backing up to ${OLD_OLD_FISHCONF}${RESET}"
	fi
	echo "${YELLOW}Found ~/.config/fish.${RESET} ${GREEN}Backing up to ${OLD_FISHCONF}${RESET}"
	mv ~/.config/fish "$OLD_FISHCONF"
  fi

  echo "${GREEN}Copying the dotfiles fish config.${RESET}"

  cp -rf `ls -A ~/dotfiles-new/ | grep -v ".git"` ~/

  echo
}

setup_shell() {
  # Skip setup if the user wants or stdin is closed (not running interactively).
  if [ "$CHSH" = no ]; then
	return
  fi

  # If this user's login shell is already "fish", do not attempt to switch.
  if [ "$(basename -- "$SHELL")" = "fish" ]; then
	return 
  fi

  # If this platform doesn't provide a "chsh" command, bail out.
  if ! command_exists chsh; then
	cat <<EOF
I can't change your shell automatically because this system does not have chsh.
${BLUE}Please manually change your default shell to fish${RESET}
EOF
	return
  fi

  echo "${BLUE}Time to change your default shell to fish:${RESET}"

  # Prompt for user choice on changing the default login shell
  printf '%sDo you want to change your default shell to fish? [Y/n]%s ' \
	"$YELLOW" "$RESET"
  read -r opt
  case $opt in
	y*|Y*|"") echo "Changing the shell..." ;;
	n*|N*) echo "Shell change skipped."; return ;;
	*) echo "Invalid choice. Shell change skipped."; return ;;
  esac

  # Check if we're running on Termux
  case "$PREFIX" in
	*com.termux*) termux=true; fish=fish ;;
	*) termux=false ;;
  esac

  if [ "$termux" != true ]; then
	# Test for the right location of the "shells" file
	if [ -f /etc/shells ]; then
	  shells_file=/etc/shells
	elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
	  shells_file=/usr/share/defaults/etc/shells
	else
	  fmt_error "could not find /etc/shells file. Change your default shell manually."
	  return
	fi

	# Get the path to the right fish binary
	# 1. Use the most preceding one based on $PATH, then check that it's in the shells file
	# 2. If that fails, get a fish path from the shells file, then check it actually exists
	if ! fish=$(command -v fish) || ! grep -qx "$fish" "$shells_file"; then
	  if ! fish=$(grep '^/.*/fish$' "$shells_file" | tail -1) || [ ! -f "$fish" ]; then
		fmt_error "no fish binary found or not present in '$shells_file'"
		fmt_error "change your default shell manually."
		return
	  fi
	fi
  fi

  # We're going to change the default shell, so back up the current one
  if [ -n "$SHELL" ]; then
	echo "$SHELL" > ~/.shell.pre-dotfiles
  else
	grep "^$USERNAME:" /etc/passwd | awk -F: '{print $7}' > ~/.shell.pre-dotfiles
  fi

  # Actually change the default shell to fish
  if ! chsh -s "$fish"; then
	fmt_error "chsh command unsuccessful. Change your default shell manually."
  else
	export SHELL="$fish"
	echo "${GREEN}Shell successfully changed to '$fish'.${RESET}"
  fi

  echo
}


main() {
  # Run as unattended if stdin is not a tty
  if [ ! -t 0 ]; then
	RUNFISH=no
	CHSH=no
  fi

  # Parse arguments
  while [ $# -gt 0 ]; do
	case $1 in
	  --unattended) RUNFISH=no; CHSH=no ;;
	  --skip-chsh) CHSH=no ;;
	esac
	shift
  done

  setup_color

  if ! command_exists fish; then
	echo "${YELLOW}Fish is not installed.${RESET} Please install fish first."
	exit 1
  fi

  if [ -d "$DOTFILES" ]; then
	echo "${YELLOW}The \$DOTFILES folder already exists ($DOTFILES).${RESET}"
	if [ "$custom_dotfiles" = yes ]; then
	  cat <<EOF

You ran the installer with the \$DOTFILES setting or the \$DOTFILES variable is
exported. You have 3 options:

1. Unset the DOTFILES variable when calling the installer:
   $(fmt_code "DOTFILES= sh install.sh")
2. Install dotfiles to a directory that doesn't exist yet:
   $(fmt_code "DOTFILES=path/to/new/dotfiles/folder sh install.sh")
3. (Caution) If the folder doesn't contain important information,
   you can just remove it with $(fmt_code "rm -r $DOTFILES")

EOF
	else
	  echo "You'll need to remove it if you want to reinstall."
	fi
	exit 1
  fi

  setup_dotfiles
  setup_fish
  setup_shell

  printf %s "$GREEN"
  cat <<'EOF'
  The dotfiles are now installed!
EOF
  printf %s "$RESET"

  if [ $RUNDOTFILES = no ]; then
	echo "${YELLOW}Run fish to try it out.${RESET}"
	exit
  fi

  exec fish -l
}

main "$@"












#echo
#curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
#echo
#check_for_software neovim
#echo
#check_for_software peco
#echo 
#check_for_software exa
#echo
#fisher install jethrokuan/z
#echo
#cp -rf `ls -A ~/dotfiles-new/ | grep -v ".git"` ~/
#echo
#echo "Please log out and log back in for default shell to be initialized."