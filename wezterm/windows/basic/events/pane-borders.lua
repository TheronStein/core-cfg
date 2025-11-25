-- This is a helper function that allows us to get the "default"
-- value of a color before we override it.
local function get_initial_color(key, default)
	local overrides = wezterm.config_builder().colors
	return (overrides and overrides[key]) or default or "#3b3b3b"
end

-- 1. Store the original color and define the highlight color
local original_split_color = get_initial_color("split", "'#01F9C6")
local resize_highlight_color = "#ff007c" -- A bright pink for feedback
local nav_highlight_color = "#ff007c" -- A bright pink for feedback

-- 2. Create a reusable action to reset the border and exit the key table
-- This is the crucial part for exiting the mode cleanly.
local function reset_border_and_pop(window, pane)
	local overrides = window:get_config_overrides() or {}
	overrides.colors = overrides.colors or {}
	overrides.colors.split = original_split_color
	window:set_config_overrides(overrides)
	window:perform_action(act.PopKeyTable(), pane)
end
