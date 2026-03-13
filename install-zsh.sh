#!/bin/bash

# Exit on error
set -e

# Determine the target user and home directory
TARGET_USER="${SUDO_USER:-$(whoami)}"
TARGET_HOME=$(eval echo "~$TARGET_USER")

echo "🔧 Installing Zsh and dependencies..."
apt update
apt install -y zsh curl git

echo ""
echo "🛠️  Zsh is installed. How would you like to set it as the default shell?"
echo "1) Only for the current user ($TARGET_USER)"
echo "2) For all existing users who currently use /bin/bash"
echo "3) For all future users (via /etc/default/useradd)"
echo "4) All of the above"
echo "5) Skip setting default shell"
read -rp "Enter your choice [1-5]: " ZSH_CHOICE

ZSH_PATH="$(which zsh)"

# Function: change shell only for users who currently use /bin/bash
change_shell_for_bash_users() {
    echo "🔧 Setting Zsh as default shell ONLY for users who currently use /bin/bash"
    echo "ℹ️  This avoids modifying system accounts or users with nologin/false shells."

    for u in $(awk -F: '$7 == "/bin/bash" {print $1}' /etc/passwd); do
        echo "🔄 Changing shell for user: $u"
        chsh -s "$ZSH_PATH" "$u" || echo "⚠️ Failed to change shell for $u"
    done
}

case "$ZSH_CHOICE" in
  1)
    echo "🔧 Setting Zsh as default shell for current user: $TARGET_USER"
    chsh -s "$ZSH_PATH" "$TARGET_USER"
    ;;
  2)
    change_shell_for_bash_users
    ;;
  3)
    echo "🔧 Setting Zsh as default shell for all future users"
    sed -i "s|^SHELL=.*|SHELL=$ZSH_PATH|" /etc/default/useradd
    ;;
  4)
    echo "🔧 Applying all options..."

    echo "🔄 Changing shell for current user: $TARGET_USER"
    chsh -s "$ZSH_PATH" "$TARGET_USER"

    change_shell_for_bash_users

    echo "🔧 Setting Zsh as default shell for all future users"
    sed -i "s|^SHELL=.*|SHELL=$ZSH_PATH|" /etc/default/useradd
    ;;
  5)
    echo "⏭️  Skipping shell change."
    ;;
  *)
    echo "❌ Invalid choice. Skipping shell change."
    ;;
esac

echo "🎨 Installing Oh My Zsh for $TARGET_USER..."
export RUNZSH=no
export CHSH=no
export ZSH="$TARGET_HOME/.oh-my-zsh"

# Ensure .zshrc exists BEFORE installing Oh My Zsh
if [ ! -f "$TARGET_HOME/.zshrc" ]; then
    echo "# .zshrc created by install-zsh.sh" > "$TARGET_HOME/.zshrc"
    chown "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.zshrc"
fi

# Install Oh My Zsh without overwriting .zshrc
if [ -d "$ZSH" ]; then
  echo "⚠️  Oh My Zsh already installed at $ZSH. Skipping installation."
else
  sudo -u "$TARGET_USER" KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
    sh -c 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
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
