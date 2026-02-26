# 🚀 Mi Configuración Personal de NeoVim (PDC)

Esta es mi configuración personalizada ("Personal Developer Center") para NeoVim, optimizada para desarrollo Web (Vue, TS, JS) en Fedora Linux.

## 📋 Requisitos Previos (Dependencias Externas)

Antes de clonar esta configuración, es necesario instalar estas herramientas en el sistema para que los plugins funcionen correctamente (Telescope, Clipboard, Treesitter, etc.).

### En Fedora (40/41/42):

```bash
# 1. Herramientas básicas de compilación (Para Treesitter y Mason)
sudo dnf install gcc g++ make unzip wget curl git

# 2. Buscador rápido (Para Telescope 'live_grep')
sudo dnf install ripgrep fd-find

# 3. Portapapeles (Para copiar/pegar entre Nvim y el sistema)
# Si usas Wayland (Gnome/KDE moderno):
sudo dnf install wl-clipboard
# Si usas X11 (Legacy):
# sudo dnf install xclip

# 4. NVM para Node y NPM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# 5. Lazy git
# Habiliar repositorio para instalarlo
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
