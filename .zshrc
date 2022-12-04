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
prompt off

# Fix shell bugs
export TERMINFO=/usr/share/terminfo 

# Powerline stuff
powerline-daemon -q
. /home/guy/.local/lib/python3.10/site-packages/powerline/bindings/zsh/powerline.zsh

# Yank to the system clipboard
function vi-yank-xclip {
    zle vi-yank
   echo -n "$CUTBUFFER" | xclip -sel clip
}

zle -N vi-yank-xclip
bindkey -M vicmd 'y' vi-yank-xclip


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$('/home/guy/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
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


# Search plugin (arrow keys)
source /home/guy/.zsh_repos/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
        
#export PATH="/usr/local/bin:$PATH"
#alias python=python3
