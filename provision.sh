#!/usr/bin/env bash

# Packages
NODE="nodejs"
BUILD_ESSENTIAL="build-essential"
MONGO="mongodb-org"
GIT="git"
YARN="yarn"

# Prerequisites
GIT_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' $GIT | grep "install ok installed")
echo "Checking for $GIT: $GIT_INSTALLED"
if [ "" == "$GIT_INSTALLED" ]; then
 apt-get update
 apt-get install -y $GIT
fi

# MongoDB https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
MONGO_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' $MONGO | grep "install ok installed")
echo "Checking for $MONGO: $MONGO_INSTALLED"
if [ "" == "$MONGO_INSTALLED" ]; then
 wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
 echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
 sudo apt-get update
 sudo apt-get install -y mongodb-org
 sudo chmod +w /etc/mongod.conf
 # sudo sed -i 's/\ \ bindIp:\ 127.0.0.1/  bindIp: 0.0.0.0/g' /etc/mongod.conf
 # sudo service mongod restart ## Configure MongoDB administrative instance...
fi

# Node.js
NODE_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' $NODE | grep "install ok installed")
echo "Checking for $NODE: $NODE_INSTALLED"
if [ "" == "$NODE_INSTALLED" ]; then
 curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
 apt-get install -y build-essential nodejs
fi

# Yarn
YARN_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' $YARN | grep "install ok installed")
echo "Checking for Yarn: ${YARN_INSTALLED}"
if [ "" == "$YARN_INSTALLED" ]; then
  curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update
  sudo apt-get install yarn
  export PATH="$PATH:$(yarn global bin)" ## Add yarn to executable path...
fi
 
# Install oh-my-zsh synatax highlighting plugin...
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/vagrant/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Install NPM
sudo apt-get install npm -y

# Install Tmux
sudo apt-get install tmux

# Install ESLint globally...
## Make sure to install vim plugins, through vim :PluginInstall
sudo npm install eslint -g 

# Install Vim-Plug package manager for Vim for vagrant user...
curl -fLo /home/vagrant/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install iTerm2 Integration
curl -L https://iterm2.com/shell_integration/zsh \
-o /home/vagrant/.iterm2_shell_integration.zsh

echo "Provisioning complete."
