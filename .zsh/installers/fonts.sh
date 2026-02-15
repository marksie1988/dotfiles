#!/bin/zsh

# Font Automation - Hack Nerd Font Mono

FONT_NAME="Hack"
FONT_ZIP="Hack.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_ZIP}"

install_font() {
  echo "Checking for ${FONT_NAME} Nerd Font..."

  if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
  else
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
  fi

  if find "$FONT_DIR" -name "*${FONT_NAME}*Nerd Font*" | grep -q "."; then
    echo "${FONT_NAME} Nerd Font already installed."
    return 0
  fi

  echo "Downloading ${FONT_NAME} Nerd Font..."
  cd /tmp
  curl -fLo "$FONT_ZIP" "$FONT_URL"
  unzip -o "$FONT_ZIP" -d font_tmp
  
  echo "Installing fonts to ${FONT_DIR}..."
  cp font_tmp/*Mono* "$FONT_DIR/"
  
  if [[ "$OSTYPE" != "darwin"* ]]; then
    fc-cache -f "$FONT_DIR"
  fi

  rm -rf font_tmp "$FONT_ZIP"
  echo "Font installation complete."
}

install_font
