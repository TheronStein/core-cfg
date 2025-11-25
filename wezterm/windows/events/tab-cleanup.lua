-- ~/.core/.sys/configs/wezterm/events/tab-cleanup.lua
-- Cleanup temporary tmux views when tabs are closed
-- Monitor and close tabs when their tmux sessions die

local wezterm = require("wezterm")

local M = {}

-- Track last check time per window to avoid checking too frequently
local last_check = {}
local CHECK_INTERVAL = 2000 -- Check every 2 seconds

function M.setup()
	-- Clean up tmux views when a tab is closed
	wezterm.on("mux-tab-closed", function(tab_id, pane_id)
		-- Try to load tmux_sessions module
		local ok, tmux_sessions = pcall(require, "modules.tmux_sessions")
		if ok and tmux_sessions then
			wezterm.log_info("Tab closed: " .. tostring(tab_id) .. ", cleaning up tmux view")
			tmux_sessions.cleanup_tab_view(tab_id)
		end
	end)

	-- Clean up tmux views when a window is closed
	wezterm.on("mux-window-close", function(window_id)
		-- Try to load tmux_sessions module
		local ok, tmux_sessions = pcall(require, "modules.tmux_sessions")
		if ok and tmux_sessions then
			wezterm.log_info("Window closed: " .. tostring(window_id) .. ", cleaning up orphaned views")
			tmux_sessions.cleanup_orphaned_views()
		end
	end)

	-- Clean up all orphaned views when WezTerm shuts down
	wezterm.on("gui-shutdown", function()
		wezterm.log_info("WezTerm shutting down, cleaning up all orphaned tmux views")
		local ok, tmux_sessions = pcall(require, "modules.tmux_sessions")
		if ok and tmux_sessions then
			tmux_sessions.cleanup_orphaned_views()
		end
	end)

	-- Event-driven cleanup: Listen for user-var changes from tmux
	-- When tmux detaches/closes a view session, it sends TMUX_CLEANUP_TRIGGER
	wezterm.on("user-var-changed", function(window, pane, name, value)
		if name == "TMUX_CLEANUP_TRIGGER" then
			-- Decode the base64 value
			local ok, decoded = pcall(function()
				return wezterm.base64_decode(value)
			end)

			if ok and decoded then
				wezterm.log_info("Received tmux cleanup trigger: " .. decoded)

				-- Trigger cleanup immediately
				local ok_cleanup, tmux_sessions = pcall(require, "modules.tmux_sessions")
				if ok_cleanup and tmux_sessions and tmux_sessions.is_tmux_available() then
					wezterm.log_info("Running event-driven cleanup")
					tmux_sessions.cleanup_orphaned_views()
				end
			end
		end
	end)

	-- FALLBACK: Periodically check if tmux sessions are still alive (reduced frequency)
	-- This is now a backup mechanism, not the primary cleanup method
	wezterm.on("update-status", function(window, pane)
		local window_id = tostring(window:window_id())
		-- Get current time as Unix timestamp in seconds
		local now = os.time()

		-- Check every 60 seconds instead of 2 seconds (reduced from CHECK_INTERVAL)
		if not last_check[window_id] or (now - last_check[window_id]) >= 60 then
			last_check[window_id] = now

			-- Check for dead tmux sessions and close their tabs
			local ok, tmux_sessions = pcall(require, "modules.tmux_sessions")
			if ok and tmux_sessions and tmux_sessions.is_tmux_available() then
				local closed_any = tmux_sessions.check_and_close_dead_sessions(window)
				if closed_any then
					wezterm.log_info("Closed tabs with dead tmux sessions (periodic check)")
				end
			end
		end
	end)

	-- OPTIONAL: Reduced frequency periodic cleanup (every 5 minutes)
	-- This is now just a safety net since we have event-driven cleanup
	wezterm.time.call_after(300, function()
		local ok, tmux_sessions = pcall(require, "modules.tmux_sessions")
		if ok and tmux_sessions and tmux_sessions.is_tmux_available() then
			wezterm.log_info("Periodic safety cleanup of orphaned tmux views (5 min interval)")
			tmux_sessions.cleanup_orphaned_views()
		end
		-- Schedule next cleanup
		wezterm.time.call_after(300, function()
			M.setup_periodic_cleanup()
		end)
	end)
end

-- Helper to set up recurring periodic cleanup (now 5 minutes instead of 30 seconds)
function M.setup_periodic_cleanup()
	local ok, tmux_sessions = pcall(require, "modules.tmux_sessions")
	if ok and tmux_sessions and tmux_sessions.is_tmux_available() then
		tmux_sessions.cleanup_orphaned_views()
	end
	-- Schedule next cleanup
	wezterm.time.call_after(300, function()
		M.setup_periodic_cleanup()
	end)
end

return M
