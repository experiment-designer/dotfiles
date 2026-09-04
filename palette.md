# Phosphor — the desktop palette

One rule: **structure is near-white hairlines on near-black; state is lime.**
Zero border radius everywhere. Monospace everywhere. Small, dense, defined.

| token   | hex       | use |
|---------|-----------|-----|
| bg0     | `#07080a` | canvas, window/page background |
| bg1     | `#0d0f12` | surface: bars, panels, toolbars |
| bg2     | `#14171c` | raised: hover, inactive tab, popup body |
| bg3     | `#1c2027` | selection, pressed, current line |
| line0   | `#262b33` | quiet separators, unfocused borders |
| line1   | `#e6e9ed` | hard 1px borders (the high-contrast edge) |
| fg0     | `#e6e9ed` | primary text |
| fg1     | `#9aa1ab` | secondary text |
| fg2     | `#5b626c` | muted / disabled |
| lime    | `#c3f542` | focus, active, primary accent (the only loud colour) |
| cyan    | `#5ed3f3` | links, info |
| blue    | `#5b9dff` | secondary info, directories |
| magenta | `#d67cff` | keywords, special |
| amber   | `#ffb340` | warning, constants |
| red     | `#ff4d6d` | error, urgent, delete |

## Terminal ANSI (alacritty / Xresources; htop and nvim inherit these)

| slot | normal    | bright    |
|------|-----------|-----------|
| 0 black   | `#14171c` | `#5b626c` |
| 1 red     | `#ff4d6d` | `#ff7a90` |
| 2 green   | `#c3f542` | `#d9ff70` |
| 3 yellow  | `#ffb340` | `#ffc966` |
| 4 blue    | `#5b9dff` | `#82b6ff` |
| 5 magenta | `#d67cff` | `#e3a0ff` |
| 6 cyan    | `#5ed3f3` | `#8ee3fa` |
| 7 white   | `#c9ced6` | `#f4f6f8` |

background `#07080a`, foreground `#e6e9ed`, cursor `#c3f542` (block, no blink),
selection bg `#1c2027`.

## Type

`InputMono Nerd Font` for everything (terminal 11pt, WM bar 9pt, browser UI 11px).
`InputMonoCondensed Nerd Font` where density matters (browser tabs, htop header).

## Rules

- Borders: 1px `line1` on the thing that must read as a frame (window, urlbar,
  active tab, popups). 1px `line0` for internal separators. Never 2 shades of
  frame on the same element.
- Focus/active: `lime` text or a 2px `lime` edge. Never a lime fill behind
  body text bigger than a badge.
- No gradients, no shadows, no blur, no radius, no transparency.
- Hover: `bg2`. Pressed/selected: `bg3`.
