# Solves weird urxvt bug where line starts low after some spacing without
# clearing every new Alacritty/WezTerm window.
[[ "$TERM" == rxvt* ]] && clear

# iHD Driver
#export LIBVA_DRIVER_NAME=iHD
#export LIBVA_DRIVER_NAME=i965
#export LIBVA_DRIVERS_PATH=/usr/lib/dri

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify menucomplete automenu
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/guy/.zshrc'

zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit
compinit
# End of lines added by compinstall

# Fix shell bugs
export TERMINFO=/usr/share/terminfo 

# AI
#export ANTHROPIC_API_KEY=YOUR_KEY_HERE
#export ANTHROPIC_API_KEY=YOUR_KEY_HERE
export GEMINI_API_KEY=YOUR_KEY_HERE
export XAI_API_KEY=YOUR_KEY_HERE
export OPENAI_API_KEY=YOUR_KEY_HERE

# Powerline stuff
# Keep the daemon for fast prompt rendering, but only start it when needed.
# Powerline's generic binding also starts Python three times to discover this
# known prompt/tmux setup; answer those checks cheaply and use its compiled
# daemon client directly. The stock discovery path remains as a fallback.
if (( $+commands[powerline] )); then
    if ! pgrep -u "$EUID" -f '[/]powerline-daemon( |$)' >/dev/null; then
        powerline-daemon -q
    fi

    POWERLINE_CONFIG_COMMAND=/usr/bin/true
    POWERLINE_COMMAND=powerline
    . /usr/lib/python3.14/site-packages/powerline/bindings/zsh/powerline.zsh
    unset POWERLINE_CONFIG_COMMAND
else
    . /usr/lib/python3.14/site-packages/powerline/bindings/zsh/powerline.zsh
fi

# Keep the active Powerline prompt rich, but collapse prompts in scrollback to a
# quiet marker once a command is accepted (Powerlevel10k calls this transient
# prompt). PS1 is restored before the command runs, so the next prompt is full.
function powerline-transient-accept-line {
    emulate -L zsh

    local full_ps1="$PS1"
    local full_rps1="$RPS1"

    PS1='%F{#c3f542}❯%f '
    RPS1=''
    zle reset-prompt

    PS1="$full_ps1"
    RPS1="$full_rps1"
    zle .accept-line
}

zle -N powerline-transient-accept-line
for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^M' powerline-transient-accept-line
    bindkey -M "$keymap" '^J' powerline-transient-accept-line
done
unset keymap

# Yank to the system clipboard
function vi-yank-xclip {
    zle vi-yank
    echo -n "$CUTBUFFER" | xclip -sel clip
}

# Paste from system clipboard
function vi-put-xclip {
    CUTBUFFER="$(xclip -sel clip -o)"
    zle vi-put-after
}

zle -N vi-yank-xclip
zle -N vi-put-xclip

bindkey -M vicmd 'y' vi-yank-xclip
bindkey -M vicmd 'p' vi-put-xclip   # paste with p in normal mode

# Load Conda's static shell integration directly. It is the same code emitted
# by `conda shell.zsh hook` on this machine, without starting Python for every
# new terminal.
if [[ -r /home/guy/anaconda3/etc/profile.d/conda.sh ]]; then
    . /home/guy/anaconda3/etc/profile.d/conda.sh
else
    export PATH="/home/guy/anaconda3/bin:$PATH"
fi

# For aider
export PATH="/home/guy/.local/bin:$PATH"

# Search history for the text already typed at the prompt.
history_search_plugin="$HOME/.zsh_repos/zsh-history-substring-search/zsh-history-substring-search.zsh"
if [[ -r "$history_search_plugin" ]]; then
    source "$history_search_plugin"

    for keymap in emacs viins; do
        # WezTerm/xterm normal and application cursor modes.
        bindkey -M "$keymap" '^[[A' history-substring-search-up
        bindkey -M "$keymap" '^[[B' history-substring-search-down
        bindkey -M "$keymap" '^[OA' history-substring-search-up
        bindkey -M "$keymap" '^[OB' history-substring-search-down

        # Use terminfo too when the current terminal provides it.
        [[ -n "${terminfo[kcuu1]-}" ]] &&
            bindkey -M "$keymap" "$terminfo[kcuu1]" history-substring-search-up
        [[ -n "${terminfo[kcud1]-}" ]] &&
            bindkey -M "$keymap" "$terminfo[kcud1]" history-substring-search-down
    done
fi
unset history_search_plugin keymap

        
#export PATH="/usr/local/bin:$PATH"
#alias python=python3

# Lazy load nvm to improve shell startup time
export NVM_DIR="$HOME/.config/nvm"

# Function to lazy load nvm
load_nvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Create wrapper functions that load nvm on first use
nvm() {
    unset -f nvm node npm npx
    load_nvm
    nvm "$@"
}

node() {
    unset -f nvm node npm npx
    load_nvm
    node "$@"
}

npm() {
    unset -f nvm node npm npx
    load_nvm
    npm "$@"
}

npx() {
    unset -f nvm node npm npx claude
    load_nvm
    npx "$@"
}

claude() {
    unset -f nvm node npm npx claude
    load_nvm
    claude "$@"
}

# pnpm
export PNPM_HOME="/home/guy/.local/bin"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
