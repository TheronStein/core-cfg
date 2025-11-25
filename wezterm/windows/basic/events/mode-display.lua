local wezterm = require("wezterm")
local M = {}
local current_mode = "CORE"

-- Public function to get current mode
function M.get_current_mode()
	return current_mode
end

-- Function to update mode and refresh tabline
function M.update_mode_display(window, mode_name)
	current_mode = mode_name
	window:perform_action(wezterm.action.EmitEvent("refresh-tabline"), nil)
end

function M.init()
	-- Initialize GLOBAL state
	wezterm.GLOBAL.current_mode = "CORE"
	wezterm.GLOBAL.leader_active = false
	wezterm.on("update-mode", function(window, pane, mode_name)
		M.update_mode_display(window, mode_name)
	end)
end

function M.setup()
	wezterm.on("refresh-tabline", function(window, pane)
		window:set_right_status(wezterm.format({
			{ Text = "MODE: " .. current_mode .. " " },
		}))
	end)
end
