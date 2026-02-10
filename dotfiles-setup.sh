#!/bin/bash

# Create necessary directories
mkdir -p ~/dotfiles/.config

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
)

# Function to sync files
sync_file() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$src" ]; then
        echo "Copying $src to $dest"
        # Use rsync to copy files while preserving attributes
        rsync -ah --progress "$src" "$dest"
    else
        echo "Warning: $src does not exist, skipping"
    fi
}

# Copy home dotfiles
for file in "${HOME_DOTFILES[@]}"; do
    sync_file ~/"$file" ~/dotfiles/"$file"
done

# Copy .config files
for dir in "${CONFIG_DIRS[@]}"; do
    sync_file ~/.config/"$dir"/ ~/dotfiles/.config/"$dir"/
done

# Sanitize API keys from .zshrc
echo "Sanitizing API keys from .zshrc..."
sed -i \
    -e 's/export ANTHROPIC_API_KEY=.*/export ANTHROPIC_API_KEY=YOUR_KEY_HERE/' \
    -e 's/export GEMINI_API_KEY=.*/export GEMINI_API_KEY=YOUR_KEY_HERE/' \
    -e 's/export XAI_API_KEY=.*/export XAI_API_KEY=YOUR_KEY_HERE/' \
    -e 's/export OPENAI_API_KEY=.*/export OPENAI_API_KEY=YOUR_KEY_HERE/' \
    ~/dotfiles/.zshrc

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
