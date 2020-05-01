# Dotfiles backup using a bare repository


This approach is following [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles) article. I just changed the alias and destination folder a bit: 


## Create new bare repo from scratch


```
cd ~
git init --bare $HOME/.config-tilde
alias tilde='/usr/bin/git --git-dir=$HOME/.config-tilde/ --work-tree=$HOME'
tilde config --local status.showUntrackedFiles no
```


At this point the article has a command to append the alias to `.bashrc`. But since my bash profile is a bit more elaborated, I just added it manually in `/.config/bash/.aliases`.


In my case then I am using `tilde status`, `tilde add`, `tilde commit`, etc. 


## Clone bare repo in new machine


First, you need to make sure you don't already have these files / folders in your machine, to avoid conflicts. You can simply backup or remove them, depending on your situation. Then: 


```
alias tilde='/usr/bin/git --git-dir=$HOME/.config-tilde/ --work-tree=$HOME'
echo ".config-tilde" >> .gitignore
git clone --bare <git-repo-url> $HOME/.config-tilde
alias tilde='/usr/bin/git --git-dir=$HOME/.config-tilde/ --work-tree=$HOME'
tilde checkout
tilde config --local status.showUntrackedFiles no
```


...and you're good to go. Again, in this case, you would be using `tilde status`, `tilde add`, `tilde commit`, etc. 

