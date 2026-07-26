#!/bin/bash

set -euo pipefail

# Symlink dotfiles from repo to home on a new system
# Usage: git clone <repo-url> ~/dotfiles && cd ~/dotfiles && ./dotfiles-install.sh

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

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
    "wezterm"
)

USER_SCRIPTS=(
    "BMT.sh"
    "bin/brightness-step"
)

XORG_CONFIGS=(
    "00-keyboard.conf"
    "30-touchpad.conf"
)

UDEV_RULES=(
    "90-battery-threshold.rules"
)

mkdir -p ~/.config ~/.local/bin

link_path() {
    local source="$1"
    local destination="$2"
    local backup

    if [ -L "$destination" ] \
        && [ "$(readlink -f -- "$destination")" = "$(readlink -f -- "$source")" ]; then
        echo "Already linked $destination"
        return
    fi

    if [ -e "$destination" ] || [ -L "$destination" ]; then
        backup="${destination}.pre-dotfiles"
        if [ -e "$backup" ] || [ -L "$backup" ]; then
            backup="${backup}.$(date +%Y%m%d%H%M%S)"
        fi
        mv -- "$destination" "$backup"
        echo "Backed up $destination to $backup"
    fi

    ln -s -- "$source" "$destination"
    echo "Linked $destination"
}

for file in "${HOME_DOTFILES[@]}"; do
    if [ -e "$DOTFILES_DIR/$file" ]; then
        link_path "$DOTFILES_DIR/$file" "$HOME/$file"
    fi
done

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
        link_path "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
    fi
done

for file in "${USER_SCRIPTS[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        link_path "$DOTFILES_DIR/$file" "$HOME/.local/bin/${file##*/}"
    fi
done

for file in "${XORG_CONFIGS[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        sudo install -D -m 0644 \
            "$DOTFILES_DIR/$file" \
            "/etc/X11/xorg.conf.d/$file"
        echo "Installed /etc/X11/xorg.conf.d/$file"
    fi
done

for file in "${UDEV_RULES[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        sudo install -D -m 0644 \
            "$DOTFILES_DIR/$file" \
            "/etc/udev/rules.d/$file"
        echo "Installed /etc/udev/rules.d/$file"
    fi
done

echo "Done! You may need to fill in API keys in ~/.zshrc"
