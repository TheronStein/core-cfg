-- Unified update-status event handler
-- This is THE ONLY handler for the update-status event
-- Consolidates all update-status logic from:
--   - backdrop-cycle.lua (backdrop cycling)
--   - backdrop-opacity-watcher.lua (opacity file watching)
--   - backdrop-refresh-watcher.lua (refresh signal watching)
--   - leader-activated.lua (leader key tracking)
--   - tab-cleanup.lua (periodic tmux cleanup)
--   - update-status-unified.lua (previous attempt at unification)
--   - claude-code-status.lua (Claude Code AI session polling)

local wezterm = require("wezterm")
local debug_config = require("config.debug")

local M = {}

-- ============================================================================
-- BACKDROP CYCLING
-- ============================================================================
local backdrop_cycle = {
	last_cycle = {},
	CYCLE_INTERVAL = 300, -- seconds
}

function backdrop_cycle.update(window, pane)
	local backdrops = require("modules.gui.backdrops")

	-- Skip if backgrounds are disabled
	if not backdrops:are_backgrounds_enabled() then
		return
	end

	local window_id = tostring(window:window_id())
	local now = os.time()

	-- Initialize if first run
	if not backdrop_cycle.last_cycle[window_id] then
		backdrop_cycle.last_cycle[window_id] = now
		-- Set initial backdrop
		backdrops:set_img(window, 1)
		return
	end

	-- Check if interval has passed
	if now - backdrop_cycle.last_cycle[window_id] > backdrop_cycle.CYCLE_INTERVAL then
		backdrops:cycle_forward(window)
		backdrop_cycle.last_cycle[window_id] = now
		if debug_config.is_enabled("debug_mods_backdrop_events") then
			wezterm.log_info("[EVENT:BACKDROP] Cycled for window " .. window_id)
		end
	end
end

-- ============================================================================
-- BACKDROP OPACITY WATCHER
-- ============================================================================
local backdrop_opacity = {
	last_opacity = {},
}

-- Get opacity file path for workspace
local function get_opacity_file(workspace_name)
	local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
	if workspace_name and workspace_name ~= "" then
		return string.format("%s/wezterm_backdrop_opacity_%s.txt", runtime_dir, workspace_name)
	else
		return runtime_dir .. "/wezterm_backdrop_opacity.txt"
	end
end

function backdrop_opacity.update(window, pane)
	local backdrops = require("modules.gui.backdrops")

	-- Skip if backgrounds are disabled
	if not backdrops:are_backgrounds_enabled() then
		return
	end

	local workspace = window:active_workspace() or "default"
	local opacity_file = get_opacity_file(workspace)

	-- Read opacity value from file
	local f = io.open(opacity_file, "r")
	if f then
		local opacity_str = f:read("*line")
		f:close()

		if opacity_str then
			local opacity = tonumber(opacity_str)
			if opacity and opacity >= 0.0 and opacity <= 1.0 then
				-- Check if opacity changed
				local workspace_key = workspace or "default"
				if backdrop_opacity.last_opacity[workspace_key] ~= opacity then
					backdrop_opacity.last_opacity[workspace_key] = opacity

					-- Update backdrop with new opacity
					backdrops.overlay_opacity = opacity

					-- Force refresh to apply new opacity
					backdrops:set_img(window, backdrops.current_idx)

					wezterm.log_info(
						string.format("Updated backdrop opacity for workspace '%s': %.2f", workspace, opacity)
					)
				end
			end
		end
	end
end

-- ============================================================================
-- BACKDROP REFRESH WATCHER
-- ============================================================================
local backdrop_refresh = {
	last_signal_time = 0,
}

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

function backdrop_refresh.update(window, pane)
	local backdrops = require("modules.gui.backdrops")

	-- Skip if backgrounds are disabled
	if not backdrops:are_backgrounds_enabled() then
		return
	end

	local signal_file = wezterm.config_dir .. "/.data/.backdrop-refresh"
	local current_mtime = get_file_mtime(signal_file)

	-- If signal file has been modified since last check
	if current_mtime > backdrop_refresh.last_signal_time then
		backdrop_refresh.last_signal_time = current_mtime

		-- Small delay to ensure all file operations are complete
		wezterm.sleep_ms(100)

		-- Refresh all windows
		refresh_all_windows()
	end
end

-- ============================================================================
-- TAB SWITCH DETECTION
-- ============================================================================
-- Detects when the active tab changes and restores that tab's mode

function detect_and_handle_tab_switch(window, pane)
	local ok, tab_mode_state = pcall(require, "modules.utils.tab_mode_state")
	if not ok then
		return false
	end

	local ok2, mode_colors = pcall(require, "keymaps.mode-colors")
	if not ok2 then
		return false
	end

	-- Check if tab switched
	local switched, from_tab_id, to_tab_id = tab_mode_state.detect_tab_switch(window)

	if switched and to_tab_id then
		-- Handle the tab switch - restore destination tab's mode
		mode_colors.on_tab_switch(window, pane, from_tab_id, to_tab_id)
		return true
	end

	return false
end

-- ============================================================================
-- MODE BORDER COLOR SYNC
-- ============================================================================
-- Syncs mode colors ONLY when the mode actually changes.
-- This allows instant detection of leader key and other mode transitions
-- while avoiding unnecessary set_mode calls.

-- Initialize GLOBAL tracking if needed
wezterm.GLOBAL.last_mode_per_window = wezterm.GLOBAL.last_mode_per_window or {}

function sync_mode_border(window, pane)
	-- First, check for tab switch (this takes priority)
	if detect_and_handle_tab_switch(window, pane) then
		-- Tab switched, mode was already updated by on_tab_switch
		wezterm.GLOBAL.leader_active = window:leader_is_active()
		return
	end

	local ok, mode_colors = pcall(require, "keymaps.mode-colors")
	if not ok then
		return
	end

	local ok2, mode_colors_const = pcall(require, "modules.utils.mode_colors")
	if not ok2 then
		return
	end

	local window_id = tostring(window:window_id())

	-- Check leader state directly
	local leader_active = window:leader_is_active()
	if leader_active then
		wezterm.log_info("[SYNC] Leader is active!")
	end

	-- Detect current mode (cheap boolean/string checks)
	local current_mode = mode_colors_const.get_current_mode(window)

	-- Only call set_mode if mode actually changed from what update-status last saw
	-- Note: set_mode also updates GLOBAL.current_mode, so we check against that too
	local last_synced = wezterm.GLOBAL.last_mode_per_window[window_id]
	if last_synced ~= current_mode then
		wezterm.log_info("[SYNC] Mode changed: " .. tostring(last_synced) .. " -> " .. current_mode)
		wezterm.GLOBAL.last_mode_per_window[window_id] = current_mode
		mode_colors.set_mode(window, current_mode)
	end

	-- Update global state for other systems
	wezterm.GLOBAL.leader_active = window:leader_is_active()
end

-- ============================================================================
-- TAB CLEANUP (Periodic tmux session check)
-- ============================================================================
local tab_cleanup = {
	last_check = {},
	CHECK_INTERVAL = 60, -- Check every 60 seconds (reduced from original)
}

function tab_cleanup.update(window, pane)
	local window_id = tostring(window:window_id())
	local now = os.time()

	-- Check every 60 seconds
	if not tab_cleanup.last_check[window_id] or (now - tab_cleanup.last_check[window_id]) >= tab_cleanup.CHECK_INTERVAL then
		tab_cleanup.last_check[window_id] = now

		-- Check for dead tmux sessions and close their tabs
		local ok, tmux_sessions = pcall(require, "modules.tmux.sessions")
		if ok and tmux_sessions and tmux_sessions.is_tmux_available() then
			local closed_any = tmux_sessions.check_and_close_dead_sessions(window)
			if closed_any then
				wezterm.log_info("Closed tabs with dead tmux sessions (periodic check)")
			end
		end
	end
end

-- ============================================================================
-- TABLINE STATUS BAR COMPONENTS
-- ============================================================================
function update_tabline_status(window, pane)
	local ok, tabline_component = pcall(require, "tabline.component")
	if ok and tabline_component and tabline_component.set_status then
		tabline_component.set_status(window)
	end
end

-- ============================================================================
-- WORKSPACE THEME APPLICATION
-- ============================================================================
function update_workspace_theme(window, pane)
	local workspace = window:active_workspace()
	if workspace then
		local ok, workspace_themes = pcall(require, "modules.sessions.themes")
		if ok then
			local theme_data = workspace_themes.get_workspace_theme(workspace)

			if theme_data and theme_data.theme then
				-- Apply workspace theme if it's different from current override
				local overrides = window:get_config_overrides() or {}
				if overrides.color_scheme ~= theme_data.theme then
					workspace_themes.apply_workspace_theme(window, workspace)
				end
			end
		end
	end
end

-- ============================================================================
-- CLAUDE CODE STATUS POLLING
-- ============================================================================
-- Polls process state as fallback when user vars aren't available
-- This detects Claude Code sessions by checking the foreground process

local claude_code_poll = {
	last_poll = {},
	POLL_INTERVAL = 2, -- seconds (lightweight check)
}

function claude_code_poll.update(window, pane)
	local window_id = tostring(window:window_id())
	local now = os.time()

	-- Rate limit polling per window
	if claude_code_poll.last_poll[window_id] and
	   (now - claude_code_poll.last_poll[window_id]) < claude_code_poll.POLL_INTERVAL then
		return
	end
	claude_code_poll.last_poll[window_id] = now

	-- Try to load Claude Code status module
	local ok, claude_status = pcall(require, "modules.ai.claude-code-status")
	if not ok then
		return
	end

	-- Poll the active pane for Claude Code process
	claude_status.poll_pane_state(pane)
end

-- ============================================================================
-- TAB TEMPLATE HOOKS (Directory-based auto-loading)
-- ============================================================================
-- Monitors directory changes and applies templates when patterns match
-- Rate-limited to avoid excessive checks

local tab_hooks_poll = {
	last_poll = {},
	POLL_INTERVAL = 3, -- seconds (check every 3 seconds)
}

function tab_hooks_poll.update(window, pane)
	local pane_id = tostring(pane:pane_id())
	local now = os.time()

	-- Rate limit polling per pane
	if tab_hooks_poll.last_poll[pane_id] and
	   (now - tab_hooks_poll.last_poll[pane_id]) < tab_hooks_poll.POLL_INTERVAL then
		return
	end
	tab_hooks_poll.last_poll[pane_id] = now

	-- Try to load tab hooks module
	local ok, tab_hooks = pcall(require, "modules.tabs.tab_hooks")
	if not ok then
		return
	end

	-- Check and apply hooks for current pane
	tab_hooks.check_and_apply_hooks(window, pane)
end

-- ============================================================================
-- UNIFIED UPDATE-STATUS HANDLER
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.update_status_initialized then
		return
	end
	wezterm.GLOBAL.update_status_initialized = true

	-- Initialize GLOBAL state
	-- Initialize to wezterm_mode by default (context detection will update to tmux_mode if needed)
	wezterm.GLOBAL.current_mode = wezterm.GLOBAL.current_mode or "wezterm_mode"
	wezterm.GLOBAL.leader_active = wezterm.GLOBAL.leader_active or false

	-- THE unified update-status event handler
	-- This is the ONLY handler for this event - all others are consolidated here
	wezterm.on("update-status", function(window, pane)
		-- 1. Backdrop cycling (automatic backdrop rotation)
		backdrop_cycle.update(window, pane)

		-- 2. Backdrop opacity watcher (theme browser integration)
		backdrop_opacity.update(window, pane)

		-- 3. Backdrop refresh watcher (signal file monitoring)
		backdrop_refresh.update(window, pane)

		-- 4. Mode border color sync (keeps pane borders in sync with current mode)
		sync_mode_border(window, pane)

		-- 5. Tab cleanup (periodic tmux session check - fallback mechanism)
		tab_cleanup.update(window, pane)

		-- 6. Tabline status bar components (left/right sections)
		update_tabline_status(window, pane)

		-- 7. Workspace theme application (auto-apply workspace themes)
		update_workspace_theme(window, pane)

		-- 8. Claude Code status polling (fallback detection when user vars unavailable)
		claude_code_poll.update(window, pane)

		-- 9. Tab template hooks (directory-based auto-loading)
		tab_hooks_poll.update(window, pane)
	end)

	wezterm.log_info("[EVENT] Unified update-status handler initialized")
end

return M
