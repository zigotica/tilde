# Dotfiles backup using a bare repository


This approach is following [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles) article. I just changed the alias and destination folder a bit: 


## Create new bare repo from scratch


```
cd ~
git init --bare $HOME/.config-dot
alias dot='/usr/bin/git --git-dir=$HOME/.config-dot/ --work-tree=$HOME'
dot config --local status.showUntrackedFiles no
```


At this point the article has a command to append the alias to `.bashrc`. But since my bash profile is a bit more elaborated, I just added it manually in `/.config/bash/.aliases`.


In my case then I am using `dot status`, `dot add`, `dot commit`, etc. 


## Clone bare repo in new machine


First, you need to make sure you don't already have these files / folders in your machine, to avoid conflicts. You can simply backup or remove them, depending on your situation. Then: 


```
alias dot='/usr/bin/git --git-dir=$HOME/.config-dot/ --work-tree=$HOME'
echo ".config-dot" >> .gitignore
git clone --bare <git-repo-url> $HOME/.config-dot
alias dot='/usr/bin/git --git-dir=$HOME/.config-dot/ --work-tree=$HOME'
dot checkout
dot config --local status.showUntrackedFiles no
```


...and you're good to go. Again, in this case, you would be using `dot status`, `dot add`, `dot commit`, etc. 

## Install other software

You can get a list of manually installed formulae with `brew bundle dump` (this will create a file called Brewfile). You can also list the formulae installed manually by typing `brew leaves --installed-on-request`. In my case, I will need to install:

Brew:
bash
bash-completion@2
coreutils
exa
ffmpeg
fzf
git
git-lfs
htop
mas
neovim
nvm
pfetch
plug
the_silver_searcher
tmux
wakeonlan
wget
yarn
youtube-dl

Brew casks:
alacritty
arduino
balenaetcher
docker
dropbox
easyeda
figma
firefox
forticlient
google-chrome
google-drive-file-stream
handbrake
imageoptim
mediahuman-audio-converter
musicbrainz-picard
sketch
sketch-toolbox
skype
slack
sourcetree
spotify
tripmode
tunnelblick
vlc
zerotier-one
zoom
