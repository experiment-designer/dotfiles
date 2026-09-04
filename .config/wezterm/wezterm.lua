local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- BiDi / RTL: makes Hebrew (and Arabic) render right-to-left correctly.
-- The reason we migrated off alacritty — it silently renders LTR only.
config.bidi_enabled = true
config.bidi_direction = 'LeftToRight'

-- Primary: Adwaita Mono — what the alacritty config was actually rendering
-- (fontconfig resolved its non-existent "DejaVu Sans Mono for Powerline"
-- to Adwaita Mono via the monospace fallback chain). Keeps visual parity.
-- Hebrew falls through to Noto Sans Hebrew.
config.font = wezterm.font_with_fallback {
  'Adwaita Mono',
  'Noto Sans Hebrew',
  'Noto Color Emoji',
}
config.font_size = 11.0

-- Phosphor palette — see ~/dotfiles/palette.md (mirrors alacritty.toml).
config.colors = {
  foreground = '#f4f6f8',
  background = '#16181d',
  cursor_bg = '#ffb340',
  cursor_fg = '#16181d',
  cursor_border = '#ffb340',
  selection_bg = '#2c313a',
  selection_fg = 'none',
  split = '#e6e9ed',
  ansi = {
    '#23272e', -- black
    '#ff4d6d', -- red
    '#98c379', -- green
    '#ffb340', -- yellow
    '#5b9dff', -- blue
    '#d67cff', -- magenta
    '#5ed3f3', -- cyan
    '#dfe3e8', -- white
  },
  brights = {
    '#7b838f',
    '#ff7a90',
    '#b3d98f',
    '#ffc966',
    '#82b6ff',
    '#e3a0ff',
    '#8ee3fa',
    '#f4f6f8',
  },
}

-- Window chrome + padding match alacritty.
config.window_decorations = 'NONE'
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_background_opacity = 1.0
config.default_cursor_style = 'SteadyBlock'
config.enable_tab_bar = false

-- Clipboard: alacritty had `selection.save_to_clipboard = true`.
config.selection_word_boundary = ' \t\n{}[]()"\',;:'

-- Keybind parity with alacritty: Shift+Enter → ESC + CR (\u001B\r),
-- used by some REPLs to distinguish newline from submit.
config.keys = {
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\x1b\r',
  },
}

return config
