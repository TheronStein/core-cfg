local wezterm = require("wezterm")
local act = wezterm.action
local paths = require("utils.paths")
local debug_config = require("config.debug")
local mux_ws = require("tmux.workspaces")

local M = {}

-- =====================================================
-- BASH-INTEGRATED TMUX MANAGEMENT
-- =====================================================

-- Show bash FZF list of TMUX servers
function M.show_bash_servers_list(window, pane)
  -- Build servers data for the script
  local servers_data = { servers = {} }

  -- Get all active servers
  for name, workspace in pairs(mux_ws) do
    if mux_ws.is_server_active(name) then
      local sessions = mux_ws.list_workspace_sessions(name)
      local session_count = #sessions

      -- Get socket path
      local uid = os.getenv("UID")
      if not uid then
        local handle = io.popen("id -u")
        if handle then
          uid = handle:read("*a"):gsub("%s+$", "")
          handle:close()
        end
      end

      local socket_path = ""
      if uid and uid ~= "" then
        socket_path = "/tmp/tmux-" .. uid .. "/" .. name
      end

      table.insert(servers_data.servers, {
        name = workspace.display_name,
        socket = socket_path,
        icon = workspace.icon,
        session_count = session_count,
      })
    end
  end

  if #servers_data.servers == 0 then
    window:toast_notification("TMUX Manager", "No active TMUX servers found", nil, 2000)
    return
  end

  -- Create callback file
  local callback_file = wezterm.config_dir .. "/.data/tmux-servers-callback.tmp"

  -- Launch bash servers list script
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab({
      args = {
        paths.WEZTERM_SCRIPTS .. "/tmux-manager/servers-list.sh",
        callback_file,
        wezterm.json_encode(servers_data),
      },
    }),
    pane
  )

  -- Watch for callback
  local function watch_for_callback(iterations)
    if iterations > 60 then
      os.remove(callback_file)
      return
    end

    local f = io.open(callback_file, "r")
    if f then
      local action = f:read("*line")
      f:close()
      os.remove(callback_file)

      if action and action ~= "" then
        local win = window
        local p = pane

        if action:match("^error:") then
          win:toast_notification("TMUX Manager", action:match("^error:(.+)"), nil, 2000)
        else
          -- Action contains server socket path
          local server_socket = action
          -- Show server menu for this socket
          M.show_bash_server_menu(win, p, server_socket)
        end

        -- Close the servers list tab
        wezterm.time.call_after(0.2, function()
          local mux_window = win:mux_window()
          if mux_window then
            for _, tab in ipairs(mux_window:tabs()) do
              local panes = tab:panes()
              if #panes > 0 then
                local pane_obj = panes[1]
                local process = pane_obj:get_foreground_process_name()
                if process and process:match("servers%-list%.sh") then
                  tab:activate()
                  wezterm.time.call_after(0.05, function()
                    win:perform_action(
                      wezterm.action.CloseCurrentTab({ confirm = false }),
                      pane_obj
                    )
                  end)
                  break
                end
              end
            end
          end
        end)
      end
    else
      -- File doesn't exist yet, check again
      wezterm.time.call_after(0.5, function()
        watch_for_callback(iterations + 1)
      end)
    end
  end

  -- Start watching
  wezterm.time.call_after(0.5, function()
    watch_for_callback(0)
  end)
end

-- Show bash FZF server management menu
function M.show_bash_server_menu(window, pane, server_socket)
  -- Extract server name from socket path
  local server_name = server_socket:match("/([^/]+)$") or "TMUX Server"

  -- Create callback file
  local callback_file = wezterm.config_dir .. "/.data/tmux-server-menu-callback.tmp"

  -- Launch bash server menu script
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab({
      args = {
        paths.WEZTERM_SCRIPTS .. "/tmux-manager/server-menu.sh",
        callback_file,
        server_socket,
        server_name,
      },
    }),
    pane
  )

  -- Watch for callback
  local function watch_for_callback(iterations)
    if iterations > 60 then
      os.remove(callback_file)
      return
    end

    local f = io.open(callback_file, "r")
    if f then
      local action = f:read("*line")
      f:close()
      os.remove(callback_file)

      if action and action ~= "" then
        local win = window
        local p = pane

        if action == "back" then
          -- Go back to servers list
          M.show_bash_servers_list(win, p)
        elseif action == "create_session" then
          -- Create new session (prompt for name)
          win:perform_action(
            wezterm.action.PromptInputLine({
              description = "Enter new session name:",
              action = wezterm.action_callback(function(inner_win, inner_pane, session_name)
                if session_name and session_name ~= "" then
                  local cmd = string.format(
                    "tmux -S '%s' new-session -d -s '%s' 2>/dev/null",
                    server_socket,
                    session_name
                  )
                  os.execute(cmd)
                  inner_win:toast_notification(
                    "TMUX Manager",
                    "Created session: " .. session_name,
                    nil,
                    2000
                  )
                end
              end),
            }),
            p
          )
        elseif action == "choose_icon" or action == "choose_color" or action == "jump_config" then
          -- TODO: Implement these actions
          win:toast_notification(
            "TMUX Manager",
            "Action not yet implemented: " .. action,
            nil,
            2000
          )
        elseif action == "list_sessions" then
          -- Show sessions list for this server
          M.show_bash_sessions_list(win, p, server_socket, server_name)
        end

        -- Close the server menu tab
        wezterm.time.call_after(0.2, function()
          local mux_window = win:mux_window()
          if mux_window then
            for _, tab in ipairs(mux_window:tabs()) do
              local panes = tab:panes()
              if #panes > 0 then
                local pane_obj = panes[1]
                local process = pane_obj:get_foreground_process_name()
                if process and process:match("server%-menu%.sh") then
                  tab:activate()
                  wezterm.time.call_after(0.05, function()
                    win:perform_action(
                      wezterm.action.CloseCurrentTab({ confirm = false }),
                      pane_obj
                    )
                  end)
                  break
                end
              end
            end
          end
        end)
      end
    else
      -- File doesn't exist yet, check again
      wezterm.time.call_after(0.5, function()
        watch_for_callback(iterations + 1)
      end)
    end
  end

  -- Start watching
  wezterm.time.call_after(0.5, function()
    watch_for_callback(0)
  end)
end

-- Show bash FZF sessions list for a server
function M.show_bash_sessions_list(window, pane, server_socket, server_name)
  -- Create callback file
  local callback_file = wezterm.config_dir .. "/.data/tmux-sessions-callback.tmp"

  -- Launch bash sessions list script
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab({
      args = {
        paths.WEZTERM_SCRIPTS .. "/tmux-manager/sessions-list.sh",
        callback_file,
        server_socket,
        server_name,
      },
    }),
    pane
  )

  -- Watch for callback
  local function watch_for_callback(iterations)
    if iterations > 60 then
      os.remove(callback_file)
      return
    end

    local f = io.open(callback_file, "r")
    if f then
      local action_line = f:read("*line")
      f:close()
      os.remove(callback_file)

      if action_line and action_line ~= "" then
        local win = window
        local p = pane

        -- Parse action: "attach:session_name", "delete:session_name", "rename:session_name", "error:message"
        local action_type, param = action_line:match("^([^:]+):(.+)$")

        if action_type == "error" then
          win:toast_notification("TMUX Manager", param, nil, 2000)
        elseif action_type == "attach" then
          -- Attach to session
          win:perform_action(
            wezterm.action.SpawnCommandInNewTab({
              args = { "tmux", "-S", server_socket, "attach-session", "-t", param },
            }),
            p
          )
          win:toast_notification("TMUX Manager", "Attached to: " .. param, nil, 2000)
        elseif action_type == "delete" then
          -- Delete session
          local cmd =
            string.format("tmux -S '%s' kill-session -t '%s' 2>/dev/null", server_socket, param)
          os.execute(cmd)
          win:toast_notification("TMUX Manager", "Deleted session: " .. param, nil, 2000)
        elseif action_type == "rename" then
          -- Rename session (prompt for new name)
          win:perform_action(
            wezterm.action.PromptInputLine({
              description = "Rename session to:",
              action = wezterm.action_callback(function(inner_win, inner_pane, new_name)
                if new_name and new_name ~= "" and new_name ~= param then
                  local cmd = string.format(
                    "tmux -S '%s' rename-session -t '%s' '%s' 2>/dev/null",
                    server_socket,
                    param,
                    new_name
                  )
                  os.execute(cmd)
                  inner_win:toast_notification(
                    "TMUX Manager",
                    "Renamed to: " .. new_name,
                    nil,
                    2000
                  )
                end
              end),
            }),
            p
          )
        end

        -- Close the sessions list tab
        wezterm.time.call_after(0.2, function()
          local mux_window = win:mux_window()
          if mux_window then
            for _, tab in ipairs(mux_window:tabs()) do
              local panes = tab:panes()
              if #panes > 0 then
                local pane_obj = panes[1]
                local process = pane_obj:get_foreground_process_name()
                if process and process:match("sessions%-list%.sh") then
                  tab:activate()
                  wezterm.time.call_after(0.05, function()
                    win:perform_action(
                      wezterm.action.CloseCurrentTab({ confirm = false }),
                      pane_obj
                    )
                  end)
                  break
                end
              end
            end
          end
        end)
      end
    else
      -- File doesn't exist yet, check again
      wezterm.time.call_after(0.5, function()
        watch_for_callback(iterations + 1)
      end)
    end
  end

  -- Start watching
  wezterm.time.call_after(0.5, function()
    watch_for_callback(0)
  end)
end

return M
