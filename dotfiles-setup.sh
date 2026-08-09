#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v rsync >/dev/null 2>&1; then
    echo "Error: rsync is required. Install it and rerun this script." >&2
    exit 1
fi

# shellcheck source=dotfiles-manifest.sh
source "$DOTFILES_DIR/dotfiles-manifest.sh"

# Create necessary directories
mkdir -p "$DOTFILES_DIR/.config" "$DOTFILES_DIR/bin"

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
        # Dereference source symlinks and preserve useful file metadata, but
        # never copy system ownership/group into the user-owned repository.
        rsync -rltpLh --progress "$src" "$dest"
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

# Copy the portable pieces of the generated Firefox Developer Edition profile.
if firefox_profile_dir="$(find_firefox_developer_profile)"; then
    for file in "${FIREFOX_PROFILE_FILES[@]}"; do
        sync_file \
            "$firefox_profile_dir/$file" \
            "$DOTFILES_DIR/.config/firefox/$file"
    done
else
    echo "Warning: Firefox Developer Edition profile not found, skipping"
fi

# Copy user scripts back to their repository paths.
for file in "${USER_SCRIPTS[@]}"; do
    sync_file "$HOME/.local/bin/${file##*/}" "$DOTFILES_DIR/$file"
done

# Copy system configuration files
for file in "${XORG_CONFIGS[@]}"; do
    sync_file "/etc/X11/xorg.conf.d/$file" "$DOTFILES_DIR/$file"
done

for file in "${UDEV_RULES[@]}"; do
    sync_file "/etc/udev/rules.d/$file" "$DOTFILES_DIR/$file"
done

# Never rewrite the live shell config behind a symlink. Refuse to continue if
# a real key was placed in the tracked copy.
for key in ANTHROPIC_API_KEY GEMINI_API_KEY XAI_API_KEY OPENAI_API_KEY; do
    assignment="$(grep -E "^export ${key}=" "$DOTFILES_DIR/.zshrc" | tail -n 1 || true)"
    [ -z "$assignment" ] && continue

    value="${assignment#*=}"
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    if [ -n "$value" ] && [ "$value" != "YOUR_KEY_HERE" ]; then
        echo "Error: $key contains a non-placeholder value in tracked .zshrc." >&2
        echo "Move secrets to an untracked file before collecting dotfiles." >&2
        exit 1
    fi
done
unset assignment value key
echo "Tracked API key placeholders verified."

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
