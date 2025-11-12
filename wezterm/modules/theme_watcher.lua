-- ~/.core/cfg/wezterm/util/theme_watcher.lua
-- Live theme preview watcher for the fzf theme browser

local wezterm = require("wezterm")
local debug_config = require("config.debug")
local DEBUG = debug_config.debug_mods_themes or debug_config.debug_all

local M = {}

-- Active watchers per window
M.active_watchers = {}

-- Get preview file path for current session/workspace
function M.get_preview_file(workspace_name)
	local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"

	-- If workspace name provided, use it
	if workspace_name and workspace_name ~= "" then
		return string.format("%s/wezterm_theme_preview_%s.txt", runtime_dir, workspace_name)
	end

	-- Try to get tmux session name as fallback
	local session = nil
	local success, stdout = wezterm.run_child_process({
		"tmux",
		"display-message",
		"-p",
		"#S",
	})
	if success and stdout:match("%S") then
		session = stdout:gsub("%s+", "")
	end

	-- Build preview file path
	if session then
		return string.format("%s/wezterm_theme_preview_%s.txt", runtime_dir, session)
	else
		return runtime_dir .. "/wezterm_theme_preview.txt"
	end
end

-- Start watching for theme changes
function M.start_watcher(window, workspace_name)
	if not window then
		return
	end

	local window_id = tostring(window:window_id())

	-- Get workspace if not provided
	if not workspace_name then
		workspace_name = window:active_workspace()
	end

	-- Don't start multiple watchers for same window
	if M.active_watchers[window_id] then
		if DEBUG then
			wezterm.log_info("Theme watcher already active for window " .. window_id)
		end
		return
	end

	M.active_watchers[window_id] = true

	local preview_file = M.get_preview_file(workspace_name)
	if DEBUG then
		wezterm.log_info("Theme watcher starting for workspace: " .. (workspace_name or "default"))
		wezterm.log_info("Preview file: " .. preview_file)
	end
	local last_theme = nil
	local original_theme = nil
	local domain_theme = nil

	-- Get current theme as original
	local overrides = window:get_config_overrides() or {}
	original_theme = overrides.color_scheme

	-- Store the domain's default theme
	local pane = nil
	local ok_pane, active_pane = pcall(function()
		return window:active_pane()
	end)
	if ok_pane and active_pane then
		pane = active_pane
	end

	if pane then
		local ok_domain, domain = pcall(function()
			return pane:get_domain_name()
		end)
		if ok_domain and domain and domain ~= "local" then
			local mux_name = domain:match("^([^:]+)") or domain
			-- Load config_hierarchy to get domain defaults
			local config_hierarchy = require("util.config_hierarchy")
			if config_hierarchy.domain_defaults and config_hierarchy.domain_defaults[mux_name] then
				domain_theme = config_hierarchy.domain_defaults[mux_name].color_scheme
			end
		end
	end

	local function poll()
		-- Check if window still exists
		if not M.active_watchers[window_id] then
			return
		end

		-- Read preview file
		local f = io.open(preview_file, "r")
		if f then
			local theme = f:read("*line")
			f:close()

			if theme and theme ~= "" and theme ~= "INIT" then
				-- Clean up theme name (remove any extra whitespace)
				theme = theme:gsub("^%s+", ""):gsub("%s+$", "")

				-- Apply theme if it changed
				if theme ~= last_theme then
					last_theme = theme

					local overrides = window:get_config_overrides() or {}

					-- Handle special commands
					if theme == "CANCEL" then
						-- Reset to original theme (what was there before preview started)
						if original_theme then
							overrides.color_scheme = original_theme
						else
							overrides.color_scheme = domain_theme
						end
					elseif theme == "RESET" then
						-- Reset to domain default
						overrides.color_scheme = domain_theme
					else
						-- Apply new theme for preview
						overrides.color_scheme = theme
					end

					window:set_config_overrides(overrides)
					if DEBUG then
						wezterm.log_info("Preview theme: " .. theme)
					end
				end
			end
		end

		-- Continue polling with fast refresh for smooth preview
		wezterm.time.call_after(0.05, poll)
	end

	-- Start polling
	poll()

	if DEBUG then
		wezterm.log_info("Started theme watcher for " .. preview_file)
	end
end

-- Stop watcher for a window
function M.stop_watcher(window)
	if not window then
		return
	end
	local window_id = tostring(window:window_id())
	M.active_watchers[window_id] = nil
	if DEBUG then
		wezterm.log_info("Stopped theme watcher for window " .. window_id)
	end
end

-- Check if watcher is active for a window
function M.is_active(window)
	if not window then
		return false
	end
	local window_id = tostring(window:window_id())
	return M.active_watchers[window_id] == true
end

-- Check if theme browser is running
function M.is_browser_active()
	local preview_file = M.get_preview_file()
	local f = io.open(preview_file, "r")
	if f then
		local content = f:read("*line")
		f:close()
		-- Check if file was recently modified (within last 5 seconds)
		local handle = io.popen('stat -c %Y "' .. preview_file .. '" 2>/dev/null')
		if handle then
			local mtime = handle:read("*a")
			handle:close()
			if mtime then
				local age = os.time() - tonumber(mtime)
				return age < 5
			end
		end
	end
	return false
end

-- Clean up preview file
function M.cleanup()
	local preview_file = M.get_preview_file()
	os.remove(preview_file)
end

return M
