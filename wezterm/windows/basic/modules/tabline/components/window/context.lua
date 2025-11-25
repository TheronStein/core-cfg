local wezterm = require("wezterm")

local M = {}

function M.get(window)
	return wezterm.GLOBAL.leader_context or "wezterm"
end

return {
	default_opts = {},
	update = function(window, opts)
		-- Get the current context from GLOBAL state
		local context = M.get(window)

		-- Display with appropriate icon
		if context == "tmux" then
			return "󰙀 TMUX" -- nf-md-console icon
		else
			return " WEZTERM" -- nf-md-application icon
		end
	end,
}
