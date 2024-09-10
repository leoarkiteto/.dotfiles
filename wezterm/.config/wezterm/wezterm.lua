local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disaable the title bar but enalble resizable border
	default_cursor_style = "BlinkingBar",
	color_scheme = "One Dark (Gogh)",
	font = wezterm.font("VictorMono Nerd Font", { weight = "Bold" }),
	font_size = 15,
	window_padding = {
		left = 8,
		right = 0,
		top = 8,
		bottom = 8,
	},
}

return config
