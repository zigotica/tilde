# Load the shell dotfiles:
# for file in ~/.config/bash/.{brew,profile,exports,functions,aliases,prompt}; do
for file in ~/.config/bash/.{brew,behavior,exports,path,functions,aliases}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# source hidden secret vars
source "$HOME/.bash_env_vars";

# Only initialize these in interactive shells (should fix sketchybar scripts)
if [[ $- == *i* ]]; then
  # oh-my-posh prompt
  eval "$(oh-my-posh init bash --config $HOME/.config/oh-my-posh/config.yml)"

  # terminal decorators
  eval $(ls $HOME/.config/bin/terminal-decorators/ | shuf -n 1)
fi
