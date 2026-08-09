#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then







    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then


    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

#twm &
#xclock -geometry 50x50-1+1 &
#xterm -geometry 80x50+494+51 &
#xterm -geometry 80x20+494-0 &
#exec xterm -geometry 80x66+0+0 -name login

xbindkeys

# Lock after the X server's existing 10-minute idle timeout.  This only locks
# and powers off the display; it does not suspend or pause running processes.
# xss-lock also acquires systemd's delay inhibitor so manual/lid suspend cannot
# complete before the session is safely locked.
xset s 600 0
xset dpms 0 0 0
XSECURELOCK_PAM_SERVICE=xsecurelock \
XSECURELOCK_BLANK_TIMEOUT=10 \
XSECURELOCK_BLANK_DPMS_STATE=off \
xss-lock --transfer-sleep-lock -- xsecurelock &
exec awesome
