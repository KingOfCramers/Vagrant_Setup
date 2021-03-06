# For setup instructions, see https://linuxacademy.com/guide/14756-install-the-mean-stack-on-vagrant/

Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu1804"
  config.vm.synced_folder "./machine", "/home/vagrant", type: "virtualbox"

  config.vm.hostname = "myvm"

  # Copy the path to the private key to login. Use Vagrant's default as a backup. https://ermaker.github.io/blog/2015/11/18/change-insecure-key-to-my-own-key-on-vagrant.html
  config.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]

  # Copy public key to VM.
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"

  # Do not insert a randomly generated key.
  config.ssh.insert_key = false

  # Turn off password access (to prevent unauthorized access through vagrant user)
  config.vm.provision "shell", inline: <<-EOC
  sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
    sudo service ssh restart
  EOC

  # Open ports for Node.js and MongoDB
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1" # Node.js
  config.vm.network "forwarded_port", guest: 27017, host: 27017, host_ip: "127.0.0.1" # MongoDB

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

  # Copy in my .tmux.conf file
  config.vm.provision "file", source: "~/.tmux.conf", destination: ".tmux.conf"

  # Copy over GIT configuration
  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

  # Install MEAN stack using provision script. Now if we execute vagrant up for the first time (or we force it using –provision parameter) Vagrant will execute our script as part of the starting.
  config.vm.provision :shell, :path => "provision.sh"

end
