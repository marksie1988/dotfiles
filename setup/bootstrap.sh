#!/usr/bin/env bash
#
# bootstrap.sh — first-run setup for a fresh machine.
#
# Installs Nix (Determinate Systems installer, flakes enabled by default) and
# activates this flake. Idempotent: safe to re-run. After the first activation,
# day-to-day updates are just `darwin-rebuild switch --flake .#<host>` (macOS) or
# `home-manager switch --flake .#<user>@linux` (Linux/WSL2) — see README.
#
# Keeps stdout/stderr separate; no `2>&1`.

set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="Stevens-MacBook-Pro"  # matches darwinConfigurations.<host> in flake.nix
LINUX_TARGET="linux"        # matches homeConfigurations.<name> in flake.nix

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
err() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; }

os="$(uname -s)"

# 1. Install Nix if missing.
if ! command -v nix >/dev/null 2>&1; then
  log "Installing Nix (Determinate Systems installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install --no-confirm
  # Load Nix into the current shell so the rest of the script can use it.
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
else
  log "Nix already installed: $(nix --version)"
fi

# 1b. Ensure flakes are usable and (on Linux multi-user installs) the daemon is
#     running. The Determinate installer sets both up; a distro-packaged Nix
#     (e.g. the Arch/CachyOS `nix` package) does not, so wire them up here.
if ! nix flake --help >/dev/null 2>&1 || ! grep -qrs 'experimental-features.*flakes' /etc/nix ~/.config/nix; then
  log "Enabling flakes for this user (~/.config/nix/nix.conf)..."
  mkdir -p ~/.config/nix
  if ! grep -qs 'experimental-features' ~/.config/nix/nix.conf 2>/dev/null; then
    printf 'experimental-features = nix-command flakes\n' >>~/.config/nix/nix.conf
  fi
fi

if [ "$os" = "Linux" ] && [ ! -d /nix/store ]; then
  if command -v systemctl >/dev/null 2>&1; then
    log "Initialising the Nix daemon (needs sudo)..."
    sudo systemctl enable --now nix-daemon.socket
  else
    err "/nix/store missing and no systemctl found — start the nix daemon manually, then re-run."
    exit 1
  fi
fi

# 2. On macOS, ensure Homebrew exists (nix-darwin manages casks declaratively
#    but does not install Homebrew itself).
if [ "$os" = "Darwin" ] && ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Load brew into PATH for this session (Apple Silicon location).
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# 3. Activate the flake for this platform.
case "$os" in
  Darwin)
    if command -v darwin-rebuild >/dev/null 2>&1; then
      log "Rebuilding nix-darwin (.#$HOST)..."
      darwin-rebuild switch --impure --flake "${FLAKE_DIR}#${HOST}"
    else
      log "First nix-darwin activation (.#$HOST)..."
      nix run nix-darwin -- switch --impure --flake "${FLAKE_DIR}#${HOST}"
    fi
    ;;
  Linux)
    log "Activating home-manager (.#$LINUX_TARGET)..."
    # -b bak backs up any pre-existing files instead of failing the first switch.
    nix run home-manager/master -- switch -b bak --impure --flake "${FLAKE_DIR}#${LINUX_TARGET}"
    ;;
  *)
    err "Unsupported OS: $os"
    exit 1
    ;;
esac

# 4. Make zsh the login shell. home-manager manages the zsh *config*, but as a
#    standalone install it can't touch /etc/passwd — that's a chsh (prompts for
#    your password). Prefer the Nix-provided zsh; fall back to a system one.
desired_shell="${HOME}/.nix-profile/bin/zsh"
[ -x "$desired_shell" ] || desired_shell="$(command -v zsh 2>/dev/null || true)"
if [ -n "$desired_shell" ] && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  log "Setting login shell to zsh (${desired_shell})..."
  if ! grep -qxF "$desired_shell" /etc/shells 2>/dev/null; then
    echo "$desired_shell" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$desired_shell" || err "chsh failed — run 'chsh -s ${desired_shell}' yourself."
  log "Login shell set. Open a new terminal (or log out/in) to use it."
fi

log "Done."
log "SSH/GPG keys are not managed by Nix — generate them once if needed:"
log "  ssh-keygen -t ed25519 -C \"\$(git config user.email)\""
log "  gpg --full-generate-key"
