#!/bin/bash
# install.sh - Installs rune globally

echo "Installing rune globally..."

# Define install directory
INSTALL_DIR="/usr/local/bin"
if [ ! -w "$INSTALL_DIR" ]; then
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"
  echo "Warning: No sudo rights. Installing to $INSTALL_DIR instead."
  echo "Make sure $INSTALL_DIR is in your PATH."
fi

# Download the setup script directly to the bin folder
curl -fsSL https://raw.githubusercontent.com/bhargava562/rune/main/scripts/setup.sh -o "$INSTALL_DIR/rune"

# Make it executable
chmod +x "$INSTALL_DIR/rune"

echo "✅ rune is installed! You can now run 'rune' from any project directory."
