local wezterm = require("wezterm")
local mode_colors = require("modules.utils.mode_colors")

local M = {}

-- Use the unified mode detection instead of duplicating logic
function M.get(window)
	-- ALWAYS check live mode state to catch transient modes like leader_mode
	-- Leader mode is time-sensitive (1000ms timeout) and GLOBAL state may be stale
	local current_mode = mode_colors.get_current_mode(window)

	-- Update GLOBAL state for consistency with other components
	wezterm.GLOBAL.current_mode = current_mode

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
		if mode == "leader_mode" then
			opts.icon = "󰌌" -- nf-md-keyboard
			return display_name
		elseif mode == "tmux_mode" then
			opts.icon = "󰙀" -- nf-md-console
			return display_name
		elseif mode == "wezterm_mode" then
			opts.icon = "" -- nf-md-application
			return display_name
		elseif mode == "resize_mode" then
			opts.icon = "󰩨" -- nf-md-resize
			return display_name
		elseif mode == "copy_mode" then
			opts.icon = "󰆏" -- nf-md-content_copy
			return display_name
		elseif mode == "search_mode" then
			opts.icon = "󰍉" -- nf-md-magnify
			return display_name
		elseif mode == "pane_mode" then
			opts.icon = "󰕰" -- nf-md-view_grid
			return display_name
		else
			return display_name
		end
	end,
}
