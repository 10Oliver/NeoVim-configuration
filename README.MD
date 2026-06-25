# 🚀 NeoVim Personal Configuration (PDC)

Esta es mi configuración personalizada ("Personal Developer Center") para NeoVim, optimizada para desarrollo Web (Vue, TS, JS).

## 🛠️ Instalación de Neovim

Para asegurar la compatibilidad total con los plugins, se requiere **Neovim 0.10 o superior** (preparado para 0.11+).

### Fedora
En Fedora puedes instalarlo directamente desde los repositorios oficiales ya que suelen estar actualizados:
```bash
sudo dnf install -y neovim
```

### Debian / Ubuntu
Dado que los repositorios oficiales de Debian/Ubuntu suelen tener versiones muy antiguas de Neovim, la forma recomendada es descargar la versión precompilada más reciente oficial:
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
# Si usas zsh, cambia .bashrc por .zshrc
```

## 📋 Requisitos Previos

Dependencias necesarias para el funcionamiento correcto de los plugins (Telescope, Treesitter, etc.).

### Dependencias en Fedora:

```bash
# 1. Dependencias del sistema y utilidades
sudo dnf install -y gcc g++ make unzip wget curl git ripgrep fd-find wl-clipboard

# 2. NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 3. LazyGit
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit -y
```

### Dependencias en Debian / Ubuntu:

```bash
# 1. Dependencias del sistema y utilidades
sudo apt update
sudo apt install -y build-essential unzip wget curl git ripgrep fd-find xclip wl-clipboard

# 2. NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 3. LazyGit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit
```

### Notas Adicionales

Si LazyGit falla al abrir un archivo para editar, configura tu editor por defecto en `~/.bashrc` o `~/.zshrc`:
```bash
export EDITOR="nvim"
export VISUAL="nvim"
```
