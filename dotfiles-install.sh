#!/bin/bash

# Symlink dotfiles from repo to home on a new system
# Usage: git clone <repo-url> ~/dotfiles && cd ~/dotfiles && ./dotfiles-install.sh

DOTFILES_DIR=~/dotfiles

HOME_DOTFILES=(
    ".bashrc"
    ".vimrc"
    ".xbindkeysrc"
    ".xinitrc"
    ".zshrc"
    ".zprofile"
    ".Xresources"
    ".gitconfig"
)

CONFIG_DIRS=(
    "alacritty"
    "awesome"
    "nvim"
    "powerline"
)

mkdir -p ~/.config

for file in "${HOME_DOTFILES[@]}"; do
    if [ -e "$DOTFILES_DIR/$file" ]; then
        ln -sf "$DOTFILES_DIR/$file" ~/"$file"
        echo "Linked ~/$file"
    fi
done

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
        ln -sfn "$DOTFILES_DIR/.config/$dir" ~/.config/"$dir"
        echo "Linked ~/.config/$dir"
    fi
done

echo "Done! You may need to fill in API keys in ~/.zshrc"
