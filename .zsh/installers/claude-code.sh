#!/bin/zsh

# Claude Code CLI. Anthropic's official self-updating installer drops a native
# binary into ~/.local/bin/claude (already on PATH via .zsh/exports.sh) and
# handles its own updates thereafter. Same command on macOS and every Linux
# distro (CachyOS/Arch, Debian/Ubuntu, Fedora), so no package-manager branch.
install_claude_code() {
  if command -v claude >/dev/null 2>&1; then
    return 0
  fi
  log "INFO" "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
}
