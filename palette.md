# Phosphor — the desktop palette

One rule: **structure is near-white hairlines on deep graphite; state is amber.**
Graphite, not black: pure black made the grey text tier dead. Tinted backgrounds
(diff, error) must sit ~8% lighter than bg0, never darker.
Zero border radius everywhere. Monospace everywhere. Small, dense, defined.

| token   | hex       | use |
|---------|-----------|-----|
| bg0     | `#16181d` | canvas, window/page background |
| bg1     | `#1c1f25` | surface: bars, panels, toolbars |
| bg2     | `#23272e` | raised: hover, inactive tab, popup body |
| bg3     | `#2c313a` | selection, pressed, current line |
| line0   | `#3a404a` | quiet separators, unfocused borders |
| line1   | `#e6e9ed` | hard 1px borders (the high-contrast edge) |
| fg0     | `#e6e9ed` | primary text |
| fg1     | `#b7bec8` | secondary text |
| fg2     | `#7b838f` | muted / disabled |
| amber   | `#ffb340` | focus, active, primary accent (the only loud colour); `#ffc966` when hovered/bright |
| cyan    | `#5ed3f3` | links, info |
| blue    | `#5b9dff` | secondary info, directories |
| magenta | `#d67cff` | keywords, special |
| yellow  | `#ffd866` | warning, constants |
| red     | `#ff4d6d` | error, urgent, delete |

## Terminal ANSI (alacritty / Xresources; htop and nvim inherit these)

| slot | normal    | bright    |
|------|-----------|-----------|
| 0 black   | `#23272e` | `#7b838f` |
| 1 red     | `#ff4d6d` | `#ff7a90` |
| 2 green   | `#98c379` | `#b3d98f` |
| 3 yellow  | `#ffb340` | `#ffc966` |
| 4 blue    | `#5b9dff` | `#82b6ff` |
| 5 magenta | `#d67cff` | `#e3a0ff` |
| 6 cyan    | `#5ed3f3` | `#8ee3fa` |
| 7 white   | `#dfe3e8` | `#f4f6f8` |

background `#16181d`, foreground `#e6e9ed`, cursor `#ffb340` (block, no blink),
selection bg `#2c313a`.

## Type

`InputMono Nerd Font` for everything (terminal 11pt, WM bar 9pt, browser UI 11px).
`InputMonoCondensed Nerd Font` where density matters (browser tabs, htop header).

## Rules

- Borders: 1px `line1` on the thing that must read as a frame (window, urlbar,
  active tab, popups). 1px `line0` for internal separators. Never 2 shades of
  frame on the same element.
- Focus/active: `amber` text or a 2px `amber` edge. Never an amber fill behind
  body text bigger than a badge. No neon green anywhere: ANSI green is a calm sage.
- No gradients, no shadows, no blur, no radius, no transparency.
- Hover: `bg2`. Pressed/selected: `bg3`.
