#!/bin/bash

echo "Home is $HOME"

GENESIS=$HOME/.genesis

ssh -T -o "VerifyHostKeyDNS yes" -o "StrictHostKeyChecking no" git@github.com

# make myself available somewhere
echo "meta"

[[ -e $GENESIS ]] && echo \"Exists: $GENESIS\" || git clone --recursive git@github.com:opyate/genesis.git $GENESIS
echo "Done with script"

# SBT
echo "sbt"
curl -o /tmp/sbt.deb http://repo.scala-sbt.org/scalasbt/sbt-native-packages/org/scala-sbt/sbt/0.13.0/sbt.deb
sudo dpkg -i /tmp/sbt.deb

# change the default shell
echo "zsh"
cd ~
git clone --recursive git@github.com:opyate/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
	ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh

# grab dotfiles
echo "dotfiles"
ln -s $GENESIS/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -s $GENESIS/dotfiles/.gitignore $HOME/.gitignore

install_ensime=false
# ensime
if [ $instal_ensime == true ] ; then
	echo "ensime"
	ENSIME=$HOME/ensime
	mkdir -p $ENSIME
	curl -L -o /tmp/ensime.tgz https://www.dropbox.com/sh/ryd981hq08swyqr/ZiCwjjr_vm/ENSIME%20Releases/ensime_2.10.0-0.9.8.9.tar.gz
	tar xzf /tmp/ensime.tgz -C $ENSIME
	ENSIME=$ENSIME/ensime_2.10.0-0.9.8.9
else
	echo "skipping ensime pre-built"
fi

# set up vim
echo "vim"
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

ln -s $GENESIS/dotfiles/.vimrc $HOME/.vimrc

cd $HOME/.vim/bundle/
git clone https://github.com/kien/ctrlp.vim.git
git clone https://github.com/scrooloose/nerdtree.git
git clone https://github.com/tpope/vim-sensible.git
git clone https://github.com/derekwyatt/vim-scala.git

# vimside (Vim Scala IDE)
echo "vimside"
declare -a repos=(
	"git://github.com/megaannum/self.git"
	"git://github.com/megaannum/forms.git"
	"git://github.com/Shougo/vimproc.git"
	"git://github.com/Shougo/vimshell.git"
	"git@github.com:opyate/ensime.git"
	"-b matchlist git@github.com:opyate/vimside.git"
);

cd $HOME/.vim/bundle

for repo in "${repos[@]}"; do
	git clone $repo
done; 

cd vimproc
make

cp $HOME/.vim/bundle/vimside/data/vimside/example_vimside.properties $HOME/.vim/bundle/vimside/data/vimside/vimside.properties

echo "vimside.scala.version=\"2.10.2\"" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties
echo "vimside.java.version=\"1.6\"" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties
echo "ensime.install.path=$HOME/.vim/bundle/ensime" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties

# compile ensime
echo "ensime"
cd $HOME/.vim/bundle/ensime
sbt stage
# see megaannum/vimside issue 25
FAKENAME="ensime_2.10.2-0.0.0.0"
mv dist_2.10.2 $FAKENAME

echo "ensime.dist.dir=$FAKENAME" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties
echo "ensime.config.file.name=ensime_config.vim" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties 

# 'scala home' for vimside
curl -L -s -o /tmp/scala-src.tgz https://github.com/scala/scala/archive/v2.10.3.tar.gz
SCALA_HOME=/usr/local/src/scala
sudo mkdir -p $SCALA_HOME
sudo tar xzf /tmp/scala-src.tgz -C $SCALA_HOME
SCALA_HOME=$SCALA_HOME/scala-2.10.3


# scala
echo "scala"
curl -s -o /tmp/scala.deb http://www.scala-lang.org/files/archive/scala-2.10.3.deb
sudo dpkg -i /tmp/scala.deb
