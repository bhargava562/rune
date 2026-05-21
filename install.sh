#!/bin/bash
# install.sh - Installs rune globally

echo "Installing rune globally..."

# OCP Platform Detection
OS_FAMILY="linux"
case "$(uname -s)" in
  MINGW*|CYGWIN*|MSYS*)
    OS_FAMILY="windows"
    ;;
  Darwin*)
    OS_FAMILY="macos"
    ;;
  *)
    OS_FAMILY="linux"
    ;;
esac

# Define install directory
INSTALL_DIR="/usr/local/bin"
if [ "$OS_FAMILY" = "windows" ] || [ ! -w "$INSTALL_DIR" ]; then
  # Prefer local bin for Windows to avoid permission issues, or if standard bin is not writable
  INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$INSTALL_DIR"
  if [ "$OS_FAMILY" != "windows" ]; then
    echo "Warning: No sudo rights. Installing to $INSTALL_DIR instead."
  fi
  echo "Make sure $INSTALL_DIR is in your PATH."
  echo "  Add to PATH by running:"
  if [ "$OS_FAMILY" = "windows" ]; then
    echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
  else
    echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
    echo "    (or ~/.zshrc if you use zsh)"
  fi
fi

# Download the setup script directly to the bin folder
curl -fsSL https://raw.githubusercontent.com/bhargava562/rune/main/scripts/setup.sh -o "$INSTALL_DIR/rune"

# Make it executable
chmod +x "$INSTALL_DIR/rune"

# Generate Windows Wrapper if applicable
if [ "$OS_FAMILY" = "windows" ]; then
  {
    echo "@echo off"
    printf '%s\n' 'bash "%~dp0\rune" %*'
  } > "$INSTALL_DIR/rune.cmd"
  echo "  ✓ Generated rune.cmd wrapper for Windows CMD/PowerShell"
fi

echo "✅ rune is installed! You can now run 'rune setup' from any project directory."
