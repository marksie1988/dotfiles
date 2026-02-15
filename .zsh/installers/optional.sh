#!/bin/zsh

# Optional Packages Installer
echo "Checking for optional packages..."

# Function to prompt for installation
prompt_install() {
  local name=$1
  local cmd=$2
  local install_logic=$3

  if ! command -v "$cmd" > /dev/null; then
    echo -n "Do you want to install $name? (y/n) "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      eval "$install_logic"
    fi
  fi
}

# Detect GUI availability
HAS_GUI=false
if [[ "$OSTYPE" == "darwin"* ]]; then
  HAS_GUI=true
elif [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
  HAS_GUI=true
fi

# Ghostty (GUI gated)
if [[ "$HAS_GUI" == "true" ]]; then
  prompt_install "Ghostty" "ghostty" "brew install --cask ghostty"
fi

# VS Code (GUI gated)
if [[ "$HAS_GUI" == "true" ]]; then
  prompt_install "VS Code" "code" "brew install --cask visual-studio-code && code --install-extension ms-python.python && code --install-extension ms-toolsai.jupyter"
fi

# beads
prompt_install "beads" "beads" "npm install -g @beads/bd"

# Gemini CLI
prompt_install "Gemini CLI" "gemini" "npm install -g @google/gemini-cli"

# pnpm
prompt_install "pnpm" "pnpm" "curl -fsSL https://get.pnpm.io/install.sh | sh -"

# kubectl
if [[ "$OSTYPE" == "darwin"* ]]; then
  prompt_install "kubectl" "kubectl" "brew install kubernetes-cli"
else
  prompt_install "kubectl" "kubectl" "curl -LO \"https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\" && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl"
fi

# k9s
if [[ "$OSTYPE" == "darwin"* ]]; then
  prompt_install "k9s" "k9s" "brew install derailed/k9s/k9s"
else
  prompt_install "k9s" "k9s" "curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | tar xz && sudo mv k9s /usr/local/bin/ && rm -rf LICENSE README.md"
fi
