#!/usr/bin/env bash

# Bash completion
bind 'set completion-ignore-case on'
shopt -s cdspell autocd histappend
complete -d cd

if [ "$(uname -s)" == "Darwin" ]; then
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi
