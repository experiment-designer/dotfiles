#!/bin/bash

# Shared by the collector and installer. Keep every managed path here so the
# two directions cannot drift apart.

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
    "30-touchpad.conf"
)

UDEV_RULES=(
    "90-battery-threshold.rules"
)
