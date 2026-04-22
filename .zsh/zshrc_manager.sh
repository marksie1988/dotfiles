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

# Starship installer
starship_install() {
  log "INFO" "Installing/Updating Starship..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install starship
  else
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$HOME/.local/bin"
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

# Install / ensure all declared tools. Safe to re-run — every installer
# short-circuits when its binary is already on PATH. Called on initial
# setup AND after every successful dotfiles pull, so new tools added in
# an upstream bump are picked up automatically.
run_tool_installers() {
  log "INFO" "Ensuring tools are installed..."

  for pkg in "${MANDATORY_PACKAGES[@]}"; do
    install_if_missing "$pkg"
  done

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
    (
      source ~/.zsh/installers/atuin.sh
      install_atuin
    ) &
    (
      source ~/.zsh/installers/zoxide.sh
      install_zoxide
    ) &
    (
      source ~/.zsh/installers/delta.sh
      install_delta
    ) &
    (
      source ~/.zsh/installers/lazygit.sh
      install_lazygit
    ) &
    (
      source ~/.zsh/installers/bat.sh
      install_bat
    ) &

    wait # Wait for background installers
  )
}

# Setup logic (gated by marker file or --setup flag)
SETUP_MARKER="$HOME/.zsh/.setup_done"
if [[ ! -f "$SETUP_MARKER" || "$1" == "--setup" ]]; then
  log "INFO" "Running initial setup..."

  run_tool_installers

  # Interactive / host-wide pieces — only on first setup, not on every pull.
  source ~/.zsh/installers/optional.sh
  if [[ "$OS_TYPE" == "darwin" ]]; then
    source ~/.zsh/installers/macos_defaults.sh
  fi
  source ~/.zsh/installers/keys.sh

  touch "$SETUP_MARKER"
  log "INFO" "Setup complete."
  INITIAL_SETUP_JUST_RAN=1
fi

# Completions are (re)generated below alongside the daily yadm fetch, so they
# refresh as tools are upgraded without paying the cost on every shell launch.
regenerate_completions() {
  mkdir -p ~/.zsh/completions
  command -v gh >/dev/null      && gh completion -s zsh      > ~/.zsh/completions/_gh      2>/dev/null
  command -v kubectl >/dev/null && kubectl completion zsh    > ~/.zsh/completions/_kubectl 2>/dev/null
  command -v docker >/dev/null  && docker completion zsh     > ~/.zsh/completions/_docker  2>/dev/null
}

# Daily/Runtime checks (optimized)
FETCH_MARKER="/tmp/.yadm_fetch_done"
FORCE_UPDATE=false
if [[ "$1" == "--force" || "$2" == "--force" ]]; then
  FORCE_UPDATE=true
fi

local_tag=$(yadm describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
log "INFO" "Current Version: $local_tag"

if [[ ! -f "$FETCH_MARKER" || -z "$(find "$FETCH_MARKER" -mmin -1440)" || "$FORCE_UPDATE" == true || "$INITIAL_SETUP_JUST_RAN" == "1" ]]; then
  log "INFO" "Checking for dotfiles updates..."
  yadm fetch --tags 2>/dev/null
  regenerate_completions
  touch "$FETCH_MARKER"
fi

remote_tag=$(yadm describe --tags --abbrev=0 origin/master 2>/dev/null || echo "$local_tag")

if [[ "$FORCE_UPDATE" == true || ("$local_tag" != "$remote_tag" && -n "$remote_tag") ]]; then
  if [[ "$local_tag" != "$remote_tag" ]]; then
    log "WARN" "Updates Detected: $local_tag -> $remote_tag"
    yadm log ..@{u} --pretty=format:%Cred%aN:%Creset\ %s\ %Cgreen%cd
  fi
  
  log "INFO" " Pulling Updates..."
  if yadm pull -q; then
    # Pick up any tools added in the pulled version before reloading.
    run_tool_installers
    log "INFO" "Reloading profile..."
    exec zsh
  else
    log "ERROR" "yadm pull failed — staying in the current shell."
    log "ERROR" "Resolve the conflict (yadm status / yadm stash), then: yadm pull && exec zsh"
  fi
fi

draw_line
source ~/.zsh/zshrc.sh
