-- Slideshow controls
table.insert(config.keys, {
	key = "s",
	mods = "CTRL|ALT|SHIFT",
	action = wezterm.action_callback(function(window, pane)
		-- Use the mux-aware script
		local script = home .. "/.core/.sys/configs/wezterm/scripts/yazi-slideshow-mux.sh"
		os.execute("chmod +x " .. script)

		-- Set environment variables for the script
		-- local domain = window:active_domain_name()
		local workspace = window:active_workspace()
		local pane_id = pane:pane_id()
		-- Export context to environment
		local env_cmd =
			string.format("export WEZTERM_WORKSPACE='%s' WEZTERM_PANE='%d'; ", workspace or "default", pane_id)
		pane:send_text(env_cmd .. script .. "\n")
	end),
})
-- Add manual slideshow init command
table.insert(config.keys, {
	key = "s",
	mods = "CTRL|ALT",
	action = wezterm.action_callback(function(window, pane)
		-- Manual slideshow initialization from last config
		local init_file = "/tmp/wezterm-slideshow-init-last.lua"
		local f = io.open(init_file, "r")
		if f then
			local content = f:read("*a")
			f:close()
			-- Execute the initialization
			local func, err = load(content)
			if func then
				local success = func()
				if success then
					window:toast_notification("Slideshow", "Initialized successfully!", nil, 3000)
					-- Trigger reload
					window:reload_configuration()
				else
					window:toast_notification("Slideshow", "Initialization failed", nil, 3000)
				end
			else
				window:toast_notification("Slideshow", "Error: " .. tostring(err), nil, 3000)
			end
		else
			window:toast_notification("Slideshow", "No pending initialization found", nil, 3000)
		end
	end),
})
-- Show slideshow info
table.insert(config.keys, {
	key = "i",
	mods = "CTRL|ALT",
	action = wezterm.action_callback(function(window, pane)
		local session_name = slideshow_integration.get_session_name(window:active_workspace())
		local info = slideshow.get_info(session_name)
		if info then
			local msg = string.format(
				"Slideshow Info:\nDirectory: %s\nImage %d of %d\nInterval: %ds\nStatus: %s",
				info.directory,
				info.current_index,
				info.total_images,
				info.interval,
				info.paused and "Paused" or "Playing"
			)
			window:toast_notification("Slideshow", msg, nil, 5000)
		else
			window:toast_notification("Slideshow", "No active slideshow", nil, 2000)
		end
	end),
})


