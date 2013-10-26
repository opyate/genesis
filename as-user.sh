#!/bin/zsh

echo "Home is $HOME"

echo "Change default shell..."
echo "vagrant" | chsh -s /bin/zsh

GENESIS=$HOME/.genesis

ssh -T -o "VerifyHostKeyDNS yes" -o "StrictHostKeyChecking no" git@github.com

# make myself available somewhere
echo "meta"

[[ -e $GENESIS ]] && echo \"Exists: $GENESIS\" || git clone git@github.com:opyate/genesis.git $GENESIS

# SBT
echo "sbt"
if which sbt; then
	echo "SBT is installed"
else
	echo "Installing SBT"
	curl -o /tmp/sbt.deb http://repo.scala-sbt.org/scalasbt/sbt-native-packages/org/scala-sbt/sbt/0.13.0/sbt.deb
	sudo dpkg -i /tmp/sbt.deb
fi

# customise zsh
echo "zsh"
cd ~
[[ -e $HOME/.zprezto ]] && echo "Exists: ~/.zprezto" || git clone --recursive git@github.com:opyate/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
	[[ -e "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]] && echo "Exists: symlink ${ZDOTDIR:-$HOME}/.$rcfile" || ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# grab dotfiles
echo "dotfiles"
[[ -e $HOME/.tmux.conf ]] && echo "Exists $GENESIS/dotfiles/.tmux.conf" || ln -s $GENESIS/dotfiles/.tmux.conf $HOME/.tmux.conf
[[ -e $HOME/.gitignore ]] && echo "Exists $GENESIS/dotfiles/.gitignore" || ln -s $GENESIS/dotfiles/.gitignore $HOME/.gitignore

# set up vim
echo "vim"
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

[[ -e $HOME/.vimrc ]] && echo "Exists $GENESIS/dotfiles/.vimrc" || ln -s $GENESIS/dotfiles/.vimrc $HOME/.vimrc

# vim plugins
echo "vim plugins"
repos=(
	"git://github.com/megaannum/self.git"
	"git://github.com/megaannum/forms.git"
	"git://github.com/Shougo/vimproc.git"
	"git://github.com/Shougo/vimshell.git"
	"git@github.com:opyate/ensime.git"
	"-b matchlist git@github.com:opyate/vimside.git"
	"https://github.com/kien/ctrlp.vim.git"
	"https://github.com/scrooloose/nerdtree.git"
	"https://github.com/tpope/vim-sensible.git"
	"https://github.com/tpope/vim-fugitive.git"
	"https://github.com/derekwyatt/vim-scala.git"
);

cd $HOME/.vim/bundle

for repo in "${repos[@]}"; do
	reponame=$(echo $repo | sed -nr 's#^.*/(.*)\.git$#\1#p')
	[[ -e $reponame ]] && echo "Repo $reponame exists" || git clone ${=repo}
done; 

cd $HOME/.vim/bundle/vimproc
make

cp $HOME/.vim/bundle/vimside/data/vimside/example_vimside.properties $HOME/.vim/bundle/vimside/data/vimside/vimside.properties

echo "vimside.scala.version=\"2.10.2\"" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties
echo "vimside.java.version=\"1.6\"" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties
echo "ensime.install.path=$HOME/.vim/bundle/ensime" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties

# compile ensime
echo "ensime"
cd $HOME/.vim/bundle/ensime
sbt stage

echo "ensime.dist.dir=dist_2.10.2" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties
echo "ensime.config.file.name=ensime_config.vim" >> $HOME/.vim/bundle/vimside/data/vimside/vimside.properties 


# scala
echo "scala"
curl -s -o /tmp/scala.deb http://www.scala-lang.org/files/archive/scala-2.10.3.deb
sudo dpkg -i /tmp/scala.deb

# scala sources
# 'scala home' for vimside
echo "scala sources"
curl -L -s -o /tmp/scala-src.tgz https://github.com/scala/scala/archive/v2.10.3.tar.gz
SCALA_HOME=/usr/local/src/scala
sudo mkdir -p $SCALA_HOME
sudo tar xzf /tmp/scala-src.tgz -C $SCALA_HOME
SCALA_HOME=$SCALA_HOME/scala-2.10.3
sudo sh -c 'echo "SCALA_HOME='$SCALA_HOME'" >> /etc/profile.d/scala-home-for-sources.sh'
sudo sh -c 'echo "SCALA_HOME='$SCALA_HOME'" >> /etc/zsh/zprofile'

# java sources
# 'java home' for vimside
echo "java sources"
JZIP=$(dpkg -L openjdk-6-source | grep zip$)
JZIP_LOC=$(dirname $JZIP)
sudo unzip -qq $JZIP -d $JZIP_LOC
sudo sh -c 'echo "JAVA_HOME='$JZIP_LOC'" >> /etc/profile.d/java-home-for-sources.sh'
sudo sh -c 'echo "JAVA_HOME='$JZIP_LOC'" >> /etc/zsh/zprofile'
