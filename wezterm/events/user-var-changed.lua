-- Unified user-var-changed event handler
-- This is THE ONLY handler for the user-var-changed event
-- Consolidates all user-var-changed logic from:
--   - notifications.lua (notify_* variables)
--   - tab-cleanup.lua (TMUX_CLEANUP_TRIGGER)
--   - user-var.lua (navigate_wezterm for tmux navigation)
--   - workspace_theme_handler.lua (theme_applied, stop_theme_watcher)
--   - claude-code-status.lua (CLAUDE_CODE_STATE for AI assistant status)

local wezterm = require("wezterm")
local debug_config = require("config.debug")

local M = {}

-- ============================================================================
-- NOTIFICATION HANDLING
-- ============================================================================
function handle_notifications(window, pane, name, value)
	-- Only process notify_* variables
	if not name:match("^notify_") then
		return false
	end

	wezterm.log_info("user-var-changed (notify): " .. name .. " = " .. tostring(value))

	-- Try to load notifications module and call its update handler
	local ok, notifications = pcall(require, "notifications")
	if ok and notifications.update_status then
		notifications.update_status(window, pane)
		return true
	end

	return false
end

-- ============================================================================
-- TMUX CLEANUP TRIGGER
-- ============================================================================
function handle_tmux_cleanup(window, pane, name, value)
	if name ~= "TMUX_CLEANUP_TRIGGER" then
		return false
	end

	-- Decode the base64 value
	local ok, decoded = pcall(function()
		return wezterm.base64_decode(value)
	end)

	if ok and decoded then
		wezterm.log_info("Received tmux cleanup trigger: " .. decoded)

		-- Trigger cleanup immediately
		local ok_cleanup, tmux_sessions = pcall(require, "modules.tmux.sessions")
		if ok_cleanup and tmux_sessions and tmux_sessions.is_tmux_available() then
			wezterm.log_info("Running event-driven cleanup")
			tmux_sessions.cleanup_orphaned_views()
		end
		return true
	end

	return false
end

-- ============================================================================
-- TMUX NAVIGATION (WezTerm pane navigation from tmux)
-- ============================================================================
function handle_tmux_navigation(window, pane, name, value)
	if name ~= "navigate_wezterm" then
		return false
	end

	-- Decode base64 direction value
	local direction = wezterm.base64_decode(value)
	if debug_config.is_enabled("debug_events_user_var") then
		wezterm.log_info("[EVENT:USER_VAR] Navigating WezTerm pane: " .. direction)
	end
	window:perform_action(wezterm.action.ActivatePaneDirection(direction), pane)
	return true
end

-- ============================================================================
-- WORKSPACE THEME HANDLING
-- ============================================================================
function handle_workspace_theme(window, pane, name, value)
	-- Handle theme_applied variable
	if name == "theme_applied" and value and value ~= "" then
		local workspace = window:active_workspace()
		if workspace then
			-- Try to load workspace themes module
			local ok_themes, workspace_themes = pcall(require, "modules.sessions.themes")
			if ok_themes then
				-- Save the theme to workspace (legacy system)
				workspace_themes.set_workspace_theme(workspace, value)
			end

			-- ALSO save to metadata system (new persistent storage)
			local ok_meta, workspace_metadata = pcall(require, "modules.sessions.workspace_metadata")
			if ok_meta then
				workspace_metadata.set_theme(workspace, value)
				wezterm.log_info("Auto-saved theme '" .. value .. "' to workspace metadata '" .. workspace .. "'")
			end

			wezterm.log_info("Saved theme '" .. value .. "' for workspace '" .. workspace .. "'")
		end
		return true
	end

	-- Handle stop_theme_watcher variable
	if name == "stop_theme_watcher" then
		local ok, theme_watcher = pcall(require, "modules.sessions.theme_watcher")
		if ok and theme_watcher then
			theme_watcher.stop_watcher(window)
			wezterm.log_info("Stopped theme watcher")
		end
		return true
	end

	return false
end

-- ============================================================================
-- TABLINE REFRESH (TMUX user vars)
-- ============================================================================
function handle_tmux_tabline_refresh(window, pane, name, value)
	-- Check if this is a TMUX-related variable that should trigger tabline refresh
	-- Variables like TMUX_SESSION, TMUX_WINDOW, TMUX_SERVER_ICON
	if name:match("^TMUX_") then
		-- Note: Tabline refresh is handled by update-status event
		-- We just log that we received the update
		if debug_config.is_enabled("debug_events_user_var") then
			wezterm.log_info("[EVENT:USER_VAR] TMUX variable updated: " .. name)
		end
		-- Tabline will refresh automatically on next update-status cycle
		return true
	end

	return false
end

-- ============================================================================
-- CLAUDE CODE STATE HANDLING
-- ============================================================================
-- Handles CLAUDE_CODE_STATE user variable for AI assistant status indicators
-- Values: busy, waiting, complete, error, active, exit
function handle_claude_code_state(window, pane, name, value)
	if name ~= "CLAUDE_CODE_STATE" then
		return false
	end

	-- Try to load claude-code-status module
	local ok, claude_status = pcall(require, "modules.ai.claude-code-status")
	if not ok then
		if debug_config.is_enabled("debug_mods_claude_code") then
			wezterm.log_warn("[CLAUDE_CODE] Failed to load claude-code-status module")
		end
		return false
	end

	-- Delegate to the module's handler
	local handled = claude_status.handle_user_var(pane, name, value)

	if handled and debug_config.is_enabled("debug_mods_claude_code") then
		wezterm.log_info("[EVENT:USER_VAR] Claude Code state updated")
	end

	return handled
end

-- ============================================================================
-- UNIFIED USER-VAR-CHANGED HANDLER
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.user_var_changed_initialized then
		return
	end
	wezterm.GLOBAL.user_var_changed_initialized = true

	-- THE unified user-var-changed event handler
	-- This is the ONLY handler for this event - all others are consolidated here
	wezterm.on("user-var-changed", function(window, pane, name, value)
		if debug_config.is_enabled("debug_events_user_var") then
			wezterm.log_info("[EVENT:USER_VAR] " .. name .. " = " .. tostring(value))
		end

		-- Try each handler in order
		-- Each handler returns true if it processed the variable, false otherwise

		-- 1. Notification handling (notify_* variables)
		if handle_notifications(window, pane, name, value) then
			return
		end

		-- 2. TMUX cleanup trigger
		if handle_tmux_cleanup(window, pane, name, value) then
			return
		end

		-- 3. TMUX navigation (navigate_wezterm)
		if handle_tmux_navigation(window, pane, name, value) then
			return
		end

		-- 4. Workspace theme handling (theme_applied, stop_theme_watcher)
		if handle_workspace_theme(window, pane, name, value) then
			return
		end

		-- 5. TMUX tabline refresh (TMUX_SESSION, TMUX_WINDOW, etc.)
		if handle_tmux_tabline_refresh(window, pane, name, value) then
			return
		end

		-- 6. Claude Code state handling (CLAUDE_CODE_STATE)
		if handle_claude_code_state(window, pane, name, value) then
			return
		end

		-- If we get here, the variable was not handled by any specific handler
		-- This is fine - not all user vars need special handling
	end)

	wezterm.log_info("[EVENT] Unified user-var-changed handler initialized")
end

return M
