local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 12.0
config.automatically_reload_config = true
config.use_ime = true
config.window_background_opacity = 0.70
config.macos_window_background_blur = 1
config.text_background_opacity = 0.5
config.color_scheme = 'Tokyo Night'

config.font = wezterm.font_with_fallback({
  { family = "Cica", weight = 'Bold' },
  { family = "Cica", assume_emoji_presentation = true, weight = 'Bold' },
})

config.window_decorations = 'RESIZE'
config.enable_tab_bar = false
config.show_tabs_in_tab_bar = true

return config
