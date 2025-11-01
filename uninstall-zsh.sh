#!/bin/bash

# Exit on error
set -e

echo "🧹 Reverting Zsh setup..."

# Restore default shell to Bash
echo "🔧 Changing default shell back to Bash for user: $USER"
sudo chsh -s /bin/bash "$USER"

# Remove Oh My Zsh
echo "🗑 Removing Oh My Zsh..."
rm -rf ~/.oh-my-zsh

# Remove .zshrc
echo "🗑 Removing ~/.zshrc..."
rm -f ~/.zshrc

# Optional: remove Zsh if you want a clean Bash-only system
read -p "Do you want to uninstall Zsh completely? [y/N]: " remove_zsh
if [[ "$remove_zsh" =~ ^[Yy]$ ]]; then
  echo "❌ Uninstalling Zsh..."
  sudo apt remove --purge -y zsh
else
  echo "✅ Keeping Zsh installed."
fi

echo "🎉 Uninstall complete. Restart your terminal or log out and back in to return to Bash."
