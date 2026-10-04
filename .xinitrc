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

# Lock after one hour of inactivity.  This only locks
# and powers off the display; it does not suspend or pause running processes.
# xss-lock also acquires systemd's delay inhibitor so manual/lid suspend cannot
# complete before the session is safely locked.
# Steam's client zeroes this timeout on start (XSetScreenSaver) and never
# restores it, so check periodically and repair changed settings. Setting even
# unchanged values rearms Xorg's saver countdown, which would prevent locking.
# The loop exits with the X server once xset fails.
(
    while saver_settings=$(LC_ALL=C xset q); do
        if [ "$(printf '%s\n' "$saver_settings" |
            awk '$1 == "timeout:" && $3 == "cycle:" { print $2, $4 }')" != "3600 0" ]; then
            xset s 3600 0 || break
        fi
        sleep 300
    done
) &
xset dpms 0 0 0
# The idle password prompt closes quickly after fingerprint fallback so a new
# keypress starts a fresh fingerprint attempt rather than remaining password-only.
XSECURELOCK_AUTH_TIMEOUT=15 \
XSECURELOCK_PAM_SERVICE=xsecurelock \
XSECURELOCK_BLANK_TIMEOUT=10 \
XSECURELOCK_BLANK_DPMS_STATE=off \
xss-lock --transfer-sleep-lock -- xsecurelock &
exec awesome
