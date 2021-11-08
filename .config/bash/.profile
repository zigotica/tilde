#!/usr/bin/env bash

# Bash completion
bind 'set completion-ignore-case on'
shopt -s cdspell autocd histappend
complete -d cd

if [ "$(uname -s)" == "Darwin" ]; then
  [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
fi

# ctrl+g: go to favourite folder finder and tmux session
bind '"\007": "gt\015"'
# ctrl+h: launch cheatsheet helper
bind '"\010": "cheatsh\015"'

# pipe fzf searches through ag
# it's faster and allows filtering out .gitignore content
if [[ ! -z $(which fzf) ]] && [[ ! -z $(which ag) ]]; then
  export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS='
  --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
  --color info:108,prompt:109,spinner:108,pointer:168,marker:168
  '
fi

# Run tmux on startup
if [[ ! "$TERM" =~ screen ]]; then
    tmux
fi
