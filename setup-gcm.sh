#!/bin/bash
set -e

###############################################
# Detectar usuario real
###############################################
if [ "$SUDO_USER" ]; then
    TARGET_USER="$SUDO_USER"
else
    TARGET_USER="$USER"
fi

echo "[*] Configurando GCM para el usuario: $TARGET_USER"

###############################################
# 1. Instalar Git Credential Manager
###############################################
GCM_VERSION="2.7.3"
GCM_DEB="gcm-linux-x64-${GCM_VERSION}.deb"
GCM_URL="https://github.com/git-ecosystem/git-credential-manager/releases/download/v${GCM_VERSION}/${GCM_DEB}"

echo "[1] Descargando GCM ${GCM_VERSION}..."
wget -q "$GCM_URL" -O "$GCM_DEB"

echo "[2] Instalando GCM..."
dpkg -i "$GCM_DEB" || apt --fix-broken install -y

###############################################
# 2. Configurar GCM para el usuario dinámico
###############################################
echo "[3] Configurando Git Credential Manager para $TARGET_USER..."

# Limpiar configuraciones previas
sudo -u "$TARGET_USER" git config --global --unset-all credential.helper 2>/dev/null || true
sudo -u "$TARGET_USER" git config --global --unset-all credential.credentialStore 2>/dev/null || true
sudo -u "$TARGET_USER" git config --global --unset-all gcm.browser 2>/dev/null || true

# Configurar GCM como helper
sudo -u "$TARGET_USER" git config --global credential.helper manager

# Credential store estilo “como antes”
sudo -u "$TARGET_USER" git config --global credential.credentialStore plaintext

# Forzar modo headless (no navegador)
sudo -u "$TARGET_USER" git config --global gcm.browser none
sudo -u "$TARGET_USER" git config --global credential.guiPrompt false

# Ejecutar configuración interna de GCM
sudo -u "$TARGET_USER" git-credential-manager configure

echo "[✔] GCM configurado correctamente para $TARGET_USER."
echo "[✔] Ahora ejecuta 'git push' y usa el código device-flow en tu navegador."
