#!/bin/zsh

# Centralized configuration for dotfiles installers

# Mandatory Packages
MANDATORY_PACKAGES=(yadm zsh curl unzip wget jq git)

# Starship Configuration
STARSHIP_VERSION="latest"
# Checksums would ideally be fetched or updated here
# STARSHIP_SHA256_X86_64="..."
# STARSHIP_SHA256_AARCH64="..."

# Eza Configuration
EZA_VERSION="latest"

# Helix Configuration
HELIX_VERSION="latest"

# Optional Packages
OPTIONAL_PACKAGES=(
  "ghostty"
  "visual-studio-code"
  "beads"
  "gemini-cli"
  "pnpm"
  "kubectl"
  "k9s"
)

# Logging Configuration
LOG_FILE="$HOME/.zsh/logs/setup.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Profiling Configuration
# Set ZSH_PROFILE=1 to enable profiling
