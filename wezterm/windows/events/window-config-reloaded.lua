local wezterm = require("wezterm")

local M = {}

-- Track last cycle time per window
local last_cycle = {}
local CYCLE_INTERVAL = 300 -- seconds
local CONFIG_RELOAD = 1

M.setup = function()
	wezterm.on("window-config-reloaded", function(window, pane)
		local window_id = tostring(window:window_id())

		-- Set initial backdrop for new window
		if not last_cycle[window_id] then
			backdrops:set_img(window, 1)
			wezterm.log_info("Initial backdrop set for window " .. window_id)
		end
		-- window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
	end)
end

return M
