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
        elif [ ! -e "$2" ]; then
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
        if ! python3 - "$firefox_profile_dir/extensions.json" <<'PY'
import json
import sys

try:
    with open(sys.argv[1]) as registry:
        active = {addon["id"] for addon in json.load(registry)["addons"] if addon.get("active")}
except (OSError, ValueError, KeyError) as error:
    sys.exit(f"Cannot check Firefox add-ons: {error}")
missing = {"phosphor-newtab@guy.local", "tridactyl.vim@cmcaine.co.uk"} - active
if missing:
    sys.exit("Missing or inactive Firefox add-ons: " + ", ".join(sorted(missing)))
PY
        then
            issues=$((issues + 1))
        fi
        if [ ! -x "$HOME/.local/share/tridactyl/native_main" ]; then
            echo "missing Tridactyl native messenger: use :nativeinstall in Tridactyl"
            issues=$((issues + 1))
        fi
    elif [ -x /usr/bin/firefox-developer-edition ]; then
        echo "missing Firefox Developer Edition profile (start Firefox and rerun dotfiles-install.sh --user-only)"
        issues=$((issues + 1))
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
    for file in "${SYSTEMD_LOGIND_CONFIGS[@]}"; do report_system "$DOTFILES_DIR/systemd/logind.conf.d/$file" "/etc/systemd/logind.conf.d/$file"; done

    for file in "${UPOWER_CONFIGS[@]}"; do report_system "$DOTFILES_DIR/upower/$file" "/etc/UPower/$file"; done
    for file in "${SUDOERS_CONFIGS[@]}"; do
        if ! sudo -kn cmp -s "$DOTFILES_DIR/sudoers.d/$file" "/etc/sudoers.d/$file" ||
           [[ "$(sudo -n stat -c '%u:%g:%a' "/etc/sudoers.d/$file" 2>/dev/null)" != 0:0:440 ]]; then
            echo "check passwordless sudo and the installed /etc/sudoers.d/$file"
            issues=$((issues + 1))
        fi
    done
    if command -v tlp >/dev/null; then
        for file in "${TLP_CONFIGS[@]}"; do report_system "$DOTFILES_DIR/tlp.d/$file" "/etc/tlp.d/$file"; done
    fi
    battery=/sys/class/power_supply/BAT0
    if [[ -r "$battery/charge_control_start_threshold" && -r "$battery/charge_control_end_threshold" ]]; then
        source "$DOTFILES_DIR/tlp.d/60-dotfiles-charge.conf"
        read -r start < "$battery/charge_control_start_threshold"
        read -r stop < "$battery/charge_control_end_threshold"
        if [[ "$start/$stop" != "$START_CHARGE_THRESH_BAT0/$STOP_CHARGE_THRESH_BAT0" ]]; then
            echo "BAT0 charge thresholds: $start/$stop (configured $START_CHARGE_THRESH_BAT0/$STOP_CHARGE_THRESH_BAT0)"
            issues=$((issues + 1))
        fi
    fi
    if systemctl --user cat ssh-agent.socket >/dev/null 2>&1 && ! systemctl --user is-active --quiet ssh-agent.socket; then
        echo "inactive SSH agent socket: run dotfiles-install.sh --user-only"
        issues=$((issues + 1))
    fi

    echo ""
    echo "Unmanaged candidates (add to dotfiles-manifest.sh if wanted):"
    for dir in "$HOME/.config"/*/; do
        name="$(basename "$dir")"
        case " ${CONFIG_DIRS[*]} " in *" $name "*) continue ;; esac
        case " ${HOME_DOTFILES[*]} " in *" .config/$name/"*) continue ;; esac
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
    echo "$issues managed item(s) need attention."
    if ((issues > 0)); then exit 1; fi
    exit 0
fi

# Collection overwrites repo files with the live versions; refuse to clobber
# uncommitted repo edits unless explicitly forced.
if ! $force && [ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" ]; then
    echo "Error: repository has uncommitted changes that collection could overwrite." >&2
    echo "Commit or stash them first, or rerun with --force." >&2
    exit 1
fi

scan_secrets() {
    gitleaks dir --config="$DOTFILES_DIR/.gitleaks.toml" --redact=100 --no-banner \
        --log-level=error --max-archive-depth=2 --follow-symlinks "$1"
}

# Check linked files and fail before copying anything into the repository.
scan_secrets "$DOTFILES_DIR"

# Create necessary directories
mkdir -p \
    "$DOTFILES_DIR/.config" \
    "$DOTFILES_DIR/bin" \
    "$DOTFILES_DIR/pam.d" \
    "$DOTFILES_DIR/system-sleep" \
    "$DOTFILES_DIR/systemd/logind.conf.d"

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

        scan_secrets "$src_real"
        echo "Copying $src to $dest"
        mkdir -p -- "$(dirname -- "$dest")"
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

for file in "${SYSTEMD_LOGIND_CONFIGS[@]}"; do
    sync_file "/etc/systemd/logind.conf.d/$file" "$DOTFILES_DIR/systemd/logind.conf.d/$file"
done

mkdir -p "$DOTFILES_DIR/upower"
for file in "${UPOWER_CONFIGS[@]}"; do
    sync_file "/etc/UPower/$file" "$DOTFILES_DIR/upower/$file"
done

if command -v tlp >/dev/null; then
    for file in "${TLP_CONFIGS[@]}"; do
        sync_file "/etc/tlp.d/$file" "$DOTFILES_DIR/tlp.d/$file"
    done
fi

for file in "${SUDOERS_CONFIGS[@]}"; do
    (
        copy="$(mktemp)"
        trap 'unlink "$copy"' EXIT
        sudo cat "/etc/sudoers.d/$file" > "$copy"
        visudo -cf "$copy"
        install -D -m 0644 "$copy" "$DOTFILES_DIR/sudoers.d/$file"
    )
done

scan_secrets "$DOTFILES_DIR"

echo "Dotfiles sync completed!"
echo ""
echo "Next steps:"
echo "1. Review with: git -C ~/dotfiles diff"
echo "2. Commit and push."
echo ""
echo "On a new system: git clone <repo-url> ~/dotfiles && ~/dotfiles/dotfiles-install.sh"
echo "To audit what is linked/managed on this machine: $0 --check"
