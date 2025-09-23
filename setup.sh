#!/usr/bin/env bash
# Cross-platform dotfiles bootstrap with interactive menu.
# Linux (Debian/Ubuntu) + macOS supported.

set -euo pipefail

# ---------- Globals ----------
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME_DIR}/.oh-my-zsh/custom}"
ZSH_PLUGIN_BASE="${ZSH_CUSTOM_DIR}/plugins"
ZSH_THEME_BASE="${ZSH_CUSTOM_DIR}/themes"
FONT_BASE="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts"

# Menu defaults (toggle here if you want non-interactive defaults)
DO_FONTS=0
DO_NVIM=1
DO_P10K=1
DO_ZSH_DEFAULT=1
DO_ZSH_PLUGINS=1

# Required zsh plugins list
ZSH_PLUGINS=(
  "zsh-users/zsh-history-substring-search"
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
  "Aloxaf/fzf-tab"
)

# Nerd fonts to fetch when on Linux (curl path style)
NERD_FONTS_LINUX=(
  "RobotoMono/Regular/RobotoMonoNerdFont-Regular.ttf"
  "RobotoMono/Regular/RobotoMonoNerdFontMono-Regular.ttf"
  "RobotoMono/Regular/RobotoMonoNerdFontPropo-Regular.ttf"
  "Hack/Regular/HackNerdFont-Regular.ttf"
  "Hack/Regular/HackNerdFontMono-Regular.ttf"
  "Hack/Regular/HackNerdFontPropo-Regular.ttf"
  "Hack/Bold/HackNerdFont-Bold.ttf"
  "Hack/Bold/HackNerdFontMono-Bold.ttf"
  "Hack/Bold/HackNerdFontPropo-Bold.ttf"
  "CascadiaCode/Regular/CaskaydiaCoveNerdFont-Regular.ttf"
  "CascadiaCode/Regular/CaskaydiaCoveNerdFontMono-Regular.ttf"
  "CascadiaCode/Regular/CaskaydiaCoveNerdFontPropo-Regular.ttf"
  "CascadiaCode/Bold/CaskaydiaCoveNerdFont-Bold.ttf"
  "CascadiaCode/Bold/CaskaydiaCoveNerdFontMono-Bold.ttf"
  "CascadiaCode/Bold/CaskaydiaCoveNerdFontPropo-Bold.ttf"
)

info()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
ok()    { printf "\033[1;32m[ OK ]\033[0m %s\n" "$*"; }

is_macos()  { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux()  { [[ "$(uname -s)" == "Linux"  ]]; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { warn "Missing command: $1"; return 1; }
}

ensure_dir() { mkdir -p "$1"; }

# ---------- Detect package managers ----------
have_brew=0
have_apt=0
if is_macos && command -v brew >/dev/null 2>&1; then have_brew=1; fi
if is_linux && command -v apt-get >/dev/null 2>&1; then have_apt=1; fi

# ---------- Menu ----------
confirm() {
  # $1: question, $2: default Y or N
  # returns 0 for yes, 1 for no
  local q="$1" d="${2:-N}" ans prompt
  case "$d" in
    Y|y) prompt="Y/n" ;;
    *)   prompt="y/N" ;;
  esac
  read -r -p "$q [$prompt]: " ans
  # empty -> default
  if [ -z "$ans" ]; then
    ans="$d"
  fi
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *)           return 1 ;;
  esac
}

ask_menu() {
  echo "=== Select tasks === (y/N default: N)"
  if confirm "Install Nerd Fonts?" N; then
    DO_FONTS=1
  else
    DO_FONTS=0
  fi

  if confirm "Install Neovim (plus Vim configs/plugins)?" N; then
    DO_NVIM=1
  else
    DO_NVIM=0
  fi

  if confirm "Deploy Powerlevel10k (theme + ~/.p10k.zsh)?" Y; then
    DO_P10K=1
  else
    DO_P10K=0
  fi

  if confirm "Set default shell to zsh?" Y; then
    DO_ZSH_DEFAULT=1
  else
    DO_ZSH_DEFAULT=0
  fi

  if confirm "Install/verify zsh plugins (git clone)?" Y; then
    DO_ZSH_PLUGINS=1
  else
    DO_ZSH_PLUGINS=0
  fi
}

# ---------- OS packages ----------
install_base_tools_linux() {
  info "Installing base packages via apt..."
  sudo apt-get -qq update
  sudo apt-get -qq install -y git curl fzf software-properties-common
  sudo apt-get -qq install -y python3-dev python3-pip python3-setuptools
  # 'bat' on Ubuntu is often 'batcat'; still install for new releases
  sudo apt-get -qq install -y zsh vim neovim bat || true
  sudo apt-get -qq autoremove -y
  # create bat shim if needed
  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ensure_dir "${HOME_DIR}/.local/bin"
    ln -sf "$(command -v batcat)" "${HOME_DIR}/.local/bin/bat"
    ok "Created ~/.local/bin/bat -> batcat"
    case ":$PATH:" in
      *":${HOME_DIR}/.local/bin:"*) :;;
      *) warn "Add ~/.local/bin to PATH in your shell rc."; ;;
    esac
  fi
}

install_base_tools_macos() {
  if [[ $have_brew -eq 0 ]]; then
    warn "Homebrew not found; skipping package installs. Install from https://brew.sh"
    return
  fi
  info "Installing base packages via Homebrew..."
  brew update >/dev/null
  brew install git curl fzf python zsh neovim bat >/dev/null || true
  # install fzf key-bindings and completion
  if [[ -x "$(brew --prefix)/opt/fzf/install" ]]; then
    yes | "$(brew --prefix)/opt/fzf/install" --no-bash --no-fish --key-bindings --completion >/dev/null || true
  fi
}

install_base_tools() {
  if is_linux;  then install_base_tools_linux;  fi
  if is_macos;  then install_base_tools_macos;  fi
}

# ---------- Fonts ----------
install_fonts_linux() {
  info "Installing Nerd Fonts (Linux, user-scoped)..."
  local font_dir="${HOME_DIR}/.local/share/fonts"
  ensure_dir "${font_dir}"
  for rel in "${NERD_FONTS_LINUX[@]}"; do
    local url="${FONT_BASE}/${rel}"
    (cd "${font_dir}" && curl -fsSOL "${url}" && printf ".") || warn "Failed: ${rel}"
  done
  echo
  fc-cache -f >/dev/null || true
  ok "Fonts installed under ${font_dir}"
}

install_fonts_macos() {
  if [[ $have_brew -eq 0 ]]; then
    warn "Homebrew not found; skipping font install on macOS."
    return
  fi
  info "Installing Nerd Fonts via Homebrew Cask (no tap)..."
  local casks=(
    font-roboto-mono-nerd-font
    font-hack-nerd-font
    font-caskaydia-cove-nerd-font
  )
  for c in "${casks[@]}"; do
    if brew list --cask "$c" >/dev/null 2>&1; then
      ok "$c already installed."
      continue
    fi
    if brew install --cask "$c"; then
      ok "Installed $c via brew."
    else
      warn "Brew failed for $c; falling back to direct download."
      manual_install_font_macos "$c"
    fi
  done
  ok "Fonts ready on macOS."
}

# Fallback: map cask name -> upstream Nerd Fonts zip, install to ~/Library/Fonts
manual_install_font_macos() {
  local cask="$1" zip=""
  case "$cask" in
    font-roboto-mono-nerd-font)   zip="RobotoMono.zip" ;;
    font-hack-nerd-font)          zip="Hack.zip" ;;
    font-caskaydia-cove-nerd-font) zip="CaskaydiaCove.zip" ;; # Nerd Fonts uses this zip name for Caskaydia
    *) warn "No fallback mapping for $cask"; return 0 ;;
  esac
  local dst="$HOME/Library/Fonts"
  ensure_dir "$dst"
  local tmp="/tmp/$zip"
  # Use the official 'latest' release URL structure
  if curl -fsSL -o "$tmp" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$zip"; then
    /usr/bin/unzip -qo "$tmp" "*.ttf" -d "$dst" || warn "unzip failed for $zip"
    rm -f "$tmp"
    ok "Installed $cask from upstream release into $dst"
  else
    warn "Download failed for $zip; please install manually from https://www.nerdfonts.com/font-downloads"
  fi
}

install_fonts() {
  [[ $DO_FONTS -eq 1 ]] || return 0
  if is_linux; then install_fonts_linux; fi
  if is_macos; then install_fonts_macos; fi
}

# ---------- Oh My Zsh ----------
ensure_oh_my_zsh() {
  if [[ -d "${HOME_DIR}/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed."
    return
  fi
  info "Installing Oh My Zsh (unattended)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
}

# ---------- Zsh plugins ----------
ensure_zsh_plugin_repo() {
  local repo="$1"                # e.g. zsh-users/zsh-autosuggestions
  local name="${repo##*/}"       # e.g. zsh-autosuggestions
  local dest="${ZSH_PLUGIN_BASE}/${name}"
  if [[ -d "${dest}" ]]; then
    ok "zsh plugin ${name} present."
  else
    info "Cloning ${repo} -> ${dest}"
    ensure_dir "${ZSH_PLUGIN_BASE}"
    git clone --depth=1 "https://github.com/${repo}.git" "${dest}"
  fi
}

install_zsh_plugins() {
  [[ $DO_ZSH_PLUGINS -eq 1 ]] || return 0
  ensure_oh_my_zsh
  for r in "${ZSH_PLUGINS[@]}"; do
    ensure_zsh_plugin_repo "$r"
  done
}

# ---------- Powerlevel10k ----------
install_p10k() {
  [[ $DO_P10K -eq 1 ]] || return 0
  ensure_oh_my_zsh
  local dest="${ZSH_THEME_BASE}/powerlevel10k"
  if [[ -d "${dest}" ]]; then
    ok "Powerlevel10k already present."
  else
    info "Cloning Powerlevel10k..."
    ensure_dir "${ZSH_THEME_BASE}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${dest}"
  fi
  if [[ -f "${REPO_DIR}/.p10k.zsh" ]]; then
    cp -f "${REPO_DIR}/.p10k.zsh" "${HOME_DIR}/.p10k.zsh"
    ok "Deployed ~/.p10k.zsh"
  else
    warn "No .p10k.zsh in repo; you can run 'p10k configure' later."
  fi
}

# ---------- Shell default ----------
set_default_shell_zsh() {
  [[ $DO_ZSH_DEFAULT -eq 1 ]] || return 0

  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    warn "zsh not installed; skip chsh"
    return
  fi

  if is_macos; then
    if ! grep -qx "$zsh_path" /etc/shells; then
      info "Adding $zsh_path to /etc/shells (sudo)..."
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
  fi

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    ok "Default shell already $zsh_path"
    return
  fi

  info "Changing default shell to $zsh_path (you may be prompted for your password)..."
  if chsh -s "$zsh_path" "$USER"; then
    ok "Default shell changed to $zsh_path"
  else
    warn "chsh failed; retrying with sudo..."
    if sudo chsh -s "$zsh_path" "$USER"; then
      ok "Default shell changed to $zsh_path (sudo)"
    else
      error "Could not change default shell. Check MDM/enterprise restrictions."
    fi
  fi
}

# ---------- Editors: Vim/Neovim + plugins ----------
deploy_editor_configs() {
  # Copy dotfiles from repo if present
  [[ -f "${REPO_DIR}/.vimrc"     ]] && cp -f "${REPO_DIR}/.vimrc"     "${HOME_DIR}/.vimrc"
  [[ -f "${REPO_DIR}/.clang-format" ]] && cp -f "${REPO_DIR}/.clang-format" "${HOME_DIR}/.clang-format"
  [[ -f "${REPO_DIR}/.zshrc"     ]] && cp -f "${REPO_DIR}/.zshrc"     "${HOME_DIR}/.zshrc"
  # nvim config directory
  if [[ -d "${REPO_DIR}/.config/nvim" ]]; then
    ensure_dir "${HOME_DIR}/.config"
    # copy (not symlink) to avoid permission surprises on some hosts
    rsync -a --delete "${REPO_DIR}/.config/nvim/" "${HOME_DIR}/.config/nvim/"
  fi
}

install_vim_plug() {
  # vim
  curl -fsSLo "${HOME_DIR}/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  # nvim
  curl -fsSLo "${HOME_DIR}/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_editor_plugins() {
  # Vim plugins
  if command -v vim >/dev/null 2>&1; then
    info "Installing Vim plugins via vim-plug..."
    vim +PlugInstall +qall || true
  fi
  # Neovim plugins
  if command -v nvim >/dev/null 2>&1; then
    info "Installing Neovim plugins via vim-plug..."
    nvim --headless "+PlugInstall --sync" +qa || true
  fi
}

install_neovim_linux() {
  # Already installed in base, but keep guard
  sudo apt-get -qq update
  sudo apt-get -qq install -y neovim
}

install_neovim_macos() {
  [[ $have_brew -eq 1 ]] || { warn "brew missing; skip Neovim"; return; }
  brew install neovim >/dev/null || true
}

setup_editors() {
  [[ $DO_NVIM -eq 1 ]] || return 0
  if is_linux; then install_neovim_linux; fi
  if is_macos; then install_neovim_macos; fi
  deploy_editor_configs
  install_vim_plug
  install_editor_plugins
}

# ---------- Zsh rc + ownership ----------
deploy_shell_configs() {
  # Preserve old files
  for f in .zshrc .vimrc; do
    if [[ -f "${HOME_DIR}/${f}" && ! -f "${HOME_DIR}/${f}.orig" ]]; then
      cp "${HOME_DIR}/${f}" "${HOME_DIR}/${f}.orig" || true
      ok "Backup ${f} -> ${f}.orig"
    fi
  done
  # Copy from repo (if present)
  [[ -f "${REPO_DIR}/.zshrc" ]] && cp -f "${REPO_DIR}/.zshrc" "${HOME_DIR}/.zshrc"
  [[ -f "${REPO_DIR}/.p10k.zsh" ]] && cp -f "${REPO_DIR}/.p10k.zsh" "${HOME_DIR}/.p10k.zsh"
  [[ -d "${HOME_DIR}/.oh-my-zsh" ]] && chown -R "$USER":"$(id -gn)" "${HOME_DIR}/.oh-my-zsh" || true
}

# ---------- Main ----------
main() {
  info "Start setup"
  ask_menu
  install_base_tools
  install_fonts
  install_zsh_plugins
  install_p10k
  setup_editors
  deploy_shell_configs
  set_default_shell_zsh
  ok "All done. Re-login or 'exec zsh' to apply."
  echo "Tip: run 'p10k configure' anytime to tweak the prompt."
}

main "$@"
