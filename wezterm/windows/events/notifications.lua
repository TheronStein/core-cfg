local wezterm = require("wezterm")
local notifications = require("notifications")

local M = {}

function M.setup()
	-- Set up the notifications module with default config
	local handlers = notifications.setup({
		max_notifications = 5,
		notification_width = 50,
		position_x = -2,
		position_y = 2,
		default_timeout = 5.0,
	})

	-- Register the update-right-status handler
	wezterm.on("update-right-status", function(window, pane)
		local elements = require("notifications").render_notifications(window)
		if #elements > 0 then
			window:set_right_status(wezterm.format(elements))
		else
			window:set_right_status('')
		end
	end)

	-- Register user-var-changed handler
	wezterm.on("user-var-changed", function(window, pane, name, value)
		wezterm.log_info("user-var-changed: " .. name .. " = " .. tostring(value))

		-- Call the notification handler
		if name:match("^notify_") then
			handlers.update_status(window, pane)
		end
	end)
end

return M
