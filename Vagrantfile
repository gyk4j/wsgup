# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/jammy64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
    config.vm.provision "shell", inline: <<-SHELL
      apt-get update
      
      # Required by Swift
      apt-get install -y \
        tree \
        binutils \
        git \
        gnupg2 \
        libc6-dev \
        libcurl4-openssl-dev \
        libedit2 \
        libgcc-11-dev \
        libpython3-dev \
        libsqlite3-0 \
        libstdc++-11-dev \
        libxml2-dev \
        libz3-dev \
        pkg-config \
        python3-lldb-13 \
        tzdata \
        unzip \
        zlib1g-dev
        
      cd /tmp
      
      # Download if required
      if [ ! -f "swift-5.10.1-RELEASE-ubuntu22.04.tar.gz" ]; then
        curl -sSL -O https://download.swift.org/swift-5.10.1-release/ubuntu2204/swift-5.10.1-RELEASE/swift-5.10.1-RELEASE-ubuntu22.04.tar.gz
      fi
      
      # Install if required
      if [ ! -d "/opt/swift" ]; then
        tar xzf swift-5.10.1-RELEASE-ubuntu22.04.tar.gz -C /opt
        mv /opt/swift-5.10.1-RELEASE-ubuntu22.04 /opt/swift
        echo export PATH=/opt/swift/usr/bin:"${PATH}" >> /etc/profile
      fi
      
      /opt/swift/usr/bin/swift --version
      
      apt-get install -y build-essential gcc g++ make cmake
      
      apt-get install -y perl python3 ruby-full python3-pip
      
      apt-get install -y openssl libssl-dev
      
      apt-get install -y php php-cli
      
      # Install .NET 6.0
      apt-get install -y dotnet-sdk-6.0
      dotnet --list-sdks
      dotnet --list-runtimes
      
      apt-get install -y openjdk-11-jre
      apt-get install -y nodejs npm
      
      # Install Dart SDK
      apt-get install apt-transport-https
      wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub \
        | gpg  --dearmor -o /usr/share/keyrings/dart.gpg
      echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' \
        | tee /etc/apt/sources.list.d/dart_stable.list
      apt-get update && apt-get install -y dart
      dart --disable-analytics
      dart --version
      
      # Install Go
      apt-get install -y golang-go
      go version
      
      # Install Rust
      apt-get install -y rustc cargo
      rustc -V
      cargo -V
    SHELL
end
