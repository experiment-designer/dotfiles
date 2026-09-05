# Phosphor start page

`startpage-server` serves `index.html` and `newtab.js` at
`http://127.0.0.1:7777/index.html`. Awesome starts the server at login.
Firefox's homepage and new-tab page both use that URL so Tridactyl can run.

The local Phosphor extension sets Firefox's native `AboutNewTab.newTabURL`
through a small experiment API. This preserves Firefox's empty, focused
address bar and normal Esc behavior without keyboard handlers, redirects,
or duplicate page content. A bundled extension page (including its frames)
cannot run Tridactyl. A redirect to HTTP leaves the URL in the address bar
with the insertion point before it.

This requires Firefox Developer Edition, unsigned local extensions, and
`extensions.experiments.enabled`; the preferences are in `../user.js`.
The API uses an internal Firefox module, so verify it after browser upgrades.

Run `~/dotfiles/bin/build-newtab-xpi` after editing the extension, then install
`../phosphor-newtab.xpi` through about:addons → Install Add-on From File.
Editing the served HTML/JS only requires reloading the page.

Verify after installing and again after restarting Firefox:

- Open a new tab: the address bar is empty and focused; typing replaces it.
- Open another new tab, press Esc, then `f`: link hints appear.
- Repeat with `F`: link hints appear for opening links in a new tab.
- Startup and Home still show the same Phosphor page.
