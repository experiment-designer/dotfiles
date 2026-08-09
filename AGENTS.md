# Dotfiles repo — how to make config changes persistent

This repo is the single source of truth for this machine's configuration.
Live config files are **symlinks into this repo**, so editing a tracked file
here changes the live system immediately — and committing it makes it
persistent. There are no separate "repo copy" and "real copy" to keep in sync.

## Rule 1: edit the repo file, never the home path

For any managed path, edit the file inside `~/dotfiles`. The symlink makes it
live instantly. Never copy files between `~` and the repo by hand.

Managed paths are declared in `dotfiles-manifest.sh` (arrays:
`HOME_DOTFILES`, `CONFIG_DIRS`, `FIREFOX_PROFILE_FILES`, `USER_SCRIPTS`,
`XORG_CONFIGS`, `UDEV_RULES`, `PAM_CONFIGS`, `SYSTEM_SLEEP_SCRIPTS`,
`SYSTEMD_LOGIND_CONFIGS`). Read it
before deciding where a change goes.

| Change to…                        | Edit…                                   | Takes effect |
|-----------------------------------|------------------------------------------|--------------|
| shell, vim, X resources, git      | `~/dotfiles/.zshrc`, `.vimrc`, …         | next shell / immediately |
| an app in `CONFIG_DIRS` (awesome, nvim, alacritty, wezterm, powerline) | `~/dotfiles/.config/<app>/…` | app reload (awesome: `Mod4+Ctrl+r`) |
| Firefox Developer Edition         | `~/dotfiles/.config/firefox/…`           | Firefox restart |
| user scripts                      | `~/dotfiles/BMT.sh`, `bin/…`             | immediately |
| X11 / udev system config          | repo file, then rerun `./dotfiles-install.sh` (copies to `/etc`, needs sudo) | after install + device replug/X restart |
| PAM service config                | `~/dotfiles/pam.d/…`, then rerun `./dotfiles-install.sh` (copies to `/etc`, needs sudo) | after install |
| system sleep hooks                | `~/dotfiles/system-sleep/…`, then rerun `./dotfiles-install.sh` (copies to `/usr/lib/systemd/system-sleep`, needs sudo) | after install |
| systemd-logind config             | `~/dotfiles/systemd/logind.conf.d/…`, then rerun `./dotfiles-install.sh` (copies to `/etc/systemd/logind.conf.d`, needs sudo) | after install + logind reload/restart |

System files (`/etc` and the systemd sleep-hook directory under `/usr/lib`) are
the one exception to the symlink rule: they are installed as **copies**, so
after editing the repo file you must rerun `./dotfiles-install.sh` (or
`sudo install` the single file) to deploy.

## Rule 2: new config files need a manifest entry

If the user asks to manage something not yet tracked:

1. Move/copy the real file into the repo (`~/dotfiles/.config/<app>/` etc.).
2. Add it to the right array in `dotfiles-manifest.sh`.
3. Run `./dotfiles-install.sh` (or `--user-only`) — it backs up the original
   to `*.pre-dotfiles` and creates the symlink.
4. Verify with `./dotfiles-setup.sh --check`.

Adding a file inside an already-managed `CONFIG_DIRS` directory needs no
manifest change — the whole directory is one symlink.

## Rule 3: finish with a commit

A change is persistent only once committed. After verifying the change works:

```sh
git add <files> && git commit && git push
```

Commit only the files related to the change; leave unrelated dirty files alone.

## Scripts

- `./dotfiles-install.sh [--user-only]` — deploy: symlink repo → home, copy
  system files to `/etc`. Idempotent; backs up anything it replaces.
- `./dotfiles-setup.sh` — collect: copy live files → repo for paths that are
  not yet symlinked (bootstrap/migration only; a no-op for linked paths).
  Refuses to run if the repo has uncommitted changes (`--force` overrides).
- `./dotfiles-setup.sh --check` — audit: reports managed paths that are
  missing/unlinked/diverged, and lists unmanaged `~/.config` dirs and
  `~/.local/bin` scripts as candidates. Run this when unsure of the state.

## Hard rules

- **Never commit secrets.** API keys in `.zshrc` stay as `YOUR_KEY_HERE`
  placeholders; real keys live in an untracked file. `dotfiles-setup.sh`
  enforces this for known keys, but check anything new you track.
- Never edit through the home-path symlink target confusion: `~/.config/awesome/rc.lua`
  and `~/dotfiles/.config/awesome/rc.lua` are the same file — fine — but if
  `--check` reports "copy, DIFFERS", reconcile before editing (diff both, keep
  the intended version, then link).
- Verify before claiming done: config syntax check where possible
  (`luac -p` for awesome, `bash -n` for shell scripts), then reload the app.
