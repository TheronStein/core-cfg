local wezterm = require("wezterm")
local mode_colors = require("modules.utils.mode_colors")

local M = {}

-- Use the unified mode detection instead of duplicating logic
function M.get(window)
	-- Use GLOBAL state set by mode-colors.lua (single source of truth)
	-- This ensures tabline always shows the same mode as the border color
	local current_mode = wezterm.GLOBAL.current_mode

	-- Fallback to detection if GLOBAL not set yet
	if not current_mode then
		current_mode = mode_colors.get_current_mode(window)
	end

	return current_mode
end

return {
	default_opts = {},
	get = M.get,
	update = function(window, opts)
		local mode = M.get(window)
		-- Convert mode key to display name
		local display_name = mode:gsub("_mode", ""):upper()

		-- Add icons based on mode
		if mode == "tmux_mode" then
			opts.icon = "󰙀"
			return display_name
		elseif mode == "wezterm_mode" then
			opts.icon = " "
			return display_name
		else
			return display_name
		end
	end,
}
