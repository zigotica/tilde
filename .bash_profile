# Load the shell dotfiles:
for file in ~/.config/bash/.{exports,functions,aliases,profile,path,prompt}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
