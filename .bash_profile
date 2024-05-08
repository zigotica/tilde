# Load the shell dotfiles:
for file in ~/.config/bash/.{brew,profile,exports,functions,aliases,prompt}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# source hidden secret vars
source "$HOME/.bash_env_vars";
