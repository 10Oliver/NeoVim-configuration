# 🚀 NeoVim Personal Configuration (PDC)

This is my personal configuration ("Personal Developer Center") for NeoVim, optimized for Web development (Vue, TS, JS).

## 📂 File Structure

This configuration uses a modular structure managed by `lazy.nvim` to keep settings organized and maintainable:

```text
~/.config/nvim/
├── init.lua
└── lua/
    ├── config/
    │   ├── keymaps.lua
    │   └── options.lua
    └── plugins/
        ├── ui.lua
        ├── git.lua
        ├── lsp.lua
        └── utils.lua
```

### 📥 Installation
Clone this repository directly into your Neovim configuration directory:
```bash
git clone https://github.com/10Oliver/NeoVim-configuration.git ~/.config/nvim
```
## 🛠️ Neovim Installation

To ensure full compatibility with the plugins, **Neovim 0.10 or higher** is required (ready for 0.11+).

### Fedora
On Fedora, you can install it directly from the official repositories since they are usually up to date:
```bash
sudo dnf install -y neovim
```

### Debian / Ubuntu
Since the official Debian/Ubuntu repositories usually have very old versions of Neovim, the recommended way is to download the latest official pre-compiled version:
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
# If you use zsh, change .bashrc to .zshrc
```

## 📋 Prerequisites

Dependencies required for the plugins to work properly (Telescope, Treesitter, etc.).

### Dependencies on Fedora:

```bash
# 1. System dependencies and utilities
sudo dnf install -y gcc g++ make unzip wget curl git ripgrep fd-find wl-clipboard

# 2. NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 3. LazyGit
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit -y
```

### Dependencies on Debian / Ubuntu:

```bash
# 1. System dependencies and utilities
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

### Additional Notes

If LazyGit fails when opening a file to edit, configure your default editor in `~/.bashrc` or `~/.zshrc`:
```bash
export EDITOR="nvim"
export VISUAL="nvim"
```
