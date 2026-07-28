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

The supported installer prepares the dependencies, Neovim, plugins and a selected theme on Fedora or Ubuntu:

```bash
git clone https://github.com/10Oliver/NeoVim-configuration.git
cd NeoVim-configuration
./install.sh
```

It saves an existing `~/.config/nvim` configuration in `~/.config/nvim-backups/` before replacing it. Use `./install.sh --dry-run` to review its actions without changing the system.

During installation choose one of these themes:

- TokyoNight (default)
- Catppuccin Mocha
- Kanagawa Dragon
- Dynamic palette transfer from illogical-impulse / Quickshell

The transfer option reads `~/.local/state/quickshell/user/generated/terminal/kitty-theme.conf`. Install and run end-4's illogical-impulse first; Neovim will use TokyoNight until Quickshell generates that file.

After the installer finishes, authenticate GitHub Copilot manually in Neovim:

```vim
:Copilot auth
```

### 🔄 Updating
If you already have this config installed and want to pull the latest updates (e.g., the TreeSitter version fix):
```bash
cd ~/.config/nvim
git pull
```
After pulling, open Neovim and run `:Lazy sync` to update the plugins.

## 🛠️ Manual installation

`install.sh` is the supported path. The manual instructions below remain useful if you prefer to manage dependencies yourself.

To ensure full compatibility with the plugins, **Neovim 0.11 or higher** is required. The installer pins the tested official version, **0.11.6**.
*Note: `nvim-treesitter` is pinned to `v0.9.3` to maintain compatibility with Neovim 0.11 and older. If you update Neovim to 0.12+ (Nightly), you can remove the `tag = "v0.9.3"` from `lua/plugins/lsp.lua` to use the latest treesitter branch.*

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

### Bash
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

### Fish
```fish
# 1. System dependencies and utilities
sudo dnf install -y gcc g++ make unzip wget curl git ripgrep fd-find wl-clipboard
# 2. NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
if set -q XDG_CONFIG_HOME
    set -gx NVM_DIR "$XDG_CONFIG_HOME/nvm"
else
    set -gx NVM_DIR "$HOME/.nvm"
end
test -s "$NVM_DIR/nvm.sh"; and source "$NVM_DIR/nvm.sh"
# 3. LazyGit
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit -y
```

### Dependencies on Debian / Ubuntu:

### Bash
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

### Fish
```fish
# 1. System dependencies and utilities
sudo apt update
sudo apt install -y build-essential unzip wget curl git ripgrep fd-find xclip wl-clipboard
# 2. NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
if set -q XDG_CONFIG_HOME
    set -gx NVM_DIR "$XDG_CONFIG_HOME/nvm"
else
    set -gx NVM_DIR "$HOME/.nvm"
end
test -s "$NVM_DIR/nvm.sh"; and source "$NVM_DIR/nvm.sh"
# 3. LazyGit
set LAZYGIT_VERSION (curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_$LAZYGIT_VERSION"_Linux_x86_64.tar.gz
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz lazygit
```

### Additional Notes

If LazyGit fails when opening a file to edit, configure your default editor in `~/.bashrc` or `~/.zshrc`:

### Bash
```bash
export EDITOR="nvim"
export VISUAL="nvim"
```

### Fish
```fish
set -gx EDITOR nvim
set -gx VISUAL nvim
```
