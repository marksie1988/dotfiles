#!/bin/zsh

install_delta() {
  if command -v delta >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing git-delta..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install git-delta
    return
  fi

  # Linux: try apt first (Debian 12+ / Ubuntu 22.04+ have git-delta in apt).
  if apt-cache show git-delta >/dev/null 2>&1; then
    sudo apt install -y git-delta
    return
  fi

  # Fallback: fetch the latest .deb from GitHub releases for x86_64 / aarch64.
  local arch
  case "$ARCH_TYPE" in
    x86_64)  arch="amd64" ;;
    aarch64) arch="arm64" ;;
    *)       log "ERROR" "Unsupported arch for delta: $ARCH_TYPE"; return 1 ;;
  esac

  local deb_url
  deb_url=$(curl -sSL https://api.github.com/repos/dandavison/delta/releases/latest \
    | jq -r ".assets[] | select(.name | test(\"${arch}.*\\\\.deb$\")) | .browser_download_url" \
    | head -n1)
  if [[ -z "$deb_url" ]]; then
    log "ERROR" "Could not resolve delta .deb download URL"
    return 1
  fi

  local tmpdeb
  tmpdeb=$(mktemp --suffix=.deb)
  curl -sSL "$deb_url" -o "$tmpdeb"
  sudo dpkg -i "$tmpdeb"
  rm -f "$tmpdeb"
}
