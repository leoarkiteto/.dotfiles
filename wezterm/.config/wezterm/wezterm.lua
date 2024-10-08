local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local config = wezterm.config_builder()
local action = wezterm.action
local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if pane:Get_users_vars().IS_NVIM == "true" then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
			else
				win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
			end
		end),
	}
end

config = {
	automatically_reload_config = true,
	term = "xterm-256color",
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

	-- leader key
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 },
	-- spliting panes
	keys = {
		{
			key = "\\",
			mods = "LEADER",
			action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "-",
			mods = "LEADER",
			action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		split_nav("h"),
		split_nav("j"),
		split_nav("k"),
		split_nav("l"),
		-- adjusting pane size
		{
			key = "h",
			mods = "CTRL|SHIFT",
			action = action.AdjustPaneSize({ "Left", 5 }),
		},
		{
			key = "l",
			mods = "CTRL|SHIFT",
			action = action.AdjustPaneSize({ "Right", 5 }),
		},
		{
			key = "j",
			mods = "CTRL|SHIFT",
			action = action.AdjustPaneSize({ "Down", 5 }),
		},
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = action.AdjustPaneSize({ "Up", 5 }),
		},
		{
			key = "m",
			mods = "LEADER",
			action = action.TogglePaneZoomState,
		},
		{
			key = "[",
			mods = "LEADER",
			action = action.ActivateCopyMode,
		},
		-- tab configuration
		{
			key = "c",
			mods = "LEADER",
			action = action.SpawnTab("CurrentPaneDomain"),
		},
		{
			key = "p",
			mods = "LEADER",
			action = action.ActivateTabRelative(-1),
		},
		{
			key = "n",
			mods = "LEADER",
			action = action.ActivateTabRelative(1),
		},
	},
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = action.ActivateTab(i - 1),
	})
end

return config
