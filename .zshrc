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

# Prompt: native zsh, single line, no plugins and no external commands per
# prompt beyond vcs_info's own git calls.
setopt PROMPT_SUBST
autoload -Uz vcs_info add-zsh-hook

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' max-exports 2
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '*'
# First export is the branch, second is the dirty marker (kept separate so a
# repo with both staged and unstaged work still prints a single '*').
zstyle ':vcs_info:git:*' formats       '%b'    '%u%c'
zstyle ':vcs_info:git:*' actionformats '%b|%a' '%u%c'

typeset -g _prompt_git=''

# Amber chevron in vi insert mode, magenta in normal mode, red after a failure.
function _prompt_chevron {
    local mode='#ffb340'
    [[ ${KEYMAP:-viins} == vicmd ]] && mode='#d67cff'
    print -r -- "%(?.%F{$mode}.%F{#ff4d6d})❯%f"
}

function _prompt_build {
    local host=''
    [[ -n $SSH_CONNECTION ]] && host='%F{#7b838f}%n@%m %f'
    PROMPT="${host}%F{#b7bec8}%~%f${_prompt_git} $(_prompt_chevron) "
    RPROMPT=''
}

function _prompt_precmd {
    vcs_info
    if [[ -z ${vcs_info_msg_0_} ]]; then
        _prompt_git=''
    elif [[ -n ${vcs_info_msg_1_} ]]; then
        _prompt_git=" %F{#ffb340}${vcs_info_msg_0_}*%f"
    else
        _prompt_git=" %F{#b7bec8}${vcs_info_msg_0_}%f"
    fi
    _prompt_build
}
add-zsh-hook precmd _prompt_precmd

# Recolour the chevron the moment the vi keymap changes.
function zle-keymap-select { _prompt_build; zle reset-prompt }
function zle-line-init     { _prompt_build; zle reset-prompt }
zle -N zle-keymap-select
zle -N zle-line-init

# Keep the live prompt rich, but collapse prompts in scrollback to a quiet grey
# chevron once a command is accepted (Powerlevel10k calls this transient
# prompt). PS1 is restored before the command runs, so the next prompt is full.
function transient-accept-line {
    emulate -L zsh

    local full_ps1="$PS1"
    local full_rps1="$RPS1"

    PS1='%F{#7b838f}❯%f '
    RPS1=''
    zle reset-prompt

    PS1="$full_ps1"
    RPS1="$full_rps1"
    zle .accept-line
}

zle -N transient-accept-line
for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^M' transient-accept-line
    bindkey -M "$keymap" '^J' transient-accept-line
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

# --- blip: audible notification for long-running commands -------------------
# preexec stores the start time + command name; precmd blips if the command ran
# for >= $BLIP_MIN_SECONDS and is not an interactive/foreground program.
BLIP_MIN_SECONDS=${BLIP_MIN_SECONDS:-8}
BLIP_IGNORE_CMDS=(vim nvim less man htop btop ssh claude codex agy python ipython zsh bash tmux)

_blip_preexec() {
  _blip_start=$SECONDS
  _blip_cmd=${${(z)1}[1]:t}
}

_blip_precmd() {
  local st=$?
  [[ -z $_blip_start ]] && return
  local elapsed=$(( SECONDS - _blip_start ))
  local cmd=$_blip_cmd
  unset _blip_start _blip_cmd
  (( elapsed >= BLIP_MIN_SECONDS )) || return
  (( ${BLIP_IGNORE_CMDS[(Ie)$cmd]} )) && return
  if (( st == 0 )); then
    ~/dotfiles/bin/blip tick
  else
    ~/dotfiles/bin/blip err
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _blip_preexec
add-zsh-hook precmd _blip_precmd
# --- end blip ---------------------------------------------------------------
