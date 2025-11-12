-- WezTerm Notification Handler
-- Add this to your ~/.wezterm.lua or source it from there

local wezterm = require("wezterm")
local module = {}

-- Notification state
local notifications = {}
local notification_id_counter = 0

-- Configuration
local config = {
	max_notifications = 5,
	notification_width = 50,
	position_x = 0, -- Right edge (negative = from right)
	position_y = 100, -- From top
	default_timeout = 5.0,
}

-- Colors based on urgency
local colors = {
	low = "#3b82f6", -- Blue
	normal = "#06b6d4", -- Cyan
	critical = "#ef4444", -- Red
	border = "#6b7280", -- Gray
	text = "#f9fafb", -- White
	muted = "#d1d5db", -- Light gray
	bg = "#1f2937", -- Dark background
}

-- Helper function to wrap text
local function wrap_text(text, width)
	if not text or text == "" then
		return {}
	end

	local words = {}
	for word in text:gmatch("%S+") do
		table.insert(words, word)
	end

	local lines = {}
	local current_line = {}
	local current_length = 0

	for _, word in ipairs(words) do
		local word_len = #word
		if current_length + word_len + #current_line <= width then
			table.insert(current_line, word)
			current_length = current_length + word_len
		else
			if #current_line > 0 then
				table.insert(lines, table.concat(current_line, " "))
			end
			current_line = { word }
			current_length = word_len
		end
	end

	if #current_line > 0 then
		table.insert(lines, table.concat(current_line, " "))
	end

	return #lines > 0 and lines or { "" }
end

-- Create notification element
local function create_notification_element(notif, window)
	local urgency_color = colors[notif.urgency] or colors.normal
	local inner_width = config.notification_width - 4

	local title_lines = wrap_text(notif.title, inner_width)
	local body_lines = notif.body and wrap_text(notif.body, inner_width) or {}

	-- Calculate remaining time
	local now = os.time()
	local age = now - notif.timestamp
	local remaining = math.max(0, notif.timeout - age)

	local elements = {}

	-- Top border
	table.insert(elements, { Foreground = { Color = urgency_color } })
	table.insert(elements, { Text = "╭" .. string.rep("─", config.notification_width - 2) .. "╮" })
	table.insert(elements, { Text = "\n" })

	-- Title
	for _, line in ipairs(title_lines) do
		local padding = config.notification_width - 4 - #line
		table.insert(elements, { Foreground = { Color = urgency_color } })
		table.insert(elements, { Text = "│" })
		table.insert(elements, { Foreground = { Color = colors.text } })
		table.insert(elements, { Text = " " .. line })
		table.insert(elements, { Text = string.rep(" ", padding) .. " " })
		table.insert(elements, { Foreground = { Color = urgency_color } })
		table.insert(elements, { Text = "│" })
		table.insert(elements, { Text = "\n" })
	end

	-- Separator and body if present
	if #body_lines > 0 then
		table.insert(elements, { Foreground = { Color = urgency_color } })
		table.insert(elements, { Text = "├" .. string.rep("─", config.notification_width - 2) .. "┤" })
		table.insert(elements, { Text = "\n" })

		for _, line in ipairs(body_lines) do
			local padding = config.notification_width - 4 - #line
			table.insert(elements, { Foreground = { Color = urgency_color } })
			table.insert(elements, { Text = "│" })
			table.insert(elements, { Foreground = { Color = colors.muted } })
			table.insert(elements, { Text = " " .. line })
			table.insert(elements, { Text = string.rep(" ", padding) .. " " })
			table.insert(elements, { Foreground = { Color = urgency_color } })
			table.insert(elements, { Text = "│" })
			table.insert(elements, { Text = "\n" })
		end
	end

	-- Time remaining
	local time_str = string.format(" %.1fs ", remaining)
	local time_padding = config.notification_width - 4 - #time_str
	table.insert(elements, { Foreground = { Color = urgency_color } })
	table.insert(elements, { Text = "│" })
	table.insert(elements, { Foreground = { Color = colors.border } })
	table.insert(elements, { Text = time_str })
	table.insert(elements, { Text = string.rep(" ", time_padding) .. " " })
	table.insert(elements, { Foreground = { Color = urgency_color } })
	table.insert(elements, { Text = "│" })
	table.insert(elements, { Text = "\n" })

	-- Bottom border
	table.insert(elements, { Foreground = { Color = urgency_color } })
	table.insert(elements, { Text = "╰" .. string.rep("─", config.notification_width - 2) .. "╯" })

	return elements
end

-- Add notification
function module.add_notification(title, body, urgency, timeout)
	urgency = urgency or "normal"
	timeout = timeout or config.default_timeout

	notification_id_counter = notification_id_counter + 1

	local notif = {
		id = notification_id_counter,
		title = title,
		body = body,
		urgency = urgency,
		timeout = timeout,
		timestamp = os.time(),
	}

	table.insert(notifications, notif)

	-- Limit max notifications
	while #notifications > config.max_notifications do
		table.remove(notifications, 1)
	end

	-- Schedule cleanup
	wezterm.time.call_after(timeout, function()
		for i, n in ipairs(notifications) do
			if n.id == notif.id then
				table.remove(notifications, i)
				break
			end
		end
	end)

	-- Trigger update for all windows
	for _, win in ipairs(wezterm.gui.gui_windows()) do
		win:invalidate()
	end
end

-- Render notifications as overlay text with absolute positioning
function module.render_notifications_overlay(window)
	if #notifications == 0 then
		return ""
	end

	local dims = window:get_dimensions()
	local viewport_width = dims.pixel_width / dims.dpi
	local viewport_height = dims.pixel_height / dims.dpi

	-- Calculate position (top-right corner with padding)
	local x_pos = math.floor(viewport_width - config.notification_width - 2)
	local y_pos = config.position_y

	local output = {}

	for i, notif in ipairs(notifications) do
		local urgency_color = colors[notif.urgency] or colors.normal
		local inner_width = config.notification_width - 4

		local title_lines = wrap_text(notif.title, inner_width)
		local body_lines = notif.body and wrap_text(notif.body, inner_width) or {}

		-- Calculate remaining time
		local now = os.time()
		local age = now - notif.timestamp
		local remaining = math.max(0, notif.timeout - age)

		local current_y = y_pos + ((i - 1) * 10) -- Stack notifications vertically

		-- Build notification box
		local lines = {}

		-- Top border
		table.insert(
			lines,
			"\027[38;2;"
				.. string.format(
					"%d;%d;%d",
					tonumber(urgency_color:sub(2, 3), 16),
					tonumber(urgency_color:sub(4, 5), 16),
					tonumber(urgency_color:sub(6, 7), 16)
				)
				.. "m"
				.. "╭"
				.. string.rep("─", config.notification_width - 2)
				.. "╮\027[0m"
		)

		-- Title lines
		for _, line in ipairs(title_lines) do
			local padding = config.notification_width - 4 - #line
			table.insert(lines, "│ " .. line .. string.rep(" ", padding) .. " │")
		end

		-- Body if present
		if #body_lines > 0 then
			table.insert(lines, "├" .. string.rep("─", config.notification_width - 2) .. "┤")
			for _, line in ipairs(body_lines) do
				local padding = config.notification_width - 4 - #line
				table.insert(lines, "│ " .. line .. string.rep(" ", padding) .. " │")
			end
		end

		-- Timer
		local time_str = string.format("%.1fs", remaining)
		local time_padding = config.notification_width - 4 - #time_str
		table.insert(lines, "│ " .. time_str .. string.rep(" ", time_padding) .. " │")

		-- Bottom border
		table.insert(lines, "╰" .. string.rep("─", config.notification_width - 2) .. "╯")

		-- Position and append each line
		for j, line in ipairs(lines) do
			table.insert(output, string.format("\027[%d;%dH%s", current_y + j - 1, x_pos, line))
		end
	end

	return table.concat(output)
end

-- Legacy function for compatibility
function module.render_notifications(window)
	if #notifications == 0 then
		return {}
	end

	local elements = {}
	for _, notif in ipairs(notifications) do
		local notif_elements = create_notification_element(notif, window)
		for _, elem in ipairs(notif_elements) do
			table.insert(elements, elem)
		end
		table.insert(elements, { Text = "\n" })
	end

	return elements
end

-- Setup function to add to your wezterm config
function module.setup(user_config)
	-- Merge user config
	if user_config then
		for k, v in pairs(user_config) do
			config[k] = v
		end
	end

	-- Return config modifications
	return {
		-- Render as window overlay instead of status bar
		window_update = function(window, pane)
			local elements = module.render_notifications(window)
			if #elements > 0 then
				-- Convert elements to plain text for overlay
				local text = wezterm.format(elements)
				window:set_config_overrides({
					window_padding = {
						right = config.notification_width + 4,
					},
				})
			end
		end,

		-- Parse notifications from user vars
		update_status = function(window, pane)
			-- Only process notifications from the active pane to avoid duplicates
			local active_pane = window:active_pane()
			if pane:pane_id() ~= active_pane:pane_id() then
				return
			end

			-- Check for notification user var
			local user_vars = pane:get_user_vars()
			if user_vars.notify_title and user_vars.notify_title ~= "" then
				wezterm.log_info("Adding notification: " .. user_vars.notify_title)
				module.add_notification(
					user_vars.notify_title,
					user_vars.notify_body or "",
					user_vars.notify_urgency or "normal",
					tonumber(user_vars.notify_timeout) or config.default_timeout
				)
			end
		end,
	}
end

return module
