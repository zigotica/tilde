#!/usr/bin/env bash

# Bash completion
if [ "$(uname -s)" == "Darwin" ]; then
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

shopt -s autocd
shopt -s cdspell
shopt -s dirspell
# shopt -s dotglob
shopt -s globstar
shopt -s histappend
shopt -s nullglob
complete -d cd

if [ -t 1 ]; then
  bind 'set completion-ignore-case on' # Use case-insensitive TAB autocompletion
  # ctrl+g: go to favourite folder finder and tmux session
  bind '"\007": "gt\015"'
  # ctrl+f: save folder to gt list of folders
  bind '"\006": "fff\015"'
  # ctrl+h: launch cheatsheet helper
  bind '"\010": "cheatsh\015"'
fi


