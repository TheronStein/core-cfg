-- ~/.core/.sys/configs/wezterm/modules/tmux_sessions.lua
-- Tmux session management - spawn tabs that attach to tmux sessions

local wezterm = require("wezterm")
local act = wezterm.action
local tmux = require("modules.tmux.utils")
local helpers = require("utils.helpers")

local M = {}

-- List all tmux sessions with metadata
-- Optional socket_name parameter for specific tmux server
function M.list_sessions(socket_name)
  if not tmux.is_tmux_available() then
    return {}
  end

  local sessions = {}
  local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""
  -- Format: session_name:windows:attached:created:session_group
  local handle = io.popen(
    string.format(
      [[tmux %slist-sessions -F '#{session_name}|#{session_windows}|#{session_attached}|#{session_created}|#{session_group}' 2>/dev/null]],
      socket_flag
    )
  )

  if not handle then
    return sessions
  end

  for line in handle:lines() do
    local name, windows, attached, created, group =
      line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]*)")
    if name then
      table.insert(sessions, {
        name = name,
        windows = tonumber(windows) or 0,
        attached = attached == "1",
        created = created or "",
        group = group or "",
        is_tmux = true, -- Mark as tmux session
        socket = socket_name, -- Store which socket this session belongs to
      })
    end
  end

  handle:close()
  return sessions
end

-- Get detailed info about a specific session
function M.get_session_info(session_name)
  if not M.is_tmux_available() then
    return nil
  end

  local handle = io.popen(
    string.format(
      [[tmux list-windows -t '%s' -F '#{window_index}:#{window_name}:#{window_panes}' 2>/dev/null]],
      session_name
    )
  )

  if not handle then
    return nil
  end

  local windows = {}
  for line in handle:lines() do
    local index, name, panes = line:match("([^:]+):([^:]+):([^:]+)")
    if index then
      table.insert(windows, {
        index = tonumber(index) or 0,
        name = name,
        panes = tonumber(panes) or 1,
      })
    end
  end

  handle:close()

  return {
    windows = windows,
    window_count = #windows,
  }
end

-- Create a new tmux session
-- Optional socket_name parameter for specific tmux server
function M.create_session(session_name, cwd, socket_name)
  if not tmux.is_tmux_available() then
    return false, "tmux not available"
  end

  cwd = cwd or wezterm.home_dir
  local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""

  local cmd = string.format(
    [[tmux %snew-session -d -s '%s' -c '%s' 2>/dev/null]],
    socket_flag,
    session_name,
    cwd
  )
  local result = os.execute(cmd)

  return result == 0 or result == true,
    result == 0 or result == true and "Session created" or "Failed to create session"
end

-- Check if a session exists
-- Optional socket_name parameter for specific tmux server
function M.session_exists(session_name, socket_name)
  if not tmux.is_tmux_available() then
    return false
  end

  local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""
  local handle = io.popen(
    string.format(
      [[tmux %shas-session -t '%s' 2>/dev/null && echo "exists"]],
      socket_flag,
      session_name
    )
  )
  if not handle then
    return false
  end

  local result = handle:read("*a")
  handle:close()

  return result:match("exists") ~= nil
end

-- Helper: Find tab template by tmux session name
local function find_template_by_session(session_name)
  -- Try to load tab_templates module
  local ok, tab_templates = pcall(require, "modules.tabs.tab_templates")
  if not ok then
    return nil
  end

  local templates = tab_templates.load_templates()
  if not templates then
    return nil
  end

  -- Search for a template with matching tmux_session
  for name, template in pairs(templates) do
    if template.tmux_session == session_name then
      wezterm.log_info("Found tab template for session: " .. session_name .. " -> " .. name)
      return template
    end
  end

  return nil
end

-- Generate a unique temporary view name for a session
local function generate_view_name(session_name)
  -- Use timestamp + random component to ensure uniqueness
  local timestamp = os.time()
  local random = math.random(1000, 9999)
  return string.format("%s-view-%d-%d", session_name, timestamp, random)
end

-- Find existing unattached view session for a parent session
-- This prevents creating duplicate view sessions when reattaching
local function find_existing_view(session_name, socket_name)
  if not tmux.is_tmux_available() then
    return nil
  end

  local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""

  -- List all sessions and find unattached view sessions for this parent
  -- Format: name|attached|group
  local handle = io.popen(
    string.format(
      [[tmux %slist-sessions -F '#{session_name}|#{session_attached}|#{session_group}' 2>/dev/null]],
      socket_flag
    )
  )

  if not handle then
    return nil
  end

  for line in handle:lines() do
    local name, attached, group = line:match("([^|]+)|([^|]+)|([^|]*)")
    -- Check if this is a view session (has -view- in name) that:
    -- 1. Is NOT currently attached (attached == "0")
    -- 2. Belongs to the parent session (group matches session_name)
    -- 3. Matches the session naming pattern
    if name and name:match("^" .. session_name:gsub("%-", "%%-") .. "%-view%-") then
      if attached == "0" and (group == session_name or group == "") then
        handle:close()
        wezterm.log_info(
          "Found existing unattached view session: "
            .. name
            .. " for parent: "
            .. session_name
        )
        return name
      end
    end
  end

  handle:close()
  return nil
end

-- Spawn a WezTerm tab that attaches to a tmux session with independent view
-- Optional socket parameter for connecting to specific tmux server
function M.spawn_tab_with_session(window, pane, session_name, create_if_missing, socket_name)
  if not M.is_tmux_available() then
    window:toast_notification("Tmux", "tmux not available", nil, 3000)
    return nil
  end

  -- Build socket flag if provided
  local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""

  -- Check if session exists
  local exists = M.session_exists(session_name, socket_name)

  if not exists then
    if create_if_missing then
      local success, msg = M.create_session(session_name, nil, socket_name)
      if not success then
        window:toast_notification("Tmux", "Failed to create session: " .. session_name, nil, 3000)
        return nil
      end
      wezterm.log_info(
        "Created new tmux session: "
          .. session_name
          .. (socket_name and " (socket: " .. socket_name .. ")" or "")
      )
    else
      window:toast_notification("Tmux", "Session not found: " .. session_name, nil, 3000)
      return nil
    end
  end

  -- Spawn a new tab with tmux attach command
  local mux_window = window:mux_window()
  if not mux_window then
    wezterm.log_error("Failed to get mux_window")
    return nil
  end

  -- Spawn new tab
  local tab, new_pane, _ = mux_window:spawn_tab({})

  -- Try to find and reuse an existing unattached view session first
  local view_name = find_existing_view(session_name, socket_name)
  local reusing_view = view_name ~= nil

  if not view_name then
    -- No existing view found, generate a new temporary view name
    view_name = generate_view_name(session_name)
  end

  -- Create independent view using session grouping (or attach to existing)
  -- The view session will be destroyed when detached (detach-on-destroy)
  local attach_cmd
  if reusing_view then
    -- Attach to existing view session
    attach_cmd = string.format(
      "tmux %sattach-session -t '%s'\n",
      socket_flag,
      view_name
    )
    wezterm.log_info(
      "Reusing existing view session: " .. view_name .. " for parent: " .. session_name
    )
  else
    -- Create new view session
    attach_cmd = string.format(
      "tmux %snew-session -t '%s' -s '%s' \\; set-option -t '%s' detach-on-destroy on\n",
      socket_flag,
      session_name,
      view_name,
      view_name
    )
    wezterm.log_info(
      "Creating new view session: " .. view_name .. " for parent: " .. session_name
    )
  end
  new_pane:send_text(attach_cmd)

  -- Look for existing tab template for this session
  local template = find_template_by_session(session_name)

  -- Store tab metadata
  if not wezterm.GLOBAL.custom_tabs then
    wezterm.GLOBAL.custom_tabs = {}
  end

  if template then
    -- Use template's icon and title
    wezterm.GLOBAL.custom_tabs[tostring(tab:tab_id())] = {
      title = template.title or session_name,
      icon_key = helpers.resolve_icon(template.icon), -- Resolve icon to character
      tmux_session = session_name,
      tmux_view = view_name, -- Store the temporary view name
      tmux_workspace = socket_name, -- Store the workspace/socket name
    }
    wezterm.log_info(
      "Spawned tab with template: "
        .. (template.title or session_name)
        .. " (view: "
        .. view_name
        .. ")"
    )
  else
    -- No template found, use generic bash icon
    wezterm.GLOBAL.custom_tabs[tostring(tab:tab_id())] = {
      title = session_name,
      icon_key = wezterm.nerdfonts.md_bash, -- Actual bash icon character
      tmux_session = session_name,
      tmux_view = view_name, -- Store the temporary view name
      tmux_workspace = socket_name, -- Store the workspace/socket name
    }
    wezterm.log_info(
      "Spawned tab with tmux session (no template): "
        .. session_name
        .. " (view: "
        .. view_name
        .. ")"
    )
  end

  return tab
end

-- Spawn tab with session and optionally set custom name/icon
-- This function is used when loading templates with explicit icon/title
-- Optional socket_name parameter for specific tmux server
function M.spawn_tab_with_custom_session(
  window,
  pane,
  session_name,
  tab_name,
  icon,
  create_if_missing,
  socket_name
)
  -- Don't call spawn_tab_with_session here - we want to set our own custom data
  if not M.is_tmux_available() then
    window:toast_notification("Tmux", "tmux not available", nil, 3000)
    return nil
  end

  -- Build socket flag if provided
  local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""

  -- Check if session exists
  local exists = M.session_exists(session_name, socket_name)

  if not exists then
    if create_if_missing then
      local success, msg = M.create_session(session_name, nil, socket_name)
      if not success then
        window:toast_notification("Tmux", "Failed to create session: " .. session_name, nil, 3000)
        return nil
      end
      wezterm.log_info(
        "Created new tmux session: "
          .. session_name
          .. (socket_name and " (socket: " .. socket_name .. ")" or "")
      )
    else
      window:toast_notification("Tmux", "Session not found: " .. session_name, nil, 3000)
      return nil
    end
  end

  -- Spawn a new tab with tmux attach command
  local mux_window = window:mux_window()
  if not mux_window then
    wezterm.log_error("Failed to get mux_window")
    return nil
  end

  -- Spawn new tab
  local tab, new_pane, _ = mux_window:spawn_tab({})

  -- Try to find and reuse an existing unattached view session first
  local view_name = find_existing_view(session_name, socket_name)
  local reusing_view = view_name ~= nil

  if not view_name then
    -- No existing view found, generate a new temporary view name
    view_name = generate_view_name(session_name)
  end

  -- Create independent view using session grouping (or attach to existing)
  -- The view session will be destroyed when detached (detach-on-destroy)
  local attach_cmd
  if reusing_view then
    -- Attach to existing view session
    attach_cmd = string.format(
      "tmux %sattach-session -t '%s'\n",
      socket_flag,
      view_name
    )
    wezterm.log_info(
      "Reusing existing view session: " .. view_name .. " for parent: " .. session_name
    )
  else
    -- Create new view session
    attach_cmd = string.format(
      "tmux %snew-session -t '%s' -s '%s' \\; set-option -t '%s' detach-on-destroy on\n",
      socket_flag,
      session_name,
      view_name,
      view_name
    )
    wezterm.log_info(
      "Creating new view session: " .. view_name .. " for parent: " .. session_name
    )
  end
  new_pane:send_text(attach_cmd)

  -- Use the explicitly provided name/icon (from template)
  if not wezterm.GLOBAL.custom_tabs then
    wezterm.GLOBAL.custom_tabs = {}
  end

  wezterm.GLOBAL.custom_tabs[tostring(tab:tab_id())] = {
    title = tab_name or session_name,
    icon_key = helpers.resolve_icon(icon), -- Resolve icon to character
    tmux_session = session_name,
    tmux_view = view_name, -- Store the temporary view name
    tmux_workspace = socket_name, -- Store the workspace/socket name
  }

  wezterm.log_info(
    "Spawned tab with custom tmux session: "
      .. (tab_name or session_name)
      .. " (view: "
      .. view_name
      .. ")"
  )
  return tab
end

-- Kill a tmux session
function M.kill_session(session_name)
  if not tmux.is_tmux_available() then
    return false
  end

  local cmd = string.format([[tmux kill-session -t '%s' 2>/dev/null]], session_name)
  local result = os.execute(cmd)

  return result == 0 or result == true
end

-- Get tmux session name from current pane (if in tmux)
function M.get_current_session(pane)
  -- Check if we're in a tmux session by looking at TMUX env var
  local handle = io.popen([[printenv TMUX 2>/dev/null]])
  if not handle then
    return nil
  end

  local tmux_env = handle:read("*a")
  handle:close()

  if tmux_env == "" then
    return nil
  end

  -- Get session name
  handle = io.popen([[tmux display-message -p '#S' 2>/dev/null]])
  if not handle then
    return nil
  end

  local session_name = handle:read("*a"):gsub("%s+$", "")
  handle:close()

  return session_name ~= "" and session_name or nil
end

return M
