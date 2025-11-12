-- This is a helper function that allows us to get the "default"
-- value of a color before we override it.
local function get_initial_color(key, default)
	local overrides = wezterm.config_builder().colors
	return (overrides and overrides[key]) or default or "#3b3b3b"
end

-- 1. Store the original color and define the highlight color
local original_split_color = get_initial_color("split", "#424242")
local resize_highlight_color = "#ff007c" -- A bright pink for feedback
local nav_highlight_color = "#ff007c" -- A bright pink for feedback
