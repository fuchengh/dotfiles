#!/bin/bash
set -e # exit if any line fails
echo "[-] Start running my setup script"
# Global variables
HOME=$( getent passwd "$USER" | cut -d: -f6 )
FONT_BASE="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/"
ZSH_PLUGIN_BASE="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/"

# Install prerequisite and some frequently used tools
echo "[-] Installing packages..."
sudo apt-get -qq update
sudo apt-get -qq install -y git curl bat software-properties-common
sudo apt-get -qq install -y python3-dev python3-pip python3-setuptools
sudo apt-get -qq install -y zsh vim
sudo apt-get -qq autoremove -y

# Install fonts
echo "[FONTS] Downloading useful fonts..."
FONTS=(
    # Roboto
    "RobotoMono/Regular/RobotoMonoNerdFont-Regular.ttf"
    "RobotoMono/Regular/RobotoMonoNerdFontMono-Regular.ttf"
    "RobotoMono/Regular/RobotoMonoNerdFontPropo-Regular.ttf"
    # Hack
    "Hack/Regular/HackNerdFont-Regular.ttf"
    "Hack/Regular/HackNerdFontMono-Regular.ttf"
    "Hack/Regular/HackNerdFontPropo-Regular.ttf"
    "Hack/Bold/HackNerdFont-Bold.ttf"
    "Hack/Bold/HackNerdFontMono-Bold.ttf"
    "Hack/Bold/HackNerdFontPropo-Bold.ttf"
    # Cascadia
    "CascadiaCode/Regular/CaskaydiaCoveNerdFont-Regular.ttf"
    "CascadiaCode/Regular/CaskaydiaCoveNerdFontMono-Regular.ttf"
    "CascadiaCode/Regular/CaskaydiaCoveNerdFontPropo-Regular.ttf"
    "CascadiaCode/Bold/CaskaydiaCoveNerdFont-Bold.ttf"
    "CascadiaCode/Bold/CaskaydiaCoveNerdFontMono-Bold.ttf"
    "CascadiaCode/Bold/CaskaydiaCoveNerdFontPropo-Bold.ttf"
)
mkdir -p "${HOME}/.local/share/fonts"
for font in ${FONTS[@]}; do
    curl --output-dir "${HOME}/.local/share/fonts" -sfLO "${FONT_BASE}${font}"
    echo -ne "..."
done


# ===================== Plugins =====================
echo "[PLUGIN] Installing plugins for zsh and vim..."
# Install Vim Plugin
curl -sfLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Install Oh-my-zsh
if [ -z "$ZSH" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "[WARNING] Oh-my-zsh has already been installed!"
fi
# Install zsh plugins
ZSH_PLUGINS=(
    "zsh-history-substring-search"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
)
for plug in ${ZSH_PLUGINS[@]}; do
    if [ -d "${ZSH_PLUGIN_BASE}${plug}" ]; then
        echo "[ZSH] Plugin ${plug} has already been installed, ignoring..."
    else
        git clone "https://github.com/zsh-users/${plug}" "${ZSH_PLUGING_BASE}${plug}"
    fi
done


# ================ Move config files ================
# create backups
if [ -f ${HOME}/.zshrc ]; then
    cp "${HOME}/.zshrc" "${HOME}/.zshrc.orig"
fi
if [ -f ${HOME}/.vimrc ]; then
    cp "${HOME}/.vimrc" "${HOME}/.vimrc.orig"
fi
sudo chown "$USER" -R "${HOME}/.oh-my-zsh/"
cp .zshrc "${HOME}/.zshrc"
# using: p10k theme
cp .p10k.zsh "${HOME}/.p10k.zsh"
cp .vimrc "${HOME}/.vimrc"
cp .clang-format "${HOME}/.clang-format"
# apply zsh configs
chsh -s /usr/bin/zsh "$USER"

echo "[DONE] You will need to re-login to apply this config"
echo "[P10K] You can also run p10k configure to change the settings"