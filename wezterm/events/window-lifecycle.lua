-- Unified window lifecycle event handler
-- Handles all window-related events:
--   - window-created
--   - window-config-reloaded
--   - window-close
--   - window-focus-changed
--
-- Consolidates logic from:
--   - backdrop-cycle.lua (window-config-reloaded)
--   - window-config-reloaded.lua (window-config-reloaded)
--   - window.lua (window-created, window-config-reloaded)
--   - workspace-auto-save.lua (window-close)
--   - workspace_theme_handler.lua (window-focus-changed)

local wezterm = require("wezterm")
local debug_config = require("config.debug")

local M = {}

-- Track last cycle time per window (for backdrops)
local last_cycle = {}

-- ============================================================================
-- WINDOW CREATED
-- ============================================================================
function M.handle_window_created(window, pane)
	-- Initialize window counter for unique IDs
	wezterm.GLOBAL.window_counter = wezterm.GLOBAL.window_counter or 0
	wezterm.GLOBAL.window_counter = wezterm.GLOBAL.window_counter + 1

	local window_id = tostring(window:window_id())
	wezterm.log_info("[EVENT:WINDOW] Window created: " .. window_id)

	-- Initialize GLOBAL state defaults (in-memory only)
	wezterm.GLOBAL.current_mode = wezterm.GLOBAL.current_mode or "wezterm_mode"
	wezterm.GLOBAL.leader_context = wezterm.GLOBAL.leader_context or "wezterm"
	wezterm.GLOBAL.last_active_tab_per_window = wezterm.GLOBAL.last_active_tab_per_window or {}

	-- Set the default border color immediately (purple for wezterm_mode)
	-- Do this directly to avoid any timing issues with mode detection
	local ok, mode_colors_const = pcall(require, "modules.utils.mode_colors")
	if ok then
		local default_color = mode_colors_const.get_color("wezterm_mode")
		local overrides = window:get_config_overrides() or {}
		overrides.colors = overrides.colors or {}
		overrides.colors.split = default_color
		window:set_config_overrides(overrides)
		wezterm.log_info("[EVENT:WINDOW] Set initial border color: " .. default_color)
	end

	-- Initialize the first tab's mode state
	local mux_window = window:mux_window()
	if mux_window then
		local active_tab = mux_window:active_tab()
		if active_tab then
			local tab_id = tostring(active_tab:tab_id())
			local ok2, tab_mode_state = pcall(require, "modules.utils.tab_mode_state")
			if ok2 then
				-- get_tab_mode auto-initializes with default (wezterm_mode) and stores it
				tab_mode_state.get_tab_mode(tab_id)
				-- Set last_active_tab so tab switch detection works correctly
				wezterm.GLOBAL.last_active_tab_per_window[window_id] = tab_id
				wezterm.log_info("[EVENT:WINDOW] Initialized tab " .. tab_id .. " mode state")
			end
		end
	end

	-- Note: Initial backdrop is set in window-config-reloaded which fires right after creation
end

-- ============================================================================
-- WINDOW CONFIG RELOADED
-- ============================================================================
function M.handle_window_config_reloaded(window, pane)
	local window_id = tostring(window:window_id())

	-- Set initial backdrop for new window
	local ok, backdrops = pcall(require, "modules.gui.backdrops")
	if ok and backdrops and backdrops.are_backgrounds_enabled and backdrops:are_backgrounds_enabled() then
		if not last_cycle[window_id] then
			backdrops:set_img(window, 1)
			if debug_config.is_enabled("debug_mods_backdrop_events") then
				wezterm.log_info("[EVENT:BACKDROP] Initial backdrop set for window " .. window_id)
			end
		end
	end

	-- Mark workspace as dirty for auto-save (only for custom workspaces)
	local workspace_name = window:active_workspace()
	if workspace_name and workspace_name ~= "" and workspace_name ~= "default" then
		local ok_autosave, workspace_autosave = pcall(require, "events.workspace-lifecycle")
		if ok_autosave and workspace_autosave.mark_workspace_dirty then
			workspace_autosave.mark_workspace_dirty(workspace_name)
		end
	end

	wezterm.log_info("[EVENT:WINDOW] Config reloaded for window " .. window_id)
end

-- ============================================================================
-- WINDOW CLOSE
-- ============================================================================
function M.handle_window_close(window, pane)
	local window_id = tostring(window:window_id())
	local workspace_name = window:active_workspace()

	-- Stop auto-save timer for workspace
	if workspace_name then
		local ok, workspace_autosave = pcall(require, "events.workspace-lifecycle")
		if ok and workspace_autosave.stop_auto_save_timer then
			workspace_autosave.stop_auto_save_timer(window, workspace_name)
		end
	end

	wezterm.log_info("[EVENT:WINDOW] Window closed: " .. window_id)
end

-- ============================================================================
-- WINDOW FOCUS CHANGED
-- ============================================================================
function M.handle_window_focus_changed(window, pane)
	-- Only act when window gains focus
	if not window:is_focused() then
		return
	end

	local workspace = window:active_workspace()

	-- Check if a preview file exists for this workspace (theme browser integration)
	local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
	local preview_file
	if workspace and workspace ~= "" then
		preview_file = string.format("%s/wezterm_theme_preview_%s.txt", runtime_dir, workspace)
	else
		preview_file = runtime_dir .. "/wezterm_theme_preview.txt"
	end

	-- If preview file exists and has content, start theme watcher
	local f = io.open(preview_file, "r")
	if f then
		local content = f:read("*line")
		f:close()

		if content and content ~= "" then
			local ok, theme_watcher = pcall(require, "modules.sessions.theme_watcher")
			if ok and theme_watcher and not theme_watcher.is_active(window) then
				theme_watcher.start_watcher(window, workspace)
				wezterm.log_info("Auto-started theme watcher for workspace: " .. (workspace or "default"))
			end
		end
	end
end

-- ============================================================================
-- SETUP
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.window_lifecycle_initialized then
		return
	end
	wezterm.GLOBAL.window_lifecycle_initialized = true

	-- Window created event
	wezterm.on("window-created", function(window, pane)
		M.handle_window_created(window, pane)
	end)

	-- Window config reloaded event
	wezterm.on("window-config-reloaded", function(window, pane)
		M.handle_window_config_reloaded(window, pane)
	end)

	-- Window close event
	wezterm.on("window-close", function(window, pane)
		M.handle_window_close(window, pane)
	end)

	-- Window focus changed event
	wezterm.on("window-focus-changed", function(window, pane)
		M.handle_window_focus_changed(window, pane)
	end)

	wezterm.log_info("[EVENT] Window lifecycle handlers initialized")
end

return M
