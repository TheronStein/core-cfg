local wezterm = require("wezterm")
local home = os.getenv("HOME")

return {
	-- Tab bar
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = false,
	tab_max_width = 20,
	switch_to_last_active_tab_when_closing_tab = true,
	show_new_tab_button_in_tab_bar = false, -- Hide the "+" button

	-- Cursor
	default_cursor_style = "BlinkingBlock",
	cursor_blink_rate = 800,
	cursor_blink_ease_in = "Linear",
	cursor_blink_ease_out = "Linear",
	force_reverse_video_cursor = true,
	line_height = 1.0,

	window_decorations = "NONE",
	enable_scroll_bar = false, -- Reduces rendering overhead
	-- font_size = 14.0,
	font_size = 14.0,
	adjust_window_size_when_changing_font_size = false,
	window_padding = {
		left = 2,
		right = 2,
		top = 2,
		bottom = 2,
	},
	window_content_alignment = {
		horizontal = "Left",
		vertical = "Bottom",
	},

	color_scheme = "Catppuccin Mocha",

	-- Inactive anes: Dim and desaturate to highlight active
	inactive_pane_hsb = {
		hue = 1.0,
		-- saturation = 0.7,
		-- brightness = 0.6,
	},

	-- Pane borders: Uniform turquoise
	colors = {
		-- Tab bar background (matches your theme's base color)
		tab_bar = {
			background = "#292D3E",
		},
		-- The default text color
		-- foreground = 'silver',
		-- foreground = "#b4befe",
		-- foreground = "#81f8bf",
		-- The default background color
		-- background = '',
		-- #B0E0E6
		-- #9deefd
		-- #89dceb
		-- #94e2d5
		-- #19dfcf
		-- #19dfcf
		-- #48D1CC
		-- #7FCDCD
		-- #04d1f9
		-- #4fe0fc
		-- #ccfce5
		-- #acf200
		-- #81f8bf
		-- #37f499
		-- #01F9C6
		-- #4ffced
		-- #04F9F8
		-- #16E2F5
		-- Overrides the cell background color when the current cell is occupied by the
		-- cursor and the cursor style is set to Block
		cursor_bg = "#4ffced",
		-- Overrides the text color when the current cell is occupied by the cursor
		cursor_fg = "black",
		-- Specifies the border color of the cursor when the cursor style is set to Block,
		-- or the color of the vertical or horizontal bar when the cursor style is set to
		-- Bar or Underline.
		cursor_border = "#987afb",
		selection_fg = "#01f9c6",
		selection_bg = "#033E3E", --"#C4E8E8",
		scrollbar_thumb = "#222222",
		split = "#01F9C6", -- Bright green for visibility
		-- copy_mode_active_highlight_fg = { Color = "Black" },
		-- copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
		-- copy_mode_inactive_highlight_fg = { Color = "" },
	},
	-- #483D8B
	-- #7F38EC
	-- #008B8B
	-- #4D908E
	-- default_cursor_style = "BlinkingBar"
	-- cursor_blink_rate = 500
	-- window_decorations = "NONE"
	-- cursor_blink_ease_in = "Constant"
	-- cursor_blink_ease_out = "Constant"
	-- force_reverse_video_cursor = true

	-- cursor_blink_ease_in = "Linear"
	-- cursor_blink_ease_out = "Linear"
	-- config.cursor_blink_ease_in = "Constant"
	-- config.cursor_blink_ease_out = "Constant"

	-- visual_bell = {
	-- 	fade_in_function = "EaseIn",
	-- 	fade_in_duration_ms = 250,
	-- 	fade_out_function = "EaseOut",
	-- 	fade_out_duration_ms = 250,
	-- 	target = "CursorColor",
	-- },

	-- Window
	-- color_scheme = "Catppuccin Mocha",

	-- window_frame = {
	--   border_left_width = '0.5cell',
	--   border_right_width = '0.5cell',
	--   border_bottom_height = '0.25cell',
	--   border_top_height = '0.25cell',
	--   border_left_color = '#01F9C6',
	--   border_right_color = '#01F9C6',
	--   border_bottom_color = '#01F9C6',
	--   border_top_color = '#01F9C6',
	-- }

	-- Background (commented out to let dynamic backdrop system work)
	-- background = {
	-- 	{
	-- 		source = {
	-- 			File = home .. "/Pictures/wallpapers/default.jpg",
	-- 			-- File = home .. "/.core/.sys/configs/wezterm/backdrops/16__ORDER__.jpg", -- "/Pictures/wallpapers/default.jpg",
	-- 		},
	-- 		opacity = 0.85,
	-- 		hsb = {
	-- 			brightness = 0.3,
	-- 			saturation = 0.8,
	-- 		},
	-- 	},
	-- 	{
	-- 		source = {
	-- 			Gradient = {
	-- 				orientation = { Linear = { angle = -90.0 } },
	-- 				colors = { "#EEBD89", "#D13ABD" },
	-- 			},
	-- 		},
	-- 		opacity = 0.05,
	-- 		width = "100%",
	-- 		height = "100%",
	-- 	},
	-- },
}
