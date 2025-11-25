local wezterm = require("wezterm")
local tabline = require("modules.gui.tabline")
local notifications = require("notifications")
local debug_config = require("config.debug")

local M = {}

function M.setup()
wezterm.on("user-var-changed", function(window, pane, name, value)
	if debug_config.is_enabled("debug_events_user_var") then
		wezterm.log_info("[EVENT:USER_VAR] " .. name .. " = " .. tostring(value))
	end

	-- Handle tmux navigation requests
	if name == "navigate_wezterm" then
		-- Decode base64 direction value
		local direction = wezterm.base64_decode(value)
		if debug_config.is_enabled("debug_events_user_var") then
			wezterm.log_info("[EVENT:USER_VAR] Navigating WezTerm pane: " .. direction)
		end
		window:perform_action(wezterm.action.ActivatePaneDirection(direction), pane)
		return
	end

	if tabline and tabline.refresh then
		tabline.refresh(window, pane)
	end
end)
end

return M
