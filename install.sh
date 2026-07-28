#!/usr/bin/env bash

# Instala esta configuración de Neovim en Fedora o Ubuntu.
# Ejecútalo desde un clon del repositorio: ./install.sh

set -Eeuo pipefail

readonly NVIM_VERSION="0.11.6"
readonly NODE_VERSION="22.22.2"
readonly NVM_VERSION="0.40.4"
readonly LAZYGIT_VERSION="0.63.1"

DRY_RUN=false
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
USER_HOME="${HOME:?No se pudo determinar el directorio personal.}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$USER_HOME/.config}"
CONFIG_DIR="$CONFIG_HOME/nvim"
LOCAL_BIN="$USER_HOME/.local/bin"
LOCAL_OPT="$USER_HOME/.local/opt"
NVM_DIR="$USER_HOME/.nvm"
PALETTE_FILE="${NVIM_TERMINAL_THEME_FILE:-${XDG_STATE_HOME:-$USER_HOME/.local/state}/quickshell/user/generated/terminal/kitty-theme.conf}"
TEMP_DIR=""

info() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
success() { printf '\033[1;32m  ✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*" >&2; }
die() { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }

run() {
  if "$DRY_RUN"; then
    printf '  [dry-run] '
    printf '%q ' "$@"
    printf '\n'
    return
  fi
  "$@"
}

cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}

on_error() {
  local exit_code=$?
  printf '\n\033[1;31mLa instalación se detuvo (línea %s, código %s).\033[0m\n' "$1" "$exit_code" >&2
  printf 'Revisa el mensaje anterior; cualquier respaldo creado permanece intacto.\n' >&2
}

trap cleanup EXIT
trap 'on_error "$LINENO"' ERR

usage() {
  cat <<'EOF'
Uso: ./install.sh [--dry-run] [--help]

  --dry-run  Muestra las acciones sin instalar paquetes ni modificar archivos.
  --help     Muestra esta ayuda.
EOF
}

while (($#)); do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --help|-h) usage; exit 0 ;;
    *) die "Opción no reconocida: $1" ;;
  esac
  shift
done

[[ $EUID -ne 0 ]] || die "No ejecutes este script como root; usará sudo solo cuando sea necesario."
[[ -f "$SCRIPT_DIR/init.lua" ]] || die "Ejecuta install.sh desde un clon completo de este repositorio."

require_sudo() {
  command -v sudo >/dev/null 2>&1 || die "Se necesita sudo para instalar dependencias del sistema."
  if ! "$DRY_RUN"; then
    sudo -v
  fi
}

detect_platform() {
  [[ -r /etc/os-release ]] || die "No se puede identificar la distribución (falta /etc/os-release)."
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}" in
    fedora) PLATFORM="fedora" ;;
    ubuntu) PLATFORM="ubuntu" ;;
    *) die "Distribución no compatible: ${PRETTY_NAME:-${ID:-desconocida}}. Se admite Fedora y Ubuntu." ;;
  esac

  case "$(uname -m)" in
    x86_64) NVIM_ARCH="x86_64"; LAZYGIT_ARCH="x86_64" ;;
    aarch64|arm64) NVIM_ARCH="arm64"; LAZYGIT_ARCH="arm64" ;;
    *) die "Arquitectura no compatible: $(uname -m). Se admite x86_64 y aarch64." ;;
  esac
}

install_system_dependencies() {
  info "1/7 Instalando dependencias del sistema para $PLATFORM"
  require_sudo

  if [[ "$PLATFORM" == "fedora" ]]; then
    run sudo dnf install -y \
      gcc gcc-c++ make git curl wget unzip tar gzip ripgrep fd-find \
      wl-clipboard xclip
  else
    run sudo apt-get update
    run sudo apt-get install -y \
      build-essential git curl wget unzip tar gzip ripgrep fd-find \
      wl-clipboard xclip ca-certificates
  fi
  success "Dependencias del sistema listas"
}

install_node() {
  info "2/7 Instalando Node.js $NODE_VERSION mediante NVM"
  if "$DRY_RUN"; then
    printf '  [dry-run] Instalaría NVM %s y Node.js %s en %s\n' "$NVM_VERSION" "$NODE_VERSION" "$NVM_DIR"
    return
  fi

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    local installer="$TEMP_DIR/nvm-install.sh"
    curl --fail --location --silent --show-error \
      "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" \
      -o "$installer"
    bash "$installer" --no-use
  fi

  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  success "Node.js $(node --version) listo"
}

backup_binary_if_needed() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local backup="${target}.backup-$(date +%Y%m%d-%H%M%S)"
    run mv "$target" "$backup"
    warn "Se respaldó $target en $backup"
  fi
}

ensure_local_bin_in_path() {
  export PATH="$LOCAL_BIN:$PATH"
  local profile="$USER_HOME/.profile"
  local path_line='export PATH="$HOME/.local/bin:$PATH"'

  if "$DRY_RUN"; then
    printf '  [dry-run] Añadiría ~/.local/bin al PATH mediante %s si hiciera falta\n' "$profile"
    return
  fi

  if [[ ! -f "$profile" ]] || ! grep -Fqx "$path_line" "$profile"; then
    printf '\n# Neovim personal instalado por NeoVim-configuration\n%s\n' "$path_line" >> "$profile"
  fi
}

install_neovim() {
  info "3/7 Instalando Neovim oficial $NVIM_VERSION"
  local archive="$TEMP_DIR/nvim-linux-${NVIM_ARCH}.tar.gz"
  local extracted="$TEMP_DIR/nvim-linux-${NVIM_ARCH}"
  local destination="$LOCAL_OPT/nvim-$NVIM_VERSION"
  local binary_link="$LOCAL_BIN/nvim"

  if "$DRY_RUN"; then
    printf '  [dry-run] Descargaría Neovim %s (%s) en %s\n' "$NVIM_VERSION" "$NVIM_ARCH" "$destination"
    return
  fi

  run mkdir -p "$LOCAL_OPT" "$LOCAL_BIN"
  if [[ ! -x "$destination/bin/nvim" ]]; then
    curl --fail --location --silent --show-error \
      "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz" \
      -o "$archive"
    tar -xzf "$archive" -C "$TEMP_DIR"
    run mv "$extracted" "$destination"
  fi

  if [[ -L "$binary_link" ]] && [[ "$(readlink -f "$binary_link")" == "$destination/bin/nvim" ]]; then
    :
  else
    backup_binary_if_needed "$binary_link"
    run ln -s "$destination/bin/nvim" "$binary_link"
  fi
  ensure_local_bin_in_path
  success "$(nvim --version | head -1) disponible en $LOCAL_BIN"
}

ensure_fd_command() {
  [[ "$PLATFORM" == "ubuntu" ]] || return 0
  command -v fd >/dev/null 2>&1 && return 0
  command -v fdfind >/dev/null 2>&1 || return 0

  local fd_link="$LOCAL_BIN/fd"
  if "$DRY_RUN"; then
    printf '  [dry-run] Crearía %s como acceso a fdfind\n' "$fd_link"
    return
  fi

  if [[ -e "$fd_link" || -L "$fd_link" ]]; then
    backup_binary_if_needed "$fd_link"
  fi
  run ln -s "$(command -v fdfind)" "$fd_link"
  success "Se creó el alias fd para fdfind"
}

install_lazygit() {
  info "4/7 Instalando LazyGit $LAZYGIT_VERSION"
  local archive="$TEMP_DIR/lazygit.tar.gz"
  local unpacked="$TEMP_DIR/lazygit"
  local binary="$LOCAL_BIN/lazygit"

  if "$DRY_RUN"; then
    printf '  [dry-run] Descargaría LazyGit %s (%s)\n' "$LAZYGIT_VERSION" "$LAZYGIT_ARCH"
    return
  fi

  if [[ -x "$binary" ]] && "$binary" --version 2>/dev/null | grep -Fq "$LAZYGIT_VERSION"; then
    success "LazyGit $LAZYGIT_VERSION ya estaba instalado"
    return
  fi

  curl --fail --location --silent --show-error \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
    -o "$archive"
  tar -xzf "$archive" -C "$TEMP_DIR" lazygit
  backup_binary_if_needed "$binary"
  run install -m 0755 "$unpacked" "$binary"
  success "LazyGit $(lazygit --version | head -1) listo"
}

choose_theme() {
  info "5/7 Seleccionando el tema de Neovim"
  local selection=""

  if [[ ! -t 0 ]] || "$DRY_RUN"; then
    selection="tokyonight"
    warn "Sin terminal interactiva: se usará TokyoNight."
  else
    printf '  1) TokyoNight (oscuro y transparente)\n'
    printf '  2) Catppuccin Mocha (pastel y transparente)\n'
    printf '  3) Kanagawa Dragon (alto contraste)\n'
    printf '  4) Transferencia dinámica desde illogical-impulse/Quickshell\n'
    read -r -p '  Elige [1-4] (1): ' selection
    case "${selection:-1}" in
      1) selection="tokyonight" ;;
      2) selection="catppuccin" ;;
      3) selection="kanagawa" ;;
      4) selection="terminal" ;;
      *) warn "Opción inválida; se usará TokyoNight."; selection="tokyonight" ;;
    esac
  fi

  SELECTED_THEME="$selection"
  if [[ "$SELECTED_THEME" == "terminal" && ! -r "$PALETTE_FILE" ]]; then
    warn "No se encontró la paleta de Quickshell en $PALETTE_FILE"
    warn "La transferencia se activará cuando illogical-impulse genere kitty-theme.conf; mientras tanto se verá TokyoNight."
  fi
  success "Tema seleccionado: $SELECTED_THEME"
}

install_configuration() {
  info "6/7 Respaldando e instalando la configuración"
  local staged_config="$TEMP_DIR/nvim"
  local backup_root="$CONFIG_HOME/nvim-backups"
  local backup_path="$backup_root/nvim-$(date +%Y%m%d-%H%M%S)"

  if "$DRY_RUN"; then
    printf '  [dry-run] Respaldaría %s y copiaría el repositorio actual en su lugar\n' "$CONFIG_DIR"
    return
  fi

  # Se prepara una copia antes de mover ~/.config/nvim, incluso si el script
  # se está ejecutando desde esa misma ruta.
  cp -a "$SCRIPT_DIR" "$staged_config"
  run mkdir -p "$CONFIG_HOME" "$backup_root"
  if [[ -e "$CONFIG_DIR" || -L "$CONFIG_DIR" ]]; then
    run mv "$CONFIG_DIR" "$backup_path"
    success "Configuración anterior respaldada en $backup_path"
  fi
  run mv "$staged_config" "$CONFIG_DIR"

  cat > "$CONFIG_DIR/lua/config/theme.local.lua" <<EOF
-- Archivo local generado por install.sh. No se versiona.
return { name = "$SELECTED_THEME" }
EOF
  success "Configuración instalada en $CONFIG_DIR"
}

install_plugins() {
  info "7/7 Sincronizando plugins, parsers y herramientas LSP"
  if "$DRY_RUN"; then
    printf '  [dry-run] Ejecutaría Lazy sync, MasonToolsInstallSync y TSUpdateSync\n'
    return
  fi

  nvim --headless \
    "+Lazy! sync" \
    "+lua require('lazy').load({ plugins = { 'nvim-treesitter' } })" \
    "+TSUpdateSync" \
    "+MasonToolsInstallSync" \
    "+qa"
  success "Plugins y herramientas instalados"
}

main() {
  TEMP_DIR="$(mktemp -d)"
  detect_platform
  info "Instalador de NeoVim Personal Configuration"
  printf '  Sistema: %s | Arquitectura: %s\n' "$PLATFORM" "$NVIM_ARCH"
  if "$DRY_RUN"; then
    warn "Modo simulación activo: no se modificará el sistema."
  fi

  install_system_dependencies
  install_node
  install_neovim
  ensure_fd_command
  install_lazygit
  choose_theme
  install_configuration
  install_plugins

  printf '\n\033[1;32mInstalación terminada.\033[0m\n'
  printf 'Abre Neovim con: nvim\n'
  printf '\nGitHub Copilot requiere inicio de sesión manual.\n'
  printf 'En Neovim ejecuta: :Copilot auth\n'
}

main "$@"
