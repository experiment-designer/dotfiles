#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export EDITOR=vim
export ANDROID_HOME=/opt/android/sdk
#PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
#PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
pactl set-sink-volume alsa_output.pci-0000_00_1b.0.analog-stereo 200%
