#!/bin/zsh

# Ghostty terminal (GUI). Config lives at .config/ghostty/config.
#   macOS: Homebrew cask.
#   Arch family (CachyOS, Manjaro): official package in the `extra` repo.
#   Other Linux: Ghostty isn't in Debian/Ubuntu apt; point at the docs rather
#     than pulling an unofficial repo. Fedora ships an official COPR.
install_ghostty() {
  if command -v ghostty >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing ghostty..."

  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install --cask ghostty
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm ghostty
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf copr enable -y pgdev/ghostty
    sudo dnf install -y ghostty
  else
    log "WARN" "Ghostty has no apt package — install it from https://ghostty.org/docs/install"
    return 1
  fi
}
