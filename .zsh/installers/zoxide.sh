#!/bin/zsh

install_zoxide() {
  if command -v zoxide >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing zoxide..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install zoxide
  else
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
}
