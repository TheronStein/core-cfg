local wezterm = require("wezterm")
local backdrops = require("modules.gui.backdrops")

local M = {}

-- Track last modification time of signal file
local last_signal_time = 0
local signal_file = wezterm.config_dir .. "/.data/.backdrop-refresh"

-- Function to get file modification time
local function get_file_mtime(path)
	local handle = io.popen("stat -c %Y '" .. path .. "' 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return tonumber(result) or 0
	end
	return 0
end

-- Function to refresh backdrops for all windows
local function refresh_all_windows()
	wezterm.log_info("Refreshing backdrops for all windows...")

	-- Reload metadata and image list
	backdrops:reload_metadata()

	-- Get all windows and update their backdrops
	for _, window in ipairs(wezterm.gui.gui_windows()) do
		-- Check if we have images
		if #backdrops.images > 0 then
			-- Pick a random image to ensure visible change
			local new_idx = math.random(1, #backdrops.images)
			backdrops:set_img(window, new_idx)
			wezterm.log_info("Refreshed backdrop for window " .. tostring(window:window_id()) .. " with image " .. new_idx)
		else
			wezterm.log_error("No images found in backdrops directory")
		end
	end
end

function M.setup()
	-- Check for signal file changes periodically
	wezterm.on("update-status", function(window, pane)
		-- Skip if backgrounds are disabled
		if not backdrops:are_backgrounds_enabled() then
			return
		end

		local current_mtime = get_file_mtime(signal_file)

		-- If signal file has been modified since last check
		if current_mtime > last_signal_time then
			last_signal_time = current_mtime

			-- Small delay to ensure all file operations are complete
			wezterm.sleep_ms(100)

			-- Refresh all windows
			refresh_all_windows()
		end
	end)

	-- Also handle manual refresh via custom event
	wezterm.on("backdrop-refresh", function()
		refresh_all_windows()
	end)
end

return M