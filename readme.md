## 🚀 Smart Zsh Installer

This repository contains a Bash script that automates the installation and configuration of **Zsh**, **Oh My Zsh**, and essential productivity plugins — giving your terminal superpowers from the start.

### 📦 What It Does

- Installs Zsh, Git, and Curl
- Sets Zsh as your default shell
- Installs [Oh My Zsh](https://ohmyz.sh)
- Adds powerful plugins:
  - [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions)
  - [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting)
  - [`zsh-history-substring-search`](https://github.com/zsh-users/zsh-history-substring-search)
- Updates your `.zshrc` with plugin configuration
- Fixes `$PATH` to ensure commands like `service` are recognized by syntax highlighting

### 📋 Requirements

- Debian-based Linux system (e.g. Ubuntu, Debian)
- Bash shell
- Sudo privileges

### 🛠 Installation

1. Clone this repo:
   ```bash
   git clone https://github.com/your-username/smart-zsh-installer.git
   cd smart-zsh-installer
   ```

2. Make the script executable:
   ```bash
   chmod +x install-smart-zsh.sh
   ```

3. Run the installer:
   ```bash
   ./install-smart-zsh.sh
   ```

4. Restart your terminal or run:
   ```bash
   exec zsh
   ```

### 🧪 Plugin Features

- **Autosuggestions**: Suggests commands as you type based on history.
- **Syntax Highlighting**: Highlights valid and invalid commands.
- **History Substring Search**: Search your command history by typing and pressing ↑ or ↓.

### 💡 Optional Enhancements

Want a beautiful prompt? Try [Powerlevel10k](https://github.com/romkatv/powerlevel10k) for a fast, feature-rich Zsh theme.

---
