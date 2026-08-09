#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v rsync >/dev/null 2>&1; then
    echo "Error: rsync is required. Install it and rerun this script." >&2
    exit 1
fi

# shellcheck source=dotfiles-manifest.sh
source "$DOTFILES_DIR/dotfiles-manifest.sh"

check_only=false
force=false
for arg in "$@"; do
    case "$arg" in
        --check) check_only=true ;;
        --force) force=true ;;
        *) echo "Usage: $0 [--check] [--force]" >&2; exit 2 ;;
    esac
done

# Report the state of every managed path plus unmanaged candidates, then exit.
if $check_only; then
    issues=0

    report() { # repo path, live path
        local repo_real live_real
        repo_real="$(readlink -f -- "$1" 2>/dev/null || true)"
        live_real="$(readlink -f -- "$2" 2>/dev/null || true)"
        if [ ! -e "$1" ]; then
            echo "missing in repo:  $1"
        elif [ -z "$live_real" ]; then
            echo "missing in home:  $2"
        elif [ "$repo_real" = "$live_real" ]; then
            return 0
        elif diff -rq -- "$1" "$2" >/dev/null 2>&1; then
            echo "copy, in sync:    $2 (run dotfiles-install.sh to link)"
        else
            echo "copy, DIFFERS:    $2 (unlinked and diverged from repo)"
        fi
        issues=$((issues + 1))
    }

    for file in "${HOME_DOTFILES[@]}"; do report "$DOTFILES_DIR/$file" "$HOME/$file"; done
    for dir in "${CONFIG_DIRS[@]}"; do report "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"; done
    if firefox_profile_dir="$(find_firefox_developer_profile)"; then
        for file in "${FIREFOX_PROFILE_FILES[@]}"; do
            report "$DOTFILES_DIR/.config/firefox/$file" "$firefox_profile_dir/$file"
        done
    fi
    for file in "${USER_SCRIPTS[@]}"; do report "$DOTFILES_DIR/$file" "$HOME/.local/bin/${file##*/}"; done

    # System files are installed as copies, not symlinks; only divergence matters.
    report_system() { # repo path, live path
        if [ ! -e "$2" ]; then
            echo "missing in /etc:  $2 (run dotfiles-install.sh)"
        elif ! diff -q -- "$1" "$2" >/dev/null 2>&1; then
            echo "copy, DIFFERS:    $2 (diverged from repo)"
        else
            return 0
        fi
        issues=$((issues + 1))
    }
    for file in "${XORG_CONFIGS[@]}"; do report_system "$DOTFILES_DIR/$file" "/etc/X11/xorg.conf.d/$file"; done
    for file in "${UDEV_RULES[@]}"; do report_system "$DOTFILES_DIR/$file" "/etc/udev/rules.d/$file"; done
    for file in "${PAM_CONFIGS[@]}"; do report_system "$DOTFILES_DIR/pam.d/$file" "/etc/pam.d/$file"; done
    for file in "${SYSTEM_SLEEP_SCRIPTS[@]}"; do report_system "$DOTFILES_DIR/system-sleep/$file" "/usr/lib/systemd/system-sleep/$file"; done

    echo ""
    echo "Unmanaged candidates (add to dotfiles-manifest.sh if wanted):"
    for dir in "$HOME/.config"/*/; do
        name="$(basename "$dir")"
        case " ${CONFIG_DIRS[*]} " in *" $name "*) continue ;; esac
        echo "  ~/.config/$name"
    done
    for script in "$HOME/.local/bin"/*; do
        [ -e "$script" ] || continue
        name="${script##*/}"
        managed=false
        for file in "${USER_SCRIPTS[@]}"; do
            [ "${file##*/}" = "$name" ] && managed=true && break
        done
        $managed || echo "  ~/.local/bin/$name"
    done

    echo ""
    echo "$issues managed path(s) need attention."
    exit 0
fi

# Collection overwrites repo files with the live versions; refuse to clobber
# uncommitted repo edits unless explicitly forced.
if ! $force && [ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" ]; then
    echo "Error: repository has uncommitted changes that collection could overwrite." >&2
    echo "Commit or stash them first, or rerun with --force." >&2
    exit 1
fi

# Create necessary directories
mkdir -p \
    "$DOTFILES_DIR/.config" \
    "$DOTFILES_DIR/bin" \
    "$DOTFILES_DIR/pam.d" \
    "$DOTFILES_DIR/system-sleep"

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
            return 0
        fi

        echo "Copying $src to $dest"
        # Dereference source symlinks and preserve useful file metadata, but
        # never copy system ownership/group into the user-owned repository.
        # --delete keeps the repo a true mirror; git history guards against loss.
        rsync -rltpLh --delete --progress "$src" "$dest"
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

for file in "${PAM_CONFIGS[@]}"; do
    sync_file "/etc/pam.d/$file" "$DOTFILES_DIR/pam.d/$file"
done

for file in "${SYSTEM_SLEEP_SCRIPTS[@]}"; do
    sync_file "/usr/lib/systemd/system-sleep/$file" "$DOTFILES_DIR/system-sleep/$file"
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
echo "1. Review with: git -C ~/dotfiles diff"
echo "2. Commit and push."
echo ""
echo "On a new system: git clone <repo-url> ~/dotfiles && ~/dotfiles/dotfiles-install.sh"
echo "To audit what is linked/managed on this machine: $0 --check"
