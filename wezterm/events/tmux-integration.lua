-- TMUX integration event handlers
-- Handles TMUX-specific events:
--   - tmux-session-renamed (custom event)
--   - tmux-session-deleted (custom event)
--   - smart_workspace_switcher.workspace_switcher.created (plugin event)
--   - smart_workspace_switcher.workspace_switcher.selected (plugin event)

local wezterm = require("wezterm")

local M = {}

-- ============================================================================
-- TMUX SESSION MANAGEMENT
-- ============================================================================

function M.handle_tmux_session_renamed(old_name, new_name)
	wezterm.log_info("[EVENT:TMUX] Session renamed: " .. old_name .. " -> " .. new_name)

	-- Try to load session manager
	local ok, session_manager = pcall(require, "modules.sessions.session_manager")
	if ok and session_manager and session_manager.rename_session then
		session_manager.rename_session(old_name, new_name)
	end
end

function M.handle_tmux_session_deleted(session_name)
	wezterm.log_info("[EVENT:TMUX] Session deleted: " .. session_name)

	-- Try to load session manager
	local ok, session_manager = pcall(require, "modules.sessions.session_manager")
	if ok and session_manager and session_manager.mark_as_unused then
		session_manager.mark_as_unused(session_name)
	end
end

-- ============================================================================
-- SMART WORKSPACE SWITCHER (RESURRECT PLUGIN)
-- ============================================================================

function M.handle_workspace_switcher_created(window, path, label)
	wezterm.log_info("[EVENT:SMART_WS] Workspace switcher created: " .. label)

	-- Try to load resurrect module
	local ok, resurrect = pcall(require, "resurrect")
	if ok and resurrect then
		local workspace_state = resurrect.workspace_state
		local state = resurrect.state_manager.load_state(label, "workspace")
		if state then
			workspace_state.restore_workspace(state, {
				window = window,
				relative = true,
				restore_text = true,
				on_pane_restore = resurrect.tab_state.default_on_pane_restore,
			})
		end
	end
end

function M.handle_workspace_switcher_selected(window, path, label)
	wezterm.log_info("[EVENT:SMART_WS] Workspace switcher selected: " .. label)

	-- Try to load resurrect module
	local ok, resurrect = pcall(require, "resurrect")
	if ok and resurrect then
		local workspace_state = resurrect.workspace_state
		local state = workspace_state.get_workspace_state()
		if state then
			state.name = label
			resurrect.state_manager.save_state(state)
		end
	end
end

-- ============================================================================
-- SETUP
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.tmux_integration_initialized then
		return
	end
	wezterm.GLOBAL.tmux_integration_initialized = true

	-- TMUX session renamed event
	wezterm.on("tmux-session-renamed", function(old_name, new_name)
		M.handle_tmux_session_renamed(old_name, new_name)
	end)

	-- TMUX session deleted event
	wezterm.on("tmux-session-deleted", function(session_name)
		M.handle_tmux_session_deleted(session_name)
	end)

	-- Smart workspace switcher created event (resurrect plugin)
	wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
		M.handle_workspace_switcher_created(window, path, label)
	end)

	-- Smart workspace switcher selected event (resurrect plugin)
	wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
		M.handle_workspace_switcher_selected(window, path, label)
	end)

	wezterm.log_info("[EVENT] TMUX integration handlers initialized")
end

return M
