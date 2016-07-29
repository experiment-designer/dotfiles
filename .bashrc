#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls -la --color=auto'
alias hibernate='systemctl hibernate'
PS1='[\u@\h \W]\$ '
