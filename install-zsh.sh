#!/bin/bash

# Exit on error
set -e

# Determine the target user and home directory
TARGET_USER="${SUDO_USER:-$(whoami)}"
TARGET_HOME=$(eval echo "~$TARGET_USER")

echo "🔧 Installing Zsh and dependencies..."
apt update
apt install -y zsh curl git

echo "🔧 Setting Zsh as default shell for user: $TARGET_USER"
chsh -s "$(which zsh)" "$TARGET_USER"

echo "🎨 Installing Oh My Zsh for $TARGET_USER..."
export RUNZSH=no
export CHSH=no
export ZSH="$TARGET_HOME/.oh-my-zsh"

if [ -d "$ZSH" ]; then
  echo "⚠️  Oh My Zsh already installed at $ZSH. Skipping installation."
else
  sudo -u "$TARGET_USER" sh -c 'RUNZSH=no CHSH=no bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

echo "✨ Installing plugins..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  sudo -u "$TARGET_USER" git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
  sudo -u "$TARGET_USER" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# zsh-history-substring-search
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-history-substring-search" ]; then
  sudo -u "$TARGET_USER" git clone https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM}/plugins/zsh-history-substring-search"
fi

echo "🧠 Updating .zshrc for $TARGET_USER..."

ZSHRC="$TARGET_HOME/.zshrc"

# Replace plugins line or add it if missing
if grep -q "^plugins=" "$ZSHRC"; then
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/' "$ZSHRC"
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)' >> "$ZSHRC"
fi

# Append configuration block
cat << 'EOF' >> "$ZSHRC"

# Fix for syntax highlighting commands like 'service'
export PATH=$PATH:/usr/sbin

# Bash-style prompt with green username@host
PROMPT='%F{green}%n@%m:%~%f$ '

# Enable completion system
autoload -Uz compinit
compinit

# Source plugins manually
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH_CUSTOM/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
EOF

echo "✅ All done! Run 'exec zsh' or restart your terminal to start using Zsh."
