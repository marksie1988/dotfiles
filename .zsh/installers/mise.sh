#!/bin/zsh

install_mise() {
  if command -v mise >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing mise..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install mise
  else
    curl -sSfL https://mise.run | sh
  fi
}
