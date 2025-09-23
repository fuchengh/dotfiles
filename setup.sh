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

# Menu defaults (you can change these)
DO_FONTS=0
DO_NVIM=1
DO_P10K=1
DO_ZSH_DEFAULT=1
DO_ZSH_PLUGINS=1

# Zsh plugins to ensure
ZSH_PLUGINS=(
  "zsh-users/zsh-history-substring-search"
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
  "Aloxaf/fzf-tab"
)

# Nerd fonts for Linux (direct paths inside Nerd Fonts repo)
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
  "CascadiaCode/CaskaydiaCoveNerdFont-Regular.ttf"
  "CascadiaCode/CaskaydiaCoveNerdFontMono-Regular.ttf"
  "CascadiaCode/CaskaydiaCoveNerdFontPropo-Regular.ttf"
  "CascadiaCode/CaskaydiaCoveNerdFont-Bold.ttf"
  "CascadiaCode/CaskaydiaCoveNerdFontMono-Bold.ttf"
  "CascadiaCode/CaskaydiaCoveNerdFontPropo-Bold.ttf"
)

info()  { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
ok()    { printf "\033[1;32m[ OK ]\033[0m %s\n" "$*"; }

is_macos()  { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux()  { [[ "$(uname -s)" == "Linux"  ]]; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || { warn "Missing command: $1"; return 1; }; }
ensure_dir() { mkdir -p "$1"; }
ensure_local_bin_in_path() {
  local line='export PATH="$HOME/.local/bin:$PATH"'
  for rc in "${HOME_DIR}/.zshrc" "${HOME_DIR}/.bashrc"; do
    [[ -f "$rc" ]] || continue
    # Use [:space:] (grep -E doesn't understand \s)
    if ! grep -qE '(^|[[:space:]])export PATH="\$HOME/\.local/bin:\$PATH"' "$rc"; then
      backup_once "$rc"
      echo "$line" >> "$rc"
      ok "Added ~/.local/bin to PATH in $(basename "$rc")"
    else
      ok "~/.local/bin already in $(basename "$rc")"
    fi
  done
  # Ensure current session has it too
  case ":$PATH:" in *":${HOME_DIR}/.local/bin:"*) :;; *) export PATH="${HOME_DIR}/.local/bin:$PATH";; esac
}

# --- helpers (put near the top, after ensure_dir) ---
backup_once() {
  # Backup a file only if it exists and no .orig yet
  local dst="$1"
  if [[ -f "$dst" && ! -f "${dst}.orig" ]]; then
    cp -f "$dst" "${dst}.orig"
    ok "Backup $(basename "$dst") -> $(basename "$dst").orig"
  fi
}

install_file() {
  # Copy file only if changed; create one-time backup first
  local src="$1" dst="$2"
  [[ -f "$src" ]] || { warn "Missing source: $src"; return 0; }
  backup_once "$dst"
  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    ok "Unchanged $(basename "$dst")"
  else
    ensure_dir "$(dirname "$dst")"
    cp -f "$src" "$dst"
    ok "Deployed $(basename "$dst")"
  fi
}

install_tree() {
  # rsync a directory tree; keep a one-time backup of existing dst
  local src="$1" dst="$2"
  [[ -d "$src" ]] || { warn "Missing dir: $src"; return 0; }
  if [[ -d "$dst" && ! -d "${dst}.orig" ]]; then
    mv "$dst" "${dst}.orig"
    ok "Backup $(basename "$dst")/ -> $(basename "$dst").orig/"
  fi
  ensure_dir "$dst"
  rsync -a --delete "${src}/" "${dst}/"
  ok "Synced $(basename "$dst")/"
}

# ---------- Package manager detection ----------
have_brew=0; have_apt=0
if is_macos && command -v brew >/dev/null 2>&1; then have_brew=1; fi
if is_linux && command -v apt-get >/dev/null 2>&1; then have_apt=1; fi

# ---------- Menu (Bash 3/4 safe) ----------
confirm() {
  local q="$1" d="${2:-N}" ans prompt
  case "$d" in Y|y) prompt="Y/n";; *) prompt="y/N";; esac
  read -r -p "$q [$prompt]: " ans
  [[ -z "$ans" ]] && ans="$d"
  case "$ans" in y|Y|yes|YES) return 0;; *) return 1;; esac
}
ask_menu() {
  echo "Select tasks (y/N default: N)"
  confirm "Install Nerd Fonts?" N && DO_FONTS=1 || DO_FONTS=0
  confirm "Install Neovim (plus Vim configs/plugins)?" Y && DO_NVIM=1 || DO_NVIM=0
  confirm "Deploy Powerlevel10k (theme + ~/.p10k.zsh)?" Y && DO_P10K=1 || DO_P10K=0
  confirm "Set default shell to zsh?" Y && DO_ZSH_DEFAULT=1 || DO_ZSH_DEFAULT=0
  confirm "Install/verify zsh plugins (git clone)?" Y && DO_ZSH_PLUGINS=1 || DO_ZSH_PLUGINS=0
}

# ---------- NVIM helpers ----------
nvim_bin_path() {
  if [[ -x "${HOME_DIR}/.local/bin/nvim" ]]; then
    echo "${HOME_DIR}/.local/bin/nvim"
  elif command -v nvim >/dev/null 2>&1; then
    command -v nvim
  else
    echo ""
  fi
}
nvim_version_minor() {
  local bin="${1:-$(nvim_bin_path)}"
  if [[ -n "$bin" && -x "$bin" ]]; then
    "$bin" --version | awk 'NR==1{match($0,/NVIM v([0-9]+)\.([0-9]+)/,a); if(a[2]!=""){print a[2]} else {print 0}}'
  else
    echo 0
  fi
}

# ---------- Base tools ----------
install_base_tools_linux() {
  info "Installing base packages via apt..."
  sudo apt-get -qq update
  sudo apt-get -qq install -y \
    git curl wget fzf software-properties-common ca-certificates \
    python3-dev python3-pip python3-setuptools \
    zsh vim bat ripgrep rsync unzip gawk fontconfig \
    build-essential fd-find zoxide || true
  sudo apt-get -qq autoremove -y

  # bat shim (Ubuntu packages often use 'batcat')
  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ensure_dir "${HOME_DIR}/.local/bin"
    ln -sf "$(command -v batcat)" "${HOME_DIR}/.local/bin/bat"
    ok "Created ~/.local/bin/bat -> batcat"
    case ":$PATH:" in *":${HOME_DIR}/.local/bin:"*) :;; *) warn "Add ~/.local/bin to PATH in your shell rc.";; esac
  fi
  # fd shim (Ubuntu uses 'fdfind')
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ensure_dir "${HOME_DIR}/.local/bin"
    ln -sf "$(command -v fdfind)" "${HOME_DIR}/.local/bin/fd"
    ok "Created ~/.local/bin/fd -> fdfind"
  fi
}
install_base_tools_macos() {
  if [[ $have_brew -eq 0 ]]; then
    warn "Homebrew not found; skipping package installs. Install from https://brew.sh"
    return
  fi
  info "Installing base packages via Homebrew..."
  brew update >/dev/null
  brew install git curl fzf python zsh neovim bat ripgrep fd zoxide gawk rsync >/dev/null || true

  # fzf key-bindings/completion
  if [[ -x "$(brew --prefix)/opt/fzf/install" ]]; then
    yes | "$(brew --prefix)/opt/fzf/install" --no-bash --no-fish --key-bindings --completion >/dev/null || true
  fi

  # clangd via LLVM, and add to PATH if needed
  brew install llvm >/dev/null || true
  local llvm_bin; llvm_bin="$(brew --prefix llvm)/bin"
  if [[ -x "$llvm_bin/clangd" ]]; then
    if ! grep -qs "$llvm_bin" "${HOME_DIR}/.zshrc"; then
      backup_once "${HOME_DIR}/.zshrc"
      echo 'export PATH="'"$llvm_bin"':$PATH"' >> "${HOME_DIR}/.zshrc"
      ok "Added LLVM bin to PATH in ~/.zshrc (for clangd)"
    fi
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
  info "Installing Nerd Fonts via Homebrew Cask..."
  local casks=(
    font-roboto-mono-nerd-font
    font-hack-nerd-font
    font-caskaydia-cove-nerd-font
  )
  for c in "${casks[@]}"; do
    if brew list --cask "$c" >/dev/null 2>&1; then
      ok "$c already installed."
    else
      brew install --cask "$c" || warn "Failed to install $c (you can install manually later)."
    fi
  done
  ok "Fonts ready on macOS."
}
manual_install_font_macos() { :; }  # reserved; no-op
install_fonts() {
  [[ $DO_FONTS -eq 1 ]] || return 0
  if is_linux; then install_fonts_linux; fi
  if is_macos; then install_fonts_macos; fi
}

# ---------- Oh My Zsh ----------
ensure_oh_my_zsh() {
  if [[ -d "${HOME_DIR}/.oh-my-zsh" ]]; then ok "Oh My Zsh already installed."; return; fi
  info "Installing Oh My Zsh (unattended)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
}

# ---------- Zsh plugins ----------
ensure_zsh_plugin_repo() {
  local repo="$1"; local name="${repo##*/}"; local dest="${ZSH_PLUGIN_BASE}/${name}"
  if [[ -d "${dest}" ]]; then ok "zsh plugin ${name} present."; else
    info "Cloning ${repo} -> ${dest}"
    ensure_dir "${ZSH_PLUGIN_BASE}"
    git clone --depth=1 "https://github.com/${repo}.git" "${dest}"
  fi
}
install_zsh_plugins() {
  [[ $DO_ZSH_PLUGINS -eq 1 ]] || return 0
  ensure_oh_my_zsh
  for r in "${ZSH_PLUGINS[@]}"; do ensure_zsh_plugin_repo "$r"; done
}

# ---------- Powerlevel10k ----------
install_p10k() {
  [[ $DO_P10K -eq 1 ]] || return 0
  ensure_oh_my_zsh
  local dest="${ZSH_THEME_BASE}/powerlevel10k"
  if [[ -d "${dest}" ]]; then ok "Powerlevel10k already present."; else
    info "Cloning Powerlevel10k..."; ensure_dir "${ZSH_THEME_BASE}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${dest}"
  fi
  if [[ -f "${REPO_DIR}/.p10k.zsh" ]]; then
    cp -f "${REPO_DIR}/.p10k.zsh" "${HOME_DIR}/.p10k.zsh"; ok "Deployed ~/.p10k.zsh"
  else
    warn "No .p10k.zsh in repo; run 'p10k configure' later."
  fi
}

# ---------- Default shell ----------
set_default_shell_zsh() {
  [[ $DO_ZSH_DEFAULT -eq 1 ]] || return 0
  need_cmd zsh || { warn "zsh not installed; skip chsh"; return; }
  local zsh_path; zsh_path="$(command -v zsh)"
  if is_macos; then
    grep -qx "$zsh_path" /etc/shells || { info "Adding $zsh_path to /etc/shells (sudo)..."; echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; }
  fi
  if [[ "${SHELL:-}" == "$zsh_path" ]]; then ok "Default shell already $zsh_path"; return; fi
  info "Changing default shell to $zsh_path (you may be prompted for your password)..."
  chsh -s "$zsh_path" "$USER" || { warn "chsh failed; retrying with sudo..."; sudo chsh -s "$zsh_path" "$USER" || error "Could not change default shell. Check restrictions."; }
}

# ---------- Editor configs ----------
deploy_editor_configs() {
  install_file "${REPO_DIR}/.vimrc"        "${HOME_DIR}/.vimrc"
  install_file "${REPO_DIR}/.clang-format" "${HOME_DIR}/.clang-format"

  if [[ -d "${REPO_DIR}/.config/nvim" ]]; then
    install_tree "${REPO_DIR}/.config/nvim" "${HOME_DIR}/.config/nvim"
  fi
}
install_vim_plug() {
  curl -fsSLo "${HOME_DIR}/.vim/autoload/plug.vim"                        --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  curl -fsSLo "${HOME_DIR}/.local/share/nvim/site/autoload/plug.vim"     --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

# ---------- Neovim (installers) ----------
install_neovim_tarball() {
  ensure_dir "${HOME_DIR}/.local/bin"
  ensure_dir "${HOME_DIR}/.local/opt"
  local arch_tag=""
  case "$(uname -m)" in
    x86_64|amd64) arch_tag="x86_64" ;;
    aarch64|arm64) arch_tag="arm64" ;;
    *) warn "Unknown arch, defaulting to x86_64"; arch_tag="x86_64" ;;
  esac
  local base="https://github.com/neovim/neovim/releases/latest/download"
  local tar="nvim-linux-${arch_tag}.tar.gz"
  info "Installing Neovim from tarball (${tar}) ..."
  curl -fsSL -o "/tmp/${tar}" "${base}/${tar}"
  (cd "${HOME_DIR}/.local/opt" && rm -rf "nvim-linux-${arch_tag}" && tar -xzf "/tmp/${tar}")
  ln -sf "${HOME_DIR}/.local/opt/nvim-linux-${arch_tag}/bin/nvim" "${HOME_DIR}/.local/bin/nvim"
  rm -f "/tmp/${tar}"
  ok "Neovim tarball installed -> ~/.local/bin/nvim"
  case ":$PATH:" in *":${HOME_DIR}/.local/bin:"*) :;; *) warn "Add ~/.local/bin to PATH in your shell rc.";; esac
}
install_neovim_appimage() {
  ensure_dir "${HOME_DIR}/.local/bin"
  ensure_dir "${HOME_DIR}/.local/opt"
  local arch_tag=""
  case "$(uname -m)" in
    x86_64|amd64) arch_tag="x86_64" ;;
    aarch64|arm64) arch_tag="arm64" ;;
    *) warn "Unknown arch, defaulting to x86_64"; arch_tag="x86_64" ;;
  esac
  local base="https://github.com/neovim/neovim/releases/latest/download"
  local app="nvim-linux-${arch_tag}.appimage"
  local app_tmp="/tmp/${app}"
  info "Installing Neovim via AppImage (${app}) ..."
  curl -fsSL -o "${app_tmp}" "${base}/${app}"
  chmod +x "${app_tmp}"
  local appdir="${HOME_DIR}/.local/opt/nvim-appimage-${arch_tag}"
  rm -rf "${appdir}"; mkdir -p "${appdir}"
  (cd "${appdir}" && "${app_tmp}" --appimage-extract >/dev/null)
  rm -f "${app_tmp}"
  ln -sf "${appdir}/squashfs-root/AppRun" "${HOME_DIR}/.local/bin/nvim"
  ok "Neovim AppImage installed -> ~/.local/bin/nvim (AppRun)"
  case ":$PATH:" in *":${HOME_DIR}/.local/bin:"*) :;; *) warn "Add ~/.local/bin to PATH in your shell rc.";; esac
}
install_neovim_ppa_with_timeout() {
  if ! grep -qi 'ubuntu' /etc/os-release || ! command -v add-apt-repository >/dev/null 2>&1; then
    warn "PPA method unavailable on this system."; return 1
  fi
  info "Trying Ubuntu PPA (neovim-ppa/stable) with timeout..."
  sudo apt-get -qq update
  sudo apt-get -qq install -y software-properties-common ca-certificates || true
  local add_ok=0
  if command -v timeout >/dev/null 2>&1; then
    sudo timeout 25s add-apt-repository -y ppa:neovim-ppa/stable && add_ok=1 || true
  else
    sudo add-apt-repository -y ppa:neovim-ppa/stable && add_ok=1 || true
  fi
  [[ $add_ok -eq 1 ]] || { warn "PPA add failed or timed out."; return 1; }
  sudo apt-get -qq update
  sudo apt-get -qq install -y neovim || true
}

# ---------- Neovim (latest orchestrator) ----------
install_neovim_linux_latest() {
  info "Ensuring Neovim >= 0.11 on Linux..."
  # NVIM_LINUX_INSTALL=tarball|appimage|ppa|auto (default auto)
  local mode="${NVIM_LINUX_INSTALL:-auto}"
  case "$mode" in
    tarball)  install_neovim_tarball   || { error "Tarball install failed."; return 1; } ;;
    appimage) install_neovim_appimage  || { error "AppImage install failed."; return 1; } ;;
    ppa)      install_neovim_ppa_with_timeout || { error "PPA path failed."; return 1; } ;;
    auto|*)   install_neovim_tarball || { warn "Tarball failed; trying AppImage..."; install_neovim_appimage || { warn "AppImage failed; trying PPA..."; install_neovim_ppa_with_timeout || error "All Neovim install methods failed."; }; } ;;
  esac

  # Verify we are using the right binary and version
  ensure_local_bin_in_path
  local NVBIN; NVBIN="$(nvim_bin_path)"
  if [[ -z "$NVBIN" ]]; then error "nvim not found in PATH after install"; return 1; fi
  local minor; minor="$(nvim_version_minor "$NVBIN")"
  if [[ "$minor" -lt 11 ]]; then warn "Neovim still < 0.11 (minor=$minor)."; fi

  # Locate runtime by filesystem (handles tarball & AppImage)
  local runtime=""
  # tarball layout: ~/.local/opt/nvim-linux-*/share/nvim/runtime
  for d in "${HOME_DIR}/.local/opt"/nvim-linux-*; do
    [[ -d "$d/share/nvim/runtime" ]] && runtime="$d/share/nvim/runtime"
  done
  # AppImage layout: ~/.local/opt/nvim-appimage-*/squashfs-root/usr/share/nvim/runtime
  if [[ -z "$runtime" ]]; then
    for d in "${HOME_DIR}/.local/opt"/nvim-appimage-*; do
      [[ -d "$d/squashfs-root/usr/share/nvim/runtime" ]] && runtime="$d/squashfs-root/usr/share/nvim/runtime"
    done
  fi

  if [[ -z "$runtime" || ! -f "$runtime/syntax/syntax.vim" ]]; then
    error "Neovim runtime not found under ~/.local/opt (broken install)."
    return 1
  fi
  ok "Neovim OK. Runtime at: $runtime"
}
install_neovim_macos() {
  [[ $have_brew -eq 1 ]] || { warn "brew missing; skip Neovim"; return; }
  brew install neovim >/dev/null || true
  ok "Neovim $(nvim --version | head -1)"
}

# ---------- Editors pipeline ----------
install_editor_plugins() {
  if command -v vim >/dev/null 2>&1; then
    info "Installing Vim plugins via vim-plug..."
    vim +PlugInstall +qall || true
  fi
  local NVBIN; NVBIN="$(nvim_bin_path)"
  if [[ -n "$NVBIN" ]]; then
    info "Installing Neovim plugins via vim-plug..."
    "$NVBIN" --headless "+PlugInstall --sync" "+TSUpdate" +qa || true
  else
    warn "Neovim binary not found; skipping Neovim plugin install."
  fi
  info "Editor plugins installation done."
}
setup_editors() {
  [[ $DO_NVIM -eq 1 ]] || return 0
  if is_linux; then install_neovim_linux_latest; fi
  if is_macos; then install_neovim_macos; fi
  deploy_editor_configs
  install_vim_plug
  install_editor_plugins
}

# ---------- Zsh rc + ownership ----------
deploy_shell_configs() {
  # Shell-related only; backup-before-first-overwrite semantics
  install_file "${REPO_DIR}/.zshrc"    "${HOME_DIR}/.zshrc"
  install_file "${REPO_DIR}/.p10k.zsh" "${HOME_DIR}/.p10k.zsh"
  [[ -d "${HOME_DIR}/.oh-my-zsh" ]] && chown -R "$USER":"$(id -gn)" "${HOME_DIR}/.oh-my-zsh" || true
}

# ---------- Main ----------
main() {
  info "Start setup"
  ask_menu
  install_base_tools
  ensure_local_bin_in_path
  install_fonts
  install_zsh_plugins
  install_p10k
  setup_editors
  deploy_shell_configs
  ensure_local_bin_in_path
  set_default_shell_zsh
  ok "All done. Re-login or 'exec zsh' to apply."
  echo "Tip: run 'p10k configure' anytime to tweak the prompt."
}

main "$@"
