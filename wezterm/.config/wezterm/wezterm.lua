local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disaable the title bar but enalble resizable border
	window_frame = {
		font = wezterm.font("VictorMono Nerd Font", { weight = "Bold" }),
		font_size = 14,
	},
	default_cursor_style = "BlinkingBar",
	hide_tab_bar_if_only_one_tab = true,
	color_scheme = "One Dark (Gogh)",
	font = wezterm.font("VictorMono Nerd Font", { weight = "Bold" }),
	font_size = 17,
	bold_brightens_ansi_colors = true,
	window_padding = {
		left = 8,
		right = 8,
		top = 8,
		bottom = 8,
	},
}

return config
