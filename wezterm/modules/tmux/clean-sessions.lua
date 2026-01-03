-- ~/.core/.sys/configs/wezterm/events/tab-cleanup.lua
-- Cleanup temporary tmux views when tabs are closed
-- Monitor and close tabs when their tmux sessions die

local wezterm = require("wezterm")
local tmux = require("modules.tmux.utils")
local sessions = require("modules.tmux.sessions")

local M = {}

-- Track last check time per window to avoid checking too frequently
local last_check = {}
local CHECK_INTERVAL = 2000 -- Check every 2 seconds

-- Cleanup temporary view for a tab
function M.cleanup_tab_view(tab_id)
  if not wezterm.GLOBAL.custom_tabs then
    return
  end

  local tab_data = wezterm.GLOBAL.custom_tabs[tostring(tab_id)]
  if not tab_data or not tab_data.tmux_view then
    return
  end

  local view_name = tab_data.tmux_view

  -- Kill the temporary view session
  -- Note: With detach-on-destroy set, this should auto-cleanup anyway
  -- but we can be explicit here
  if sessions.session_exists(view_name) then
    wezterm.log_info("Cleaning up temporary tmux view: " .. view_name)
    tmux.kill_session(view_name)
  end

  -- Clean up the tab metadata
  wezterm.GLOBAL.custom_tabs[tostring(tab_id)] = nil
end

-- Check all tabs and close those whose tmux sessions no longer exist
function M.check_and_close_dead_sessions(window)
  if not wezterm.GLOBAL.custom_tabs then
    return
  end

  local mux_window = window:mux_window()
  if not mux_window then
    return
  end

  local tabs_to_close = {}

  -- Check each tab
  for tab_id_str, tab_data in pairs(wezterm.GLOBAL.custom_tabs) do
    if type(tab_data) == "table" and tab_data.tmux_session then
      local session_name = tab_data.tmux_session
      local socket_name = tab_data.tmux_workspace -- Get workspace if present

      -- Check if the parent session still exists (with workspace context)
      if not sessions.session_exists(session_name, socket_name) then
        wezterm.log_info(
          "Tmux session '" .. session_name .. "' no longer exists, marking tab for closure"
        )
        table.insert(tabs_to_close, {
          tab_id = tonumber(tab_id_str),
          session_name = session_name,
        })
      end
    end
  end

  -- Close tabs whose sessions are dead
  for _, info in ipairs(tabs_to_close) do
    -- Find the tab by ID and close it
    for _, tab in ipairs(mux_window:tabs()) do
      if tab:tab_id() == info.tab_id then
        wezterm.log_info("Closing tab " .. info.tab_id .. " (session: " .. info.session_name .. ")")

        -- Clean up metadata first
        M.cleanup_tab_view(info.tab_id)

        -- Close the tab
        -- Note: This might not work perfectly for all cases
        -- The tab will close when the pane exits naturally
        local pane = tab:active_pane()
        if pane then
          -- Send Ctrl-C and exit to ensure the pane closes
          pane:send_text("\x03") -- Ctrl-C
          wezterm.sleep_ms(100)
          pane:send_text("exit\n")
        end

        break
      end
    end
  end

  return #tabs_to_close > 0
end

-- Cleanup orphaned view sessions that are no longer attached to any WezTerm tabs
-- This is the key function that solves the "extra sessions in background" problem
function M.cleanup_orphaned_views()
  if not tmux.is_tmux_available() then
    return 0
  end

  -- Get all currently active tabs from WezTerm
  local active_view_sessions = {}
  if wezterm.GLOBAL.custom_tabs then
    for tab_id_str, tab_data in pairs(wezterm.GLOBAL.custom_tabs) do
      if tab_data.tmux_view then
        active_view_sessions[tab_data.tmux_view] = true
      end
    end
  end

  local cleaned_count = 0
  local skipped_count = 0

  -- Get list of all tmux sockets/workspaces to check
  local sockets_to_check = { nil } -- nil = default socket

  -- Try to load tmux workspaces to check workspace-specific sockets
  local ok, tmux_workspaces = pcall(require, sessions)
  if ok and tmux_workspaces and tmux_workspaces.workspaces then
    for workspace_name, _ in pairs(tmux_workspaces.workspaces) do
      table.insert(sockets_to_check, workspace_name)
    end
  end

  -- Check all sockets (default + workspaces)
  for _, socket_name in ipairs(sockets_to_check) do
    local all_sessions = sessions.list_sessions(socket_name)

    -- Find and kill orphaned view sessions
    for _, session_info in ipairs(all_sessions) do
      local session_name = session_info.name

      -- Check if this is a view session (more flexible pattern matching)
      -- Matches: *-view-<timestamp>-<random> (e.g., tmux-17-view-*, floating-view-*, yazi-view-*)
      if session_name:match("%-view%-%d+%-%d+") then
        -- Check if this view is tracked by an active WezTerm tab
        local is_tracked = active_view_sessions[session_name] ~= nil

        -- IMPORTANT: Only clean up views that meet ALL these criteria:
        -- 1. NOT tracked by WezTerm (not in custom_tabs)
        -- 2. NOT attached (no clients connected)
        --
        -- ENHANCED: Also check age - clean up unattached views older than 5 minutes
        -- even if tracked (handles WezTerm crash/restart scenarios)
        local age_seconds = 0
        if session_info.created and session_info.created ~= "" then
          age_seconds = os.time() - tonumber(session_info.created)
        end
        local is_stale = age_seconds > 300 -- 5 minutes

        if not session_info.attached then
          if not is_tracked or is_stale then
            -- This is an orphaned view - kill it
            local socket_info = socket_name and (" [socket: " .. socket_name .. "]") or ""
            local reason = not is_tracked and "untracked" or "stale (" .. age_seconds .. "s)"
            wezterm.log_info(
              "Cleaning up orphaned view session ["
                .. reason
                .. "]: "
                .. session_name
                .. " (group: "
                .. (session_info.group or "none")
                .. ")"
                .. socket_info
            )

            -- Build kill command with socket flag if needed
            local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""
            local kill_cmd =
              string.format([[tmux %skill-session -t '%s' 2>/dev/null]], socket_flag, session_name)

            if os.execute(kill_cmd) == 0 or os.execute(kill_cmd) == true then
              cleaned_count = cleaned_count + 1
              -- Also remove from custom_tabs if present
              for tab_id_str, tab_data in pairs(wezterm.GLOBAL.custom_tabs or {}) do
                if tab_data.tmux_view == session_name then
                  wezterm.GLOBAL.custom_tabs[tab_id_str] = nil
                  break
                end
              end
            else
              wezterm.log_warn("Failed to kill orphaned view session: " .. session_name)
            end
          else
            skipped_count = skipped_count + 1
          end
        end
      end
    end
  end

  if cleaned_count > 0 then
    wezterm.log_info(
      "Cleaned up "
        .. cleaned_count
        .. " orphaned view session(s)"
        .. (skipped_count > 0 and " (skipped " .. skipped_count .. " active)" or "")
    )
  end

  return cleaned_count
end

function M.setup()
  -- Clean up tmux views when a tab is closed
  wezterm.on("mux-tab-closed", function(tab_id, pane_id)
    -- Try to load tmux_sessions module
    local ok, tmux_sessions = pcall(require, sessions)
    if ok and tmux_sessions then
      wezterm.log_info("Tab closed: " .. tostring(tab_id) .. ", cleaning up tmux view")
      tmux_sessions.cleanup_tab_view(tab_id)
    end
  end)

  -- Clean up tmux views when a window is closed
  wezterm.on("mux-window-close", function(window_id)
    -- Try to load tmux_sessions module
    local ok, tmux_sessions = pcall(require, "sessions")
    if ok and tmux_sessions then
      wezterm.log_info("Window closed: " .. tostring(window_id) .. ", cleaning up orphaned views")
      tmux_sessions.cleanup_orphaned_views()
    end
  end)

  -- Clean up all orphaned views when WezTerm shuts down
  wezterm.on("gui-shutdown", function()
    wezterm.log_info("WezTerm shutting down, cleaning up all orphaned tmux views")
    local ok, tmux_sessions = pcall(require, "sessions")
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
        wezterm.log_info("Received tmux cleanup trigger: " .. decoded)

        -- Trigger cleanup immediately
        local ok_cleanup, tmux_sessions = pcall(require, sessions)
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
      local ok, tmux_sessions = pcall(require, sessions)
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
    local ok, tmux_sessions = pcall(require, sessions)
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
  local ok, tmux_sessions = pcall(require, sessions)
  if ok and tmux_sessions and tmux_sessions.is_tmux_available() then
    tmux_sessions.cleanup_orphaned_views()
  end -- Schedule next cleanup
  wezterm.time.call_after(300, function()
    M.setup_periodic_cleanup()
  end)
end

return M
