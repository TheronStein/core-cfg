local wezterm = require("wezterm")
local M = {}

M.setup = function()
	-- Load tmux status exporter
	local tmux_status = require("modules.tmux.status_exporter")

	wezterm.on("update-status", function(window, pane)
		-- Updates left/right status bars (components like mode, workspace, ram, etc.)
		tabline_component.set_status(window)

		-- Export status to tmux if in tmux session
		tmux_status.update(window, pane)
	end)
end
return M
