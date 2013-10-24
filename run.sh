#!/bin/sh

echo "Have you got the keys?"

alias apt='DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes'

# upgrade everything first
echo "packages"
apt clean
apt update
apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
# install oft-used packages
apt install curl
apt install zsh
apt install ssh
apt install git
apt install vim
apt install tmux
apt install exuberant-ctags
apt install netcat-traditional
apt install openjdk-6-jdk

echo "Now run the vagrant script..."
su vagrant -c '/vagrant/as-user.sh'
