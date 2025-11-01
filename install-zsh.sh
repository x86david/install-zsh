#!/bin/bash

# Exit on error
set -e

echo "🔧 Installing Zsh and dependencies..."
sudo apt update
sudo apt install -y zsh curl git

echo "🔧 Setting Zsh as default shell for user: $USER"
sudo chsh -s "$(which zsh)" "$USER"

echo "🎨 Installing Oh My Zsh..."
export RUNZSH=no
export ZSH="$HOME/.oh-my-zsh"
if [ -d "$ZSH" ]; then
  echo "⚠️  Oh My Zsh already installed at $ZSH. Skipping installation."
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

echo "✨ Installing plugins..."

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# zsh-history-substring-search
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-history-substring-search" ]; then
  git clone https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM}/plugins/zsh-history-substring-search"
fi

echo "🧠 Updating ~/.zshrc with plugin configuration..."

# Replace plugins line or add it if missing
if grep -q "^plugins=" ~/.zshrc; then
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/' ~/.zshrc
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)' >> ~/.zshrc
fi

# Append configuration block
cat << 'EOF' >> ~/.zshrc

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

echo "✅ All done! Restart your terminal or run 'exec zsh' to start using your new Zsh setup."
