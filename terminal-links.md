# Terminal links

Alacritty and WezTerm underline URLs, labeled OSC 8 hyperlinks, and absolute
file paths on hover. Use **Ctrl+Shift+click** inside mouse-capturing apps such
as Claude Code and Codex. Ordinary clicks work when the app is not capturing
the mouse. **Ctrl+Shift+O** shows keyboard labels for visible links.

All open through `bin/open-link` and `xdg-open`: web URLs use the default
browser; local files use their desktop file association. HTML and PDF are
currently associated with Firefox. Existing local paths with `:line` or
`:line:column` suffixes open the file without those editor coordinates.

- **tmux:** OSC 8 support is enabled for Alacritty and WezTerm. New servers
  load `.tmux.conf`; existing servers can run `tmux source-file ~/.tmux.conf`
  and reattach their clients.
- **XTerm:** select the visible URL/path, then **Ctrl+Shift+O**. Hold Shift
  while selecting inside a mouse-capturing app. XTerm does not provide
  automatic URL hover highlighting or labeled OSC 8 links.
- **URxvt:** the existing matcher underlines URLs and opens them on click.
  URxvt is configured but is not currently installed.

Alacritty and WezTerm reload their config automatically. X resources apply
to new windows after `xrdb -merge ~/dotfiles/.Xresources`.

The terminal must receive either a visible URL/path or an OSC 8 target.
Plain descriptive text with no target cannot be made clickable by settings.
Codex's `file_opener` chooses editor URI schemes, not the web browser; it is
unchanged. No Claude Code or Codex output-rewriting wrapper is needed.

References: [Alacritty hints](https://alacritty.org/config-alacritty.html#hints),
[WezTerm mouse capture](https://wezterm.org/config/mouse.html),
[XTerm actions](https://invisible-island.net/xterm/manpage/xterm.html),
[Codex configuration](https://developers.openai.com/codex/config-reference/).
