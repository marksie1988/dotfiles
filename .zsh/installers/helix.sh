
# Install helix
install_helix() {
  if ! command -v hx > /dev/null; then
    echo "Installing helix..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install helix
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo add-apt-repository ppa:maveonair/helix-editor
      sudo apt update
      sudo apt install helix
    fi
  fi
}
