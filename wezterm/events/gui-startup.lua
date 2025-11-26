local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

function M.setup()
	local resurrect = require("resurrect")
	local state_manager = resurrect.state_manager

	-- Configure save directory
	state_manager.change_state_save_dir(paths.WEZTERM_DATA .. "/resurrect")

	-- Enable periodic auto-saving
	state_manager.periodic_save({
		interval_seconds = 60 * 7, -- 7 minutes
		save_workspaces = true,
		save_windows = true,
		save_tabs = true,
	})

	-- Track window counter for unique IDs
	wezterm.GLOBAL.window_counter = wezterm.GLOBAL.window_counter or 0

	-- Handle gui-startup event
	wezterm.on("gui-startup", function(cmd)
		-- Restore previous session first
		local success, err = state_manager.resurrect_on_gui_startup()
		if success then
			wezterm.log_info("Successfully restored previous session")
			return -- Don't spawn new window if restoration succeeded
		else
			wezterm.log_warn("Failed to restore session: " .. tostring(err))
		end

		-- If restoration failed or no saved state, spawn new window
		wezterm.GLOBAL.window_counter = wezterm.GLOBAL.window_counter + 1
		local _, _, window = wezterm.mux.spawn_window(cmd or {})

		if window then
			wezterm.log_info("Window spawned: " .. wezterm.GLOBAL.window_counter)
		end
	end)
end

return M
