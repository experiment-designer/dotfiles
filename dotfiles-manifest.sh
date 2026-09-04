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
    "btop"
    "chromium-phosphor-theme"
    "fontconfig"
    "htop"
    "nvim"
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
    "bin/blip"
    "bin/blip-post-bash"
    "bin/rice-shot"
    "bin/brightness-step"
    "bin/htop"
)

XORG_CONFIGS=(
    "30-touchpad.conf"
)

UDEV_RULES=(
    "90-battery-threshold.rules"
)

PAM_CONFIGS=(
    "system-local-login"
    "xsecurelock"
)

SYSTEM_SLEEP_SCRIPTS=(
    "xsecurelock"
)

SYSTEMD_LOGIND_CONFIGS=(
    "60-power-button.conf"
)

find_firefox_developer_profile() {
    local firefox_root="${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox"
    local result
    [ -f "$firefox_root/profiles.ini" ] || return 1

    result="$(awk -v root="$firefox_root" '
        /^\[/ { if (found) exit; name = ""; path = ""; rel = "1" }
        /^Name=/ { name = substr($0, 6) }
        /^Path=/ { path = substr($0, 6) }
        /^IsRelative=/ { rel = substr($0, 12) }
        name == "dev-edition-default" && path != "" { found = 1 }
        END { if (found) print (rel == "0") ? path : root "/" path }
    ' "$firefox_root/profiles.ini")"

    [ -n "$result" ] && printf '%s\n' "$result"
}
