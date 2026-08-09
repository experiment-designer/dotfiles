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

# These files are installed into Firefox Developer Edition's generated profile
# directory instead of ~/.config directly.
FIREFOX_PROFILE_FILES=(
    "user.js"
    "chrome/userChrome.css"
    "chrome/userContent.css"
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

find_firefox_developer_profile() {
    local firefox_root="${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox"
    local profiles_file
    local section=""
    local profile_name=""
    local profile_path=""
    local is_relative="1"
    local line

    profiles_file="$firefox_root/profiles.ini"
    [ -f "$profiles_file" ] || return 1

    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            \[Profile*\])
                if [ "$section" = "profile" ] \
                    && [ "$profile_name" = "dev-edition-default" ] \
                    && [ -n "$profile_path" ]; then
                    if [ "$is_relative" = "1" ]; then
                        printf '%s/%s\n' "$firefox_root" "$profile_path"
                    else
                        printf '%s\n' "$profile_path"
                    fi
                    return 0
                fi
                section="profile"
                profile_name=""
                profile_path=""
                is_relative="1"
                ;;
            \[*\])
                if [ "$section" = "profile" ] \
                    && [ "$profile_name" = "dev-edition-default" ] \
                    && [ -n "$profile_path" ]; then
                    if [ "$is_relative" = "1" ]; then
                        printf '%s/%s\n' "$firefox_root" "$profile_path"
                    else
                        printf '%s\n' "$profile_path"
                    fi
                    return 0
                fi
                section=""
                ;;
            Name=*)
                [ "$section" = "profile" ] \
                    && profile_name="${line#Name=}"
                ;;
            Path=*)
                [ "$section" = "profile" ] \
                    && profile_path="${line#Path=}"
                ;;
            IsRelative=*)
                [ "$section" = "profile" ] \
                    && is_relative="${line#IsRelative=}"
                ;;
        esac
    done < "$profiles_file"

    if [ "$section" = "profile" ] \
        && [ "$profile_name" = "dev-edition-default" ] \
        && [ -n "$profile_path" ]; then
        if [ "$is_relative" = "1" ]; then
            printf '%s/%s\n' "$firefox_root" "$profile_path"
        else
            printf '%s\n' "$profile_path"
        fi
        return 0
    fi

    return 1
}
