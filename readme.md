# Dotfiles backup using a bare repository


This approach is following [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles) article. I just changed the alias and destination folder a bit: 


## Create new bare repo from scratch


```
cd ~
git init --bare $HOME/._dotfiles.git
alias dot='/usr/bin/git --git-dir=$HOME/._dotfiles.git/ --work-tree=$HOME'
dot config --local status.showUntrackedFiles no
```


At this point the article has a command to append the alias to `.bashrc`. But since my bash profile is a bit more elaborated, I just added it manually in `/.config/bash/.aliases`.


In my case then I am using `dot status`, `dot add`, `dot commit`, etc. 


## Clone bare repo in new machine

I actually use [this shell script](https://github.com/zigotica/automated-desktop-setup) to automate my desktop setup. One of the options is actually cloning this repo as a bare repo.

If you want to do this manually, make sure you backup these files / folders in your machine, to avoid conflicts. How I do it: 


```
echo Clone bare repo using https (to avoid requiring .ssh key)
git clone --bare https://github.com/zigotica/tilde.git $HOME/._dotfiles.git

echo Hide untracked files
/opt/homebrew/bin/git --git-dir=$HOME/._dotfiles.git/ --work-tree=$HOME config status.showUntrackedFiles no

echo Add bare repo to .gitignore
echo ._dotfiles.git >> $HOME/.gitignore

echo backup current dotfiles
mv $HOME/.config $HOME/.config.bk
mv $HOME/.bash_profile $HOME/.bash_profile.bk
mv $HOME/.bashrc $HOME/.bashrc.bk
mv $HOME/.tmux.conf $HOME/.tmux.conf.bk
mv $HOME/readme.md $HOME/readme.md.bk

echo Checkout
cd $HOME && /opt/homebrew/bin/git --git-dir=$HOME/._dotfiles.git/ --work-tree=$HOME checkout

echo update remote url to use ssh
/opt/homebrew/bin/git --git-dir=$HOME/._dotfiles.git/ --work-tree=$HOME remote set-url origin git@github.com:zigotica/tilde.git

echo copy .ssh_bk encrypted files into .ssh and decrypt them
mkdir $HOME/.ssh && cp $HOME/.ssh_bk/* $HOME/.ssh/ && ansible-vault decrypt $HOME/.ssh/*

echo DONE
echo Note that some of these changes require a logout/restart to take effect
```


...and you're good to go.

Please note, in my case, I am keeping my ssh keys and config encrypted in a folder inside this repo (`.ssh_bk`). To encrypt/decrypt I am using ansible-vault on all the files of this folder, for instance, `ansible-vault encrypt $HOME/.ssh/*`, and `ansible-vault decrypt $HOME/.ssh/*`. In both cases, it will prompt for a password and use AES256. In the example above, I copy the encrypted files to a proper `.ssh` folder when cloning the repo, then decrypt them. This way the decrypted files will never be part of the repo.

Finally, once resourcing or restarting the shell, I would be using `dot status`, `dot add`, `dot commit`, etc. since they are part of my aliases.
