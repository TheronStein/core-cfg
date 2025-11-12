local wezterm = require("wezterm")
local tabline = require("modules.gui.tabline")
local notifications = require("notifications")

local M = {}

function M.setup()
wezterm.on("user-var-changed", function(window, pane, name, value)
	wezterm.log_info("user-var changed: " .. name .. " = " .. tostring(value))

	-- Handle tmux navigation requests
	if name == "navigate_wezterm" then
		-- Decode base64 direction value
		local direction = wezterm.base64_decode(value)
		wezterm.log_info("Navigating WezTerm pane: " .. direction)
		window:perform_action(wezterm.action.ActivatePaneDirection(direction), pane)
		return
	end

	if tabline and tabline.refresh then
		tabline.refresh(window, pane)
	end
end)
end

return M
