# Dotfiles backup using a bare repository

This approach is following [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles) article. I just changed the alias and destination folder a bit: 


```
cd ~
git init --bare $HOME/.config-tilde
alias tilde='/usr/bin/git --git-dir=/Users/zgtc/.config-tilde/ --work-tree=/Users/zgtc'
tilde config --local status.showUntrackedFiles no
```

At this point the article has a command to append the alias to `.bashrc`. But since my bash profile is a bit more elaborated, I just added it manually in `/.config/bash/.aliases`.

In my case then I am using `tilde status`, `tilde add`, `tilde commit`, etc. 