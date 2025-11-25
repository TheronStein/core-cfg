local wezterm = require 'wezterm'

-- Optional: Set update interval to 1 second (default anyway)
local M = {} 
config.status_update_interval = 1000

function M.setup()

  -- Listen for leader activation
  wezterm.on("leader-activated", function()
    debug_log("LEADER_ACTIVATED", "Leader key pressed (Ctrl+Tab)")
    wezterm.GLOBAL.current_mode = "LEADER"
    wezterm.GLOBAL.leader_active = true
      window:toast_notification('wezterm', 'LEADER MODE ACTIVATED' .. window_id, nil, 4000)
  end)

  -- Set up event handlers for mode changes
  wezterm.on("update-right-status", function(window, pane)

    end
  end)

	wezterm.on("update-status", function(window, pane)
    local effective_config = window:effective_config()
		local window_id = tostring(window:window_id())
		local now = os.time()

	-- Check if leader is active
	local leader_active = window:leader_is_active()

	-- Check if there's an active key table (mode)
	local key_table = window:active_key_table()

	-- Determine what mode to display
	if key_table then
		-- We're in a mode, keep displaying that mode
		local mode_name = key_table:upper()
		if mode_name:find("_MODE") then
			mode_name = mode_name:gsub("_MODE", "")
		end
		if wezterm.GLOBAL.current_mode ~= mode_name then
			wezterm.GLOBAL.current_mode = mode_name
			wezterm.GLOBAL.leader_active = false
			debug_log("MODE_TRANSITIONS", "Active key table: " .. mode_name)
		end
	elseif leader_active then
		-- Leader is active but no mode yet
		if wezterm.GLOBAL.current_mode ~= "LEADER" then
			wezterm.GLOBAL.current_mode = "LEADER"
			wezterm.GLOBAL.leader_active = true
			debug_log("LEADER_ACTIVATED", "Leader key is active")
		end
	else
		-- No leader, no mode, we're in CORE
		if wezterm.GLOBAL.current_mode ~= "CORE" then
			wezterm.GLOBAL.current_mode = "CORE"
			wezterm.GLOBAL.leader_active = false
			debug_log("MODE_TRANSITIONS", "Returning to CORE")
		end
	local meta = pane:get_metadata() or {}
	local domain_name = pane:get_domain_name()

	local status = string.format("Domain: %s", domain_name)

	-- Also show if tardy (lagging)
	if meta.is_tardy then
		local secs = meta.since_last_response_ms / 1000.0
		status = status .. string.format(" | tardy: %5.1fs⏳", secs)
	end
	
  -- Format and set the status (use wezterm.format for colors/styles if desired)
  local status = wezterm.format {
    { Text = string.format('Domain: %s | EGL: %s | Wayland: %s | FPS (max): %d | Frontend: %s | GPU: %s | RAM: %s | CPU: %s',
      domain, egl, wayland, fps, frontend, gpu_info, ram, cpu) },
    }

	window:set_right_status(status)

		-- Initialize if first run
		if not last_cycle[window_id] then
			last_cycle[window_id] = now
			-- Set initial backdrop
			backdrops:set_img(window, 1)
			return
		end

		-- Check if interval has passed
		if now - last_cycle[window_id] >= CYCLE_INTERVAL then
			backdrops:cycle_forward(window)
			last_cycle[window_id] = now
			wezterm.log_info("Backdrop cycled for window " .. window_id)
		end

  end)
end

return M
