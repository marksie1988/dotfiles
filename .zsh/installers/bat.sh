#!/bin/zsh

install_bat() {
  if command -v bat >/dev/null 2>&1; then
    return 0
  fi

  log "INFO" "Installing bat..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install bat
    return
  fi

  # Debian/Ubuntu apt ships the binary as `batcat`.
  sudo apt install -y bat
  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    log "INFO" "Symlinked batcat -> ~/.local/bin/bat"
  fi
}
