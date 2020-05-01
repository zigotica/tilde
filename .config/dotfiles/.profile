#!/usr/bin/env bash

# Bash completion
bind 'set completion-ignore-case on'
shopt -s cdspell autocd histappend
complete -d cd

# Bash Git completion
gitcompletionpath="/usr/local/Cellar/git/2.7.4/etc/bash_completion.d/git-completion.bash"
[[ -s $gitcompletionpath ]] && source $gitcompletionpath
