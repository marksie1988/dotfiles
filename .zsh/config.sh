#!/bin/zsh

# Centralized configuration for dotfiles installers

# Mandatory Packages
MANDATORY_PACKAGES=(yadm zsh curl unzip wget jq git fzf ripgrep direnv)

# Starship Configuration
STARSHIP_VERSION="latest"

# Eza Configuration
EZA_VERSION="latest"

# Helix Configuration
HELIX_VERSION="latest"

# Logging Configuration
LOG_FILE="$HOME/.zsh/logs/setup.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Profiling Configuration
# Set ZSH_PROFILE=1 to enable profiling
