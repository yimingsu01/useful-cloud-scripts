-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 40

-- or, changing the font size and color scheme.
config.font_size = 14

-- function scheme_for_appearance(appearance)
--   if appearance:find "Dark" then
--     return "Google Dark (base16)"
--   else
--     return "Google Light (base16)"
--   end
-- end

config.color_scheme = '3024 (base16)'
-- config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}


return config
