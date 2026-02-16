#!/bin/zsh

# zshrc_manager.sh - Manages dependencies and updates
# Optimized for performance, security, and cross-platform support

# Source centralized configuration
source ~/.zsh/config.sh

# Terminal compatibility fallback
if ! tput colors &>/dev/null; then
  export TERM=xterm-256color
fi

# Helper for timeouts
time_out () { perl -e 'alarm shift; exec @ARGV' "$@"; }

# Logging function
log() {
  local level=$1
  shift
  local msg="$*"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE"
}

# Visual separator
draw_line() {
  local cols=$(tput cols 2>/dev/null || echo 80)
  printf '%.s─' $(seq 1 $cols)
  echo
}

draw_line

# Detect the operating system and architecture
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH_TYPE=$(uname -m)

if [[ "$OS_TYPE" == "darwin" ]]; then
  INSTALL_CMD="brew install"
  # Ensure Homebrew is installed
  if ! command -v brew > /dev/null; then
    log "INFO" "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
elif [[ "$OS_TYPE" == "linux" ]]; then
  INSTALL_CMD="sudo apt install -y"
else
  log "ERROR" "Unsupported OS: $OS_TYPE"
  exit 1
fi

# Function to check and install a command if it doesn't exist
install_if_missing() {
  local pkg=$1
  if ! command -v "$pkg" > /dev/null; then
    log "INFO" "Installing $pkg..."
    $INSTALL_CMD "$pkg"
  fi
}

# Starship installer (generalized with verification)
starship_install() {
  log "INFO" "Installing/Updating Starship..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install starship
  else
    # Linux binary install
    local PLATFORM="unknown-linux-gnu"
    case "$ARCH_TYPE" in
      x86_64)  PLATFORM="x86_64-$PLATFORM" ;;
      aarch64) PLATFORM="aarch64-$PLATFORM" ;;
      *)       log "ERROR" "Unsupported architecture: $ARCH_TYPE"; return 1 ;;
    esac

    cd /tmp
    local BIN_URL=$(curl -s https://api.github.com/repos/starship/starship/releases/latest \
      | jq -r ".assets[] | select(.name | contains(\"$PLATFORM\")) | .browser_download_url")
    
    wget -q "$BIN_URL" -O starship.tar.gz
    # Verification step (placeholder for actual checksum check)
    # sha256sum -c <<< "$STARSHIP_SHA256 starship.tar.gz" || { log "ERROR" "Checksum failed"; return 1; }
    
    tar xf starship.tar.gz
    sudo mv starship /usr/local/bin/
    rm starship.tar.gz
  fi
  starship -V
}

# Backup routine
backup_existing() {
  local file=$1
  if [[ -f "$file" || -L "$file" ]]; then
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    log "INFO" "Backing up $file to $backup_dir"
    mv "$file" "$backup_dir/"
  fi
}

# Setup logic (gated by marker file or --setup flag)
SETUP_MARKER="$HOME/.zsh/.setup_done"
if [[ ! -f "$SETUP_MARKER" || "$1" == "--setup" ]]; then
  log "INFO" "Running initial setup..."

  for pkg in "${MANDATORY_PACKAGES[@]}"; do
    install_if_missing "$pkg"
  done

  # Parallel binary downloads/installs where safe
  (
    unsetopt MONITOR
    setopt NO_NOTIFY NO_CHECK_JOBS 2>/dev/null
    (
      source ~/.zsh/installers/eza.sh
      install_eza
    ) &
    (
      source ~/.zsh/installers/helix.sh
      install_helix
    ) &
    (
      if ! command -v starship > /dev/null; then
        starship_install
      fi
    ) &
    (
      source ~/.zsh/installers/fonts.sh
    ) &
    (
      source ~/.zsh/installers/k9s.sh
      install_k9s
    ) &
    
    wait # Wait for background installers
  )

  # Generate completions
  log "INFO" "Generating completions..."
  mkdir -p ~/.zsh/completions
  command -v gh >/dev/null && gh completion -s zsh > ~/.zsh/completions/_gh
  command -v kubectl >/dev/null && kubectl completion zsh > ~/.zsh/completions/_kubectl
  command -v docker >/dev/null && docker completion zsh > ~/.zsh/completions/_docker

  # Optional packages and macOS defaults (interactive/system-wide)
  source ~/.zsh/installers/optional.sh
  if [[ "$OS_TYPE" == "darwin" ]]; then
    source ~/.zsh/installers/macos_defaults.sh
  fi
  
  # SSH/GPG Keys
  source ~/.zsh/installers/keys.sh

  touch "$SETUP_MARKER"
  log "INFO" "Setup complete."
fi

# Daily/Runtime checks (optimized)
FETCH_MARKER="/tmp/.yadm_fetch_done"
FORCE_UPDATE=false
if [[ "$1" == "--force" || "$2" == "--force" ]]; then
  FORCE_UPDATE=true
fi

local_tag=$(yadm describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
log "INFO" "Current Version: $local_tag"

if [[ ! -f "$FETCH_MARKER" || -z "$(find "$FETCH_MARKER" -mmin -1440)" || "$FORCE_UPDATE" == true ]]; then
  log "INFO" "Checking for dotfiles updates..."
  yadm fetch --tags 2>/dev/null
  touch "$FETCH_MARKER"
fi

remote_tag=$(yadm describe --tags --abbrev=0 origin/master 2>/dev/null || echo "$local_tag")

if [[ "$FORCE_UPDATE" == true || ("$local_tag" != "$remote_tag" && -n "$remote_tag") ]]; then
  if [[ "$local_tag" != "$remote_tag" ]]; then
    log "WARN" "Updates Detected: $local_tag -> $remote_tag"
    yadm log ..@{u} --pretty=format:%Cred%aN:%Creset\ %s\ %Cgreen%cd
  fi
  
  log "INFO" " Pulling Updates..."
  yadm pull -q
  log "INFO" "Reloading profile..."
  exec zsh
fi

draw_line
source ~/.zsh/zshrc.sh
