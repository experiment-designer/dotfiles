if [[ -z ${SSH_AUTH_SOCK:-} && -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi


# Added by Antigravity CLI installer
export PATH="/home/guy/.local/bin:$PATH"

# nvim everywhere (Firefox/Tridactyl "open with", git, awesome fall back to this).
export EDITOR=nvim VISUAL=nvim
