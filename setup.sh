# Install prerequisite
sudo apt update
sudo apt install git -y
sudo apt install curl -y

# Install thefuck for correcting errors in previous commands
sudo apt install python3-dev python3-pip python3-setuptools -y
sudo pip3 install thefuck -y

# Install zsh
sudo apt install zsh -y

# Install Vim
sudo apt install vim -y

# Install Vim Plugin
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install Oh-my-zsh
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh ./install.sh --unattend

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# Move setting files
sudo chown "$USER" -R ~/.oh-my-zsh/

cp .zshrc ~
cp .vimrc ~
cp bullet-train.zsh-theme ~/.oh-my-zsh/themes/

chsh -s /usr/bin/zsh "$USER"
# You will need to re-login to apply this config
rm install.sh
sudo apt install fonts-hack-ttf
