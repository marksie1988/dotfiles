#!/bin/zsh

# herdr — agent multiplexer (https://herdr.dev).
#   macOS: Homebrew formula (prebuilt bottle).
#   Linux: official installer drops a prebuilt binary into ~/.local/bin
#          (already on PATH via .zsh/exports.sh). Distro-agnostic, so this
#          covers CachyOS/Arch, Debian/Ubuntu and Fedora alike. Network
#          required; tracks "latest".
install_herdr() {
  if command -v herdr >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing herdr..."

  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install herdr
  else
    curl -fsSL https://herdr.dev/install.sh | sh
  fi
}
