#!/bin/zsh

install_atuin() {
  if command -v atuin >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing atuin..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install atuin
  else
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  fi
}
