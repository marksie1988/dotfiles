#!/bin/zsh

# Neovim + the build tools the kickstart config (config/nvim/init.lua) needs:
# a C compiler and make for treesitter parsers / telescope-fzf-native, and fd
# for telescope's file source.
install_neovim() {
  if command -v nvim >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing neovim..."

  if [[ "$OS_TYPE" == "darwin" ]]; then
    brew install neovim fd
    return
  fi

  # Linux: use whichever package manager the distro ships.
  if command -v pacman >/dev/null 2>&1; then
    # Arch family (CachyOS, Manjaro). base-devel provides gcc + make.
    sudo pacman -S --needed --noconfirm neovim fd gcc make
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y neovim fd-find build-essential
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y neovim fd-find gcc make
  else
    log "ERROR" "No supported package manager (pacman/apt/dnf) for neovim"
    return 1
  fi
}
