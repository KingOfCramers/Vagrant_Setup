#!/usr/bin/env bash

# Packages
NODE="nodejs"
MONGO="mongodb-org"
GIT="git"
YARN="yarn"
NPM="npm"
TMUX="tmux"

isInstalled(){
  let answer=$(sudo dpkg -l | awk '{print $2}' | grep -E ^"${1}"$ | wc -l)
  echo $answer
};

# Prerequisites
GIT_INSTALLED=$(isInstalled "${GIT}");
echo "Checking for $GIT"
if [ 0 == "${GIT_INSTALLED}" ]; then
 apt-get update
 apt-get install -y $GIT
fi

# Set up Git username in machine...
git config --global user.name "KingOfCramers"
GIT_USER=$(git config user.name)
if [ $GIT_USER != "KingOfCramers" ]; then
  echo "Git username could not be set."
  exit 1
fi

# MongoDB https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
MONGO_INSTALLED=$(isInstalled "${MONGO}")
echo "Checking for $MONGO"
if [ 0 == "${MONGO_INSTALLED}" ]; then
 wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
 echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
 sudo apt-get update
 sudo apt-get install -y mongodb-org
 sudo chmod +w /etc/mongod.conf
 # sudo sed -i 's/\ \ bindIp:\ 127.0.0.1/  bindIp: 0.0.0.0/g' /etc/mongod.conf
 # sudo service mongod restart ## Configure MongoDB administrative instance...
fi

# Node.js
NODE_INSTALLED=$(isInstalled "${NODE}")
echo "Checking for $NODE"
if [ 0 == "$NODE_INSTALLED" ]; then
 curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
 apt-get install -y build-essential nodejs
fi

# Yarn
YARN_INSTALLED=$(isInstalled "${YARN}")
echo "Checking for $YARN"
if [ 0 == "$YARN_INSTALLED" ]; then
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update
  sudo apt-get install yarn
  export PATH="$PATH:$(yarn global bin)" ## Add yarn to executable path...
fi
 
# Install oh-my-zsh synatax highlighting plugin...
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Install NPM
NPM_INSTALLED=$(isInstalled "${NPM}");
echo "Checking for $NPM"
if [ 0 == "${NPM_INSTALLED}" ]; then
  sudo apt-get install npm -y
fi

# Install TMUX
TMUX_INSTALLED=$(isInstalled "${TMUX}");
echo "Checking for $TMUX"
if [ 0 == "${TMUX_INSTALLED}" ]; then
  sudo apt-get install tmux
fi

# Install ESLint globally...
# Make sure to install vim plugins, through vim :PluginInstall
IS_ESLINT_INSTALLED=$(npm list -g | grep eslint | wc -l);
if [ 0 == "${IS_ESLINT_INSTALLED}" ]; then
  sudo npm install eslint -g 
fi

# Install Vim-Plug package manager for Vim for vagrant user...
curl -fLo /home/vagrant/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install iTerm2 Integration
curl -L https://iterm2.com/shell_integration/zsh \
-o /home/vagrant/.iterm2_shell_integration.zsh

echo "Provisioning complete."
