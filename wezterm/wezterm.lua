local wezterm = require("wezterm")
return {
	adjust_window_size_when_changing_font_size = false,
	-- color_scheme = "termnial.sexy",
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 16.0,
	font = wezterm.font("JetBrains Mono"),
	-- macos_window_background_blur = 40,
	-- macos_window_background_blur = 100,

	-- window_background_image = "/Users/johnsouza/Documents/Wallpaper/Café Lo-fi 1920x1080.jpeg",
	-- window_background_image_hsb = {
	-- 	brightness = 0.01,
	-- },
	-- window_background_opacity = 0.92,
	window_background_opacity = 0.95,
	-- window_background_opacity = 0.20,
	window_decorations = "RESIZE",
	keys = {
		{
			key = "q",
			mods = "CTRL",
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = "'",
			mods = "CTRL",
			action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
		},
	},
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
}
