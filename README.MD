# 🚀 NeoVim Personal Configuration (PDC)

Esta es mi configuración personalizada ("Personal Developer Center") para NeoVim, optimizada para desarrollo Web (Vue, TS, JS).

## 📋 Requisitos Previos

Dependencias necesarias para el funcionamiento correcto de los plugins (Telescope, Treesitter, etc.).

### Instalación en Fedora:

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

### Notas Adicionales

Si LazyGit falla al abrir un archivo, configura tu editor por defecto en `~/.bashrc` o `~/.zshrc`:
```bash
export EDITOR="nvim"
export VISUAL="nvim"
```
