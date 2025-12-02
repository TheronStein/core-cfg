-- ~/.core/.sys/cfg/wezterm/events/workspace-auto-save.lua
-- Automatic workspace state persistence - ONLY for custom workspaces

local wezterm = require("wezterm")

local M = {}

-- Track which workspaces have auto-save enabled
local auto_save_enabled = {}
local auto_save_timers = {}
local dirty_workspaces = {}
local next_save_time = {} -- Track when next save will happen

-- Configuration
local AUTO_SAVE_INTERVAL = 300 -- 5 minutes (adjustable)

-- Check if workspace should have auto-save (not "default")
local function is_custom_workspace(workspace_name)
	return workspace_name and workspace_name ~= "" and workspace_name ~= "default"
end

-- Check if auto-save is enabled for workspace
local function is_auto_save_enabled(workspace_name)
	return auto_save_enabled[workspace_name] == true
end

-- Get time remaining until next save (in seconds)
function M.get_time_until_save(workspace_name)
	if not is_custom_workspace(workspace_name) then
		return nil
	end

	if not is_auto_save_enabled(workspace_name) then
		return nil
	end

	local next_time = next_save_time[workspace_name]
	if not next_time then
		return nil
	end

	local now = os.time()
	local remaining = next_time - now
	return remaining > 0 and remaining or 0
end

-- Enable auto-save for a workspace
function M.enable_auto_save(workspace_name)
	if is_custom_workspace(workspace_name) then
		auto_save_enabled[workspace_name] = true
		wezterm.log_info("Auto-save enabled for workspace: " .. workspace_name)
	end
end

-- Disable auto-save for a workspace
function M.disable_auto_save(workspace_name)
	auto_save_enabled[workspace_name] = nil
	wezterm.log_info("Auto-save disabled for workspace: " .. workspace_name)
end

-- Mark workspace as dirty (needs save)
local function mark_dirty(workspace_name)
	if is_auto_save_enabled(workspace_name) then
		dirty_workspaces[workspace_name] = true
		wezterm.log_info("Workspace marked dirty: " .. workspace_name)
	end
end

-- Check if workspace is dirty
local function is_dirty(workspace_name)
	return dirty_workspaces[workspace_name] == true
end

-- Clear dirty flag
local function clear_dirty(workspace_name)
	dirty_workspaces[workspace_name] = nil
end

-- Save workspace state
local function save_workspace_state(window, workspace_name)
	-- Only save if enabled and dirty
	if not is_auto_save_enabled(workspace_name) then
		return
	end

	if not is_dirty(workspace_name) then
		return
	end

	wezterm.log_info("Auto-saving workspace: " .. workspace_name)

	-- Save workspace metadata
	local ok, workspace_metadata = pcall(require, "modules.sessions.workspace_metadata")
	if ok then
		workspace_metadata.sync_icon_from_global(workspace_name)
	end

	-- Save Neovim sessions if available
	local ok_nvim, nvim_integration = pcall(require, "modules.sessions.neovim_integration")
	if ok_nvim then
		local saved_count = nvim_integration.save_workspace_nvim_sessions(window, workspace_name)
		if saved_count > 0 then
			wezterm.log_info("Auto-saved " .. saved_count .. " Neovim sessions")
		end
	end

	clear_dirty(workspace_name)
	wezterm.log_info("Auto-save complete: " .. workspace_name)
end

-- Start auto-save timer for window
local function start_auto_save_timer(window, workspace_name)
	if not is_custom_workspace(workspace_name) then
		return
	end

	if not is_auto_save_enabled(workspace_name) then
		return
	end

	local window_id = window:window_id()
	local timer_key = window_id .. ":" .. workspace_name

	-- Stop existing timer if any
	if auto_save_timers[timer_key] then
		auto_save_timers[timer_key]:cancel()
	end

	wezterm.log_info("Starting auto-save timer for workspace: " .. workspace_name)

	-- Create recurring timer
	local function schedule_next()
		-- Record when next save will happen
		next_save_time[workspace_name] = os.time() + AUTO_SAVE_INTERVAL

		auto_save_timers[timer_key] = wezterm.time.call_after(AUTO_SAVE_INTERVAL, function()
			-- Check workspace is still active and auto-save still enabled
			if window:active_workspace() == workspace_name and is_auto_save_enabled(workspace_name) then
				save_workspace_state(window, workspace_name)
				schedule_next()
			end
		end)
	end

	schedule_next()
end

-- Stop auto-save timer for workspace
local function stop_auto_save_timer(window, workspace_name)
	local window_id = window:window_id()
	local timer_key = window_id .. ":" .. workspace_name

	if auto_save_timers[timer_key] then
		auto_save_timers[timer_key]:cancel()
		auto_save_timers[timer_key] = nil
		wezterm.log_info("Stopped auto-save timer for workspace: " .. workspace_name)
	end
end

function M.setup()
	-- Enable auto-save when workspace is switched TO (and it's a custom workspace)
	wezterm.on("workspace-switched", function(window, workspace_name)
		if is_custom_workspace(workspace_name) then
			-- Enable auto-save for this workspace
			M.enable_auto_save(workspace_name)
			start_auto_save_timer(window, workspace_name)
		end
	end)

	-- Enable auto-save when workspace is created
	wezterm.on("workspace-created", function(window, workspace_name)
		if is_custom_workspace(workspace_name) then
			M.enable_auto_save(workspace_name)
			start_auto_save_timer(window, workspace_name)
			mark_dirty(workspace_name) -- Mark as dirty to trigger first save
		end
	end)

	-- Mark workspace dirty on changes (only if auto-save enabled)
	wezterm.on("window-config-reloaded", function(window, pane)
		local workspace_name = window:active_workspace()
		if workspace_name and is_auto_save_enabled(workspace_name) then
			mark_dirty(workspace_name)
		end
	end)

	-- Custom event to manually trigger save
	wezterm.on("workspace-save-now", function(window, pane)
		local workspace_name = window:active_workspace()
		if workspace_name then
			mark_dirty(workspace_name)
			save_workspace_state(window, workspace_name)
			window:toast_notification("WezTerm", "Workspace saved: " .. workspace_name, nil, 2000)
		end
	end)

	-- Custom event to mark workspace dirty
	wezterm.on("workspace-mark-dirty", function(window, pane)
		local workspace_name = window:active_workspace()
		if workspace_name and is_auto_save_enabled(workspace_name) then
			mark_dirty(workspace_name)
		end
	end)

	-- Cleanup on window close
	wezterm.on("window-close", function(window, pane)
		local workspace_name = window:active_workspace()
		if workspace_name then
			stop_auto_save_timer(window, workspace_name)
		end
	end)

	wezterm.log_info("Workspace auto-save system initialized (custom workspaces only)")
end

return M
