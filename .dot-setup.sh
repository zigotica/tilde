#!/usr/bin/env bash

RED="$(tput setaf 1)"
GRN="$(tput setaf 2)"
YEL="$(tput setaf 3)"
RST="$(tput sgr0)"

echo -ne "\n${GRN}${RST} Installing pre-commit hook for dotfiles repo..."
cp .dot-pre-commit ._dotfiles.git/hooks/pre-commit
chmod ug+x ._dotfiles.git/hooks/pre-commit

