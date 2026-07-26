#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v rsync >/dev/null 2>&1; then
    echo "Error: rsync is required. Install it and rerun this script." >&2
    exit 1
fi

# Create necessary directories
mkdir -p "$DOTFILES_DIR/.config"

# List of dotfiles from home directory to manage
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

# List of .config directories/files to manage
CONFIG_DIRS=(
    "alacritty"
    "awesome"
    "nvim"
    "powerline"
    "wezterm"
)

XORG_CONFIGS=(
    "00-keyboard.conf"
    "30-touchpad.conf"
)

UDEV_RULES=(
    "90-battery-threshold.rules"
)

# Function to sync files
sync_file() {
    local src="$1"
    local dest="$2"
    local src_real
    local dest_real
    
    if [ -e "$src" ]; then
        src_real="$(readlink -f -- "$src")"
        dest_real="$(readlink -f -- "$dest" 2>/dev/null || true)"

        # Most installed dotfiles are symlinks back into this repository.
        # Copying such a symlink onto its own target creates a symlink loop.
        if [ -n "$dest_real" ] && [ "$src_real" = "$dest_real" ]; then
            echo "Already linked, skipping $src"
            return
        fi

        echo "Copying $src to $dest"
        # Dereference source symlinks so the repository stores real files.
        rsync -ahL --progress "$src" "$dest"
    else
        echo "Warning: $src does not exist, skipping"
    fi
}

# Copy home dotfiles
for file in "${HOME_DOTFILES[@]}"; do
    sync_file ~/"$file" "$DOTFILES_DIR/$file"
done

# Copy .config files
for dir in "${CONFIG_DIRS[@]}"; do
    sync_file ~/.config/"$dir"/ "$DOTFILES_DIR/.config/$dir/"
done

# Copy system configuration files
for file in "${XORG_CONFIGS[@]}"; do
    sync_file "/etc/X11/xorg.conf.d/$file" "$DOTFILES_DIR/$file"
done

for file in "${UDEV_RULES[@]}"; do
    sync_file "/etc/udev/rules.d/$file" "$DOTFILES_DIR/$file"
done

# Sanitize API keys from the repository copy.
echo "Sanitizing API keys from .zshrc..."
sed -i \
    -e 's/export ANTHROPIC_API_KEY=.*/export ANTHROPIC_API_KEY=YOUR_KEY_HERE/' \
    -e 's/export GEMINI_API_KEY=.*/export GEMINI_API_KEY=YOUR_KEY_HERE/' \
    -e 's/export XAI_API_KEY=.*/export XAI_API_KEY=YOUR_KEY_HERE/' \
    -e 's/export OPENAI_API_KEY=.*/export OPENAI_API_KEY=YOUR_KEY_HERE/' \
    "$DOTFILES_DIR/.zshrc"

echo "Dotfiles sync completed!"
echo ""
echo "Next steps:"
echo "1. Review the copied files"
echo "2. Commit changes to git:"
echo "   cd ~/dotfiles"
echo "   git add ."
echo "   git commit -m 'Update dotfiles'"
echo "   git push"
echo ""
echo "To use these dotfiles on a new system:"
echo "1. Clone the repo: git clone <your-repo-url> ~/dotfiles"
echo "2. Create symbolic links manually as needed:"
echo "   ln -s ~/dotfiles/.bashrc ~/.bashrc"
echo "   ln -s ~/dotfiles/.config/nvim ~/.config/nvim"
echo "   etc..."
