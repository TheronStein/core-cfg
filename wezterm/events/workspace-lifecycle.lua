-- Unified workspace lifecycle event handler
-- Handles all workspace-related events:
--   - workspace-switched
--   - workspace-created
--   - workspace-changed
--   - workspace-save-now (custom event)
--   - workspace-mark-dirty (custom event)
--
-- Consolidates logic from:
--   - workspace-auto-save.lua (all workspace events + auto-save functionality)
--   - workspace.lua (workspace-changed)

local wezterm = require("wezterm")

local M = {}

-- ============================================================================
-- AUTO-SAVE STATE MANAGEMENT
-- ============================================================================

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
function M.mark_workspace_dirty(workspace_name)
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
function M.stop_auto_save_timer(window, workspace_name)
	local window_id = window:window_id()
	local timer_key = window_id .. ":" .. workspace_name

	if auto_save_timers[timer_key] then
		auto_save_timers[timer_key]:cancel()
		auto_save_timers[timer_key] = nil
		wezterm.log_info("Stopped auto-save timer for workspace: " .. workspace_name)
	end
end

-- ============================================================================
-- WORKSPACE EVENT HANDLERS
-- ============================================================================

function M.handle_workspace_switched(window, workspace_name)
	wezterm.log_info("[EVENT:WORKSPACE] Switched to workspace: " .. workspace_name)

	if is_custom_workspace(workspace_name) then
		-- Enable auto-save for this workspace
		M.enable_auto_save(workspace_name)
		start_auto_save_timer(window, workspace_name)
	end
end

function M.handle_workspace_created(window, workspace_name)
	wezterm.log_info("[EVENT:WORKSPACE] Created workspace: " .. workspace_name)

	if is_custom_workspace(workspace_name) then
		M.enable_auto_save(workspace_name)
		start_auto_save_timer(window, workspace_name)
		M.mark_workspace_dirty(workspace_name) -- Mark as dirty to trigger first save
	end
end

function M.handle_workspace_changed(window, pane, new_name)
	wezterm.log_info("[EVENT:WORKSPACE] Workspace changed to: " .. new_name)

	-- Try to load workspace manager to attach tmux session if configured
	local ok_manager, workspace_manager = pcall(require, "modules.sessions.workspace_manager")
	if ok_manager then
		local ws_config = workspace_manager.get_workspace_config(new_name)
		if ws_config and ws_config.tmux_session then
			local ok_tmux, auto_tmux_session = pcall(require, "modules.tmux.auto_tmux_session")
			if ok_tmux then
				auto_tmux_session.attach_to_session(ws_config.tmux_session, pane)
			end
		end
	end

	-- Reload session for workspace
	local ok_session, session_manager = pcall(require, "modules.sessions.session_manager")
	if ok_session then
		session_manager.reload_for_workspace(window, new_name)
	end
end

function M.handle_workspace_save_now(window, pane)
	local workspace_name = window:active_workspace()
	if workspace_name then
		M.mark_workspace_dirty(workspace_name)
		save_workspace_state(window, workspace_name)
		window:toast_notification("WezTerm", "Workspace saved: " .. workspace_name, nil, 2000)
	end
end

function M.handle_workspace_mark_dirty(window, pane)
	local workspace_name = window:active_workspace()
	if workspace_name and is_auto_save_enabled(workspace_name) then
		M.mark_workspace_dirty(workspace_name)
	end
end

-- ============================================================================
-- SETUP
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.workspace_lifecycle_initialized then
		return
	end
	wezterm.GLOBAL.workspace_lifecycle_initialized = true

	-- Workspace switched event
	wezterm.on("workspace-switched", function(window, workspace_name)
		M.handle_workspace_switched(window, workspace_name)
	end)

	-- Workspace created event
	wezterm.on("workspace-created", function(window, workspace_name)
		M.handle_workspace_created(window, workspace_name)
	end)

	-- Workspace changed event (legacy, kept for compatibility)
	wezterm.on("workspace-changed", function(window, pane, new_name)
		M.handle_workspace_changed(window, pane, new_name)
	end)

	-- Custom event to manually trigger save
	wezterm.on("workspace-save-now", function(window, pane)
		M.handle_workspace_save_now(window, pane)
	end)

	-- Custom event to mark workspace dirty
	wezterm.on("workspace-mark-dirty", function(window, pane)
		M.handle_workspace_mark_dirty(window, pane)
	end)

	wezterm.log_info("[EVENT] Workspace lifecycle handlers initialized (custom workspaces only)")
end

return M
