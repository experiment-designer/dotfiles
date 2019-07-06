# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=/home/guy/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="af-magic"
# POWERLEVEL9K_MODE='awesome-fontconfig'
#POWERLEVEL9K_MODE='awesome-patched'
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(anaconda status root_indicator background_jobs history)

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(vi-mode git command-not-found history-substring-search)

# Required for command-not-found
source /usr/share/doc/pkgfile/command-not-found.zsh

source $ZSH/oh-my-zsh.sh

# User configuration

# history search
# bindkey "^[[A" history-substring-search-up
# bindkey "^[[B" history-substring-search-down

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='vim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
# User aliases
alias hibernate='systemctl hibernate'
alias ls='ls -l --color=tty'
alias ipython='ipython --TerminalInteractiveShell.editing_mode=vi'
# Don't freeze my ass when hitting C-s
stty -ixon -ixoff

# Android settings
export ANDROID_HOME=/opt/android/sdk
PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Java
PATH=$PATH:/usr/lib/jvm/java-7-openjdk/bin

# Ruby settings
#PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"

# Matlab
PATH=$PATH:/usr/local/MATLAB/R2017a/bin

# Anaconda
con () {
    source ~/anaconda3/bin/activate ${1:-root}
}

coff () {
    typeset -a _path
    typeset _p
    for _p in $path
    do
        if [[ $_p != $HOME/anaconda3/* ]]
        then
            _path+=$_p
        fi
    done
    path=($_path)
    unset CONDA_DEFAULT_ENV
}
con
# source ~/anaconda3/etc/profile.d/conda.sh
# SSH settings
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/guy/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/home/guy/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/guy/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/guy/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
