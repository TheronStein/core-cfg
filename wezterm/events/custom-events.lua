-- Custom event handlers
-- Handles custom (non-WezTerm built-in) events:
--   - backdrop-refresh (manual backdrop refresh trigger)
--   - start-theme-watcher (theme browser integration)
--   - toggle-copilot (Copilot chat toggle)
--   - update-mode (mode display update)
--   - refresh-tabline (tabline theme refresh)
--   - reload-tabline-themes (tabline theme reload)

local wezterm = require("wezterm")

local M = {}

-- ============================================================================
-- BACKDROP REFRESH
-- ============================================================================
-- This custom event allows manual refresh of backdrops (called from keybinding)
function M.handle_backdrop_refresh()
	local backdrops = require("modules.gui.backdrops")

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

-- ============================================================================
-- THEME WATCHER
-- ============================================================================
function M.handle_start_theme_watcher(window, pane)
	local workspace = window:active_workspace()
	local ok, theme_watcher = pcall(require, "modules.sessions.theme_watcher")
	if ok and theme_watcher then
		if not theme_watcher.is_active(window) then
			theme_watcher.start_watcher(window, workspace)
			wezterm.log_info("Started theme watcher for workspace: " .. (workspace or "default"))
		end
	end
end

-- ============================================================================
-- COPILOT TOGGLE
-- ============================================================================
function M.handle_toggle_copilot(window, pane)
	local ok, copilot = pcall(require, "modules.ai.CopilotChat")
	if ok and copilot then
		copilot:toggle(window, pane)
	end
end

-- ============================================================================
-- MODE DISPLAY
-- ============================================================================
local current_mode = "CORE"

-- Function to update mode and refresh tabline
local function update_mode_display(window, mode_name)
	current_mode = mode_name
	window:perform_action(wezterm.action.EmitEvent("refresh-tabline"), nil)
end

function M.handle_update_mode(window, pane, mode_name)
	update_mode_display(window, mode_name)
end

function M.handle_refresh_tabline(window, pane)
	-- Refresh the tabline status bar
	local ok, tabline_component = pcall(require, "tabline.component")
	if ok and tabline_component and tabline_component.set_status then
		tabline_component.set_status(window)
	end
end

-- ============================================================================
-- TABLINE THEME RELOAD
-- ============================================================================
function M.handle_reload_tabline_themes(window, pane)
	-- Try to reload workspace themes if available
	local ok, workspace_themes = pcall(require, "modules.sessions.themes")
	if ok and workspace_themes.load_workspace_themes then
		workspace_themes.load_workspace_themes()
	end

	window:toast_notification("Tabline", "Themes reloaded", nil, 2000)

	-- Force refresh
	local config = window:effective_config()
	window:set_config_overrides({
		tab_bar_at_bottom = config.tab_bar_at_bottom,
	})
end

-- ============================================================================
-- SETUP
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.custom_events_initialized then
		return
	end
	wezterm.GLOBAL.custom_events_initialized = true

	-- Initialize GLOBAL state for mode display
	wezterm.GLOBAL.current_mode = "CORE"
	wezterm.GLOBAL.leader_active = false

	-- Backdrop refresh (custom event)
	wezterm.on("backdrop-refresh", function()
		M.handle_backdrop_refresh()
	end)

	-- Start theme watcher (custom event)
	wezterm.on("start-theme-watcher", function(window, pane)
		M.handle_start_theme_watcher(window, pane)
	end)

	-- Toggle Copilot (custom event)
	wezterm.on("toggle-copilot", function(window, pane)
		M.handle_toggle_copilot(window, pane)
	end)

	-- Update mode (custom event)
	wezterm.on("update-mode", function(window, pane, mode_name)
		M.handle_update_mode(window, pane, mode_name)
	end)

	-- Refresh tabline (custom event)
	wezterm.on("refresh-tabline", function(window, pane)
		M.handle_refresh_tabline(window, pane)
	end)

	-- Reload tabline themes (custom event)
	wezterm.on("reload-tabline-themes", function(window, pane)
		M.handle_reload_tabline_themes(window, pane)
	end)

	wezterm.log_info("[EVENT] Custom event handlers initialized")
end

return M
