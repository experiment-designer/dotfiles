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

-- Colors ported from ~/dotfiles/.config/alacritty/alacritty.toml.
config.colors = {
  foreground = '#ffffff',
  background = '#1c1c1c',
  cursor_bg = '#ffffff',
  cursor_fg = '#1c1c1c',
  cursor_border = '#ffffff',
  ansi = {
    '#303030', -- black
    '#d75f00', -- red
    '#005f00', -- green
    '#ffaf00', -- yellow
    '#666666', -- blue
    '#d75f00', -- magenta
    '#87d75f', -- cyan
    '#ffffff', -- white
  },
  brights = {
    '#444444',
    '#ff8700',
    '#87d75f',
    '#ffaf00',
    '#87afff',
    '#ff8700',
    '#87d7ff',
    '#ffffff',
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
