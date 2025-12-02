local wezterm = require("wezterm")

local M = {}

function M.get(window)
	-- Check if leader is active first
	if window:leader_is_active() then
		return "leader_mode"
	end

	-- Check for special key table modes (copy, resize, etc.)
	local key_table = window:active_key_table()
	if key_table and key_table:find("_mode$") then
		return key_table
	end

	-- Default: show context (TMUX or WEZTERM)
	local context = wezterm.GLOBAL.leader_context or "wezterm"

	if context == "tmux" then
		return "tmux_mode"
	else
		return "wezterm_mode"
	end
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
