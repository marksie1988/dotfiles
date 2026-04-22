#!/bin/zsh

install_lazygit() {
  if command -v lazygit >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing lazygit..."
  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install lazygit
    return
  fi

  # Linux: no reliable apt package. Pull the latest tarball from GitHub releases.
  local arch
  case "$ARCH_TYPE" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="arm64" ;;
    armv7l)  arch="armv6" ;;
    *)       log "ERROR" "Unsupported arch for lazygit: $ARCH_TYPE"; return 1 ;;
  esac

  local version
  version=$(curl -sSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | jq -r '.tag_name' | sed 's/^v//')
  if [[ -z "$version" ]]; then
    log "ERROR" "Could not resolve lazygit version"
    return 1
  fi

  local url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_${arch}.tar.gz"
  local tmpdir
  tmpdir=$(mktemp -d)
  curl -sSL "$url" -o "$tmpdir/lazygit.tar.gz"
  tar -xf "$tmpdir/lazygit.tar.gz" -C "$tmpdir" lazygit
  mkdir -p "$HOME/.local/bin"
  mv "$tmpdir/lazygit" "$HOME/.local/bin/"
  rm -rf "$tmpdir"
}
