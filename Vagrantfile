# For setup instructions, see https://linuxacademy.com/guide/14756-install-the-mean-stack-on-vagrant/

Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu1804"
  config.vm.synced_folder "./Scripts", "/home/vagrant", type: "virtualbox"

  config.vm.hostname = "myvm"

  # Open ports for Node.js and MongoDB
  config.vm.network "forwarded_port", guest: 3000, host: 3000 # Node.js
  config.vm.network "forwarded_port", guest: 27017, host: 27017 # MongoDB

  # Open private network to allow access to local computer
  config.vm.network "private_network", ip: "192.168.10.2"

  ###  Oh My ZSH Install section ###
  # Install git and zsh prerequisites
  config.vm.provision :shell, inline: "apt-get -y install git"
  config.vm.provision :shell, inline: "apt-get -y install zsh"

  # Clone Oh My Zsh from the git repo
  config.vm.provision :shell, privileged: false,
    inline: "if [ ! -d '/home/vagrant/.oh-my-zsh' ]; then git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh; else echo '.oh-my-zsh already installed.'; fi"

  # Copy in my .zshrc file
  config.vm.provision "file", source: "~/.zshrc_to_copy", destination: ".zshrc"

  # Change the vagrant user's shell to use zsh
  config.vm.provision :shell, inline: "chsh -s /bin/zsh vagrant"
  ###

  # Copy in my .vimrc file
  config.vm.provision "file", source: "~/.vimrc", destination: ".vimrc"

  # Copy over GIT configuration
  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

  # Install MEAN stack using provision script. Now if we execute vagrant up for the first time (or we force it using –provision parameter) Vagrant will execute our script as part of the starting.
  config.vm.provision :shell, :path => "provision.sh"

end