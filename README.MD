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

# 4. Node.js & NPM (Obligatorio para los servidores LSP de Vue/TS/JS)
sudo dnf install nodejs npm
