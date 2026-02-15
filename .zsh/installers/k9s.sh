# Install and configure k9s
install_k9s() {
  if ! command -v k9s > /dev/null; then
    log "INFO" "Installing k9s..."
    if [[ "$OS_TYPE" == "darwin" ]]; then
      brew install k9s
    fi
  fi

  if [[ "$OS_TYPE" == "darwin" ]]; then
    local k9s_repo_dir="$HOME/.config/k9s"
    local k9s_target_dir="$HOME/Library/Application Support/k9s"

    if [[ -d "$k9s_repo_dir" ]]; then
      if [[ ! -L "$k9s_target_dir" ]]; then
        if [[ -d "$k9s_target_dir" ]]; then
          log "INFO" "Backing up existing k9s configuration..."
          local backup_dir="$HOME/.dotfiles_backup/k9s_$(date +%Y%m%d_%H%M%S)"
          mkdir -p "$backup_dir"
          mv "$k9s_target_dir" "$backup_dir/"
        fi
        log "INFO" "Creating symlink for k9s configuration..."
        ln -s "$k9s_repo_dir" "$k9s_target_dir"
      fi
    fi
  fi
}
