#!/bin/bash

set -euo pipefail

# Symlink dotfiles from repo to home on a new system
# Usage: git clone <repo-url> ~/dotfiles && cd ~/dotfiles && ./dotfiles-install.sh

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=dotfiles-manifest.sh
source "$DOTFILES_DIR/dotfiles-manifest.sh"

install_system=true
if [ "${1:-}" = "--user-only" ]; then
    install_system=false
    shift
fi
if [ "$#" -ne 0 ]; then
    echo "Usage: $0 [--user-only]" >&2
    exit 2
fi

mkdir -p "$HOME/.config" "$HOME/.local/bin"

link_path() {
    local source="$1"
    local destination="$2"
    local backup
    local source_real
    local destination_real

    source_real="$(readlink -f -- "$source")"
    destination_real="$(readlink -f -- "$destination" 2>/dev/null || true)"
    if [ -L "$destination" ] \
        && [ -n "$destination_real" ] \
        && [ "$destination_real" = "$source_real" ]; then
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

if firefox_profile_dir="$(find_firefox_developer_profile)"; then
    mkdir -p "$firefox_profile_dir/chrome"
    for file in "${FIREFOX_PROFILE_FILES[@]}"; do
        if [ -f "$DOTFILES_DIR/.config/firefox/$file" ]; then
            link_path \
                "$DOTFILES_DIR/.config/firefox/$file" \
                "$firefox_profile_dir/$file"
        fi
    done
else
    echo "Skipped Firefox Developer Edition config (profile not found)."
fi

for file in "${USER_SCRIPTS[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        link_path "$DOTFILES_DIR/$file" "$HOME/.local/bin/${file##*/}"
    fi
done

if $install_system; then
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
else
    echo "Skipped system configuration (--user-only)."
fi

echo "Done! You may need to fill in API keys in ~/.zshrc"
