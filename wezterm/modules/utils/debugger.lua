local wezterm = require("wezterm")
local M = {}

M.DEBUG = {}

-- Logging helpers
function M.debug_log(category, message, data)
	if not M.DEBUG[category] then
		return
	end
	local log_msg = string.format("[%s] %s", category, message)
	if data then
		log_msg = log_msg .. " | Data: " .. wezterm.to_string(data)
	end
	wezterm.log_info(log_msg)
end

function M.debug_loggdebug_notify(window, category, title, message, timeout)
	if not M.DEBUG[category] then
		return
	end
	if not window then
		return
	end
	timeout = timeout or 2000
	window:toast_notification(title, message, nil, timeout)
end
-- Custom logger functions (use these in your config or event handlers)
function M.log_key_event(event)
	wezterm.log_info("Key Event: " .. wezterm.inspect(event)) -- Logs to INFO level (visible in debug overlay)
end

-- require("events.log_key_event"

return M
