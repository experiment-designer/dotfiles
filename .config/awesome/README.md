# Window audio

Focus a window and press **Mod+A** (Super/Windows+A) to mute its current
playback streams. Press again to unmute. The notification names the affected
audio and reports whether matching used the window or the application.

For Alacritty terminals, Mod+A instead toggles a remembered mute for that
window's notification sounds, including application hooks, terminal bells,
and Awesome urgency cues. This works even when no sound is playing. `blip`
checks the originating `ALACRITTY_WINDOW_ID`/`WINDOWID` (or an explicit second
argument) using `xprop` before playing. Other terminal windows stay audible.
The setting survives Awesome reloads and disappears when the window closes.
This terminal mode controls `blip` notifications, not arbitrary media players
launched inside the terminal.

Requires `python3` and `pactl` (works with this machine's PipeWire PulseAudio
server). Matching uses an explicit X11 window ID first, then the window's
process and its children, preferring matching stream/window titles.
An explicit ID for another window is never selected.

When an app shares audio processes and does not expose matching window titles,
the fallback affects that application's current streams, potentially across
multiple windows. Browser title matching identifies the active tab; background
tabs may require the browser's own tab mute control. Newly created streams are
not tracked, and a silent window with no stream cannot be pre-muted.
