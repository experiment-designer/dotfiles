# Solves weird urxvt bug where line starts low after some spacing
clear

zmodload zsh/zprof

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
autoload -Uz promptinit
promptinit
prompt off

# Fix shell bugs
export TERMINFO=/usr/share/terminfo 

# AI
#export ANTHROPIC_API_KEY=YOUR_KEY_HERE
#export ANTHROPIC_API_KEY=YOUR_KEY_HERE
export GEMINI_API_KEY=YOUR_KEY_HERE
export XAI_API_KEY=YOUR_KEY_HERE
export OPENAI_API_KEY=YOUR_KEY_HERE

# Powerline stuff
powerline-daemon -q
. /usr/lib/python3.14/site-packages/powerline/bindings/zsh/powerline.zsh

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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/guy/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/guy/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/guy/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/guy/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# For aider
export PATH="/home/guy/.local/bin:$PATH"

# Search plugin (arrow keys)
source /home/guy/.zsh_repos/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down

        
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
