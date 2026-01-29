-- ~/.core/.sys/configs/wezterm/modules/tmux_workspaces.lua
-- Tmux workspace management - handles multiple tmux servers with dedicated configs

local wezterm = require("wezterm")
local act = wezterm.action
local paths = require("utils.paths")
local debug_config = require("config.debug")
local tmux_utils = require("modules.tmux.utils")

local M = {}

-- Workspace definitions with metadata
M.workspaces = {
  chaoscore_ide = {
    name = "core-ide",
    display_name = "[CHAOSCORE]",
    shortname = "CORE",
    icon = wezterm.nerdfonts.md_cog,
    color = "#01F9C6",
    description = "Core IDE workspace for ChaosCore development",
    default_cwd = "$HOME/.core/.sys",
  },
  configuration = {
    name = "configuration",
    display_name = "Configuration",
    shortname = "CFG",
    icon = wezterm.nerdfonts.md_cog,
    color = "#89b4fa", -- Blue
    description = "System configuration and dotfiles",
    default_cwd = "$CORE_CFG",
  },
  development = {
    name = "development",
    display_name = "Development",
    shortname = "DEV",
    icon = wezterm.nerdfonts.md_code_braces,
    color = "#a6e3a1", -- Green
    description = "Software development projects",
    default_cwd = "$CORE_PROJ",
  },
  documentation = {
    name = "documentation",
    display_name = "Documentation",
    shortname = "DOC",
    icon = wezterm.nerdfonts.md_book_open_variant,
    color = "#f9e2af", -- Yellow
    description = "Documentation and knowledge base",
    default_cwd = "$CORE_CORTEX",
  },
  environment = {
    name = "environment",
    display_name = "Environment",
    shortname = "ENV",
    icon = wezterm.nerdfonts.md_application_cog,
    color = "#fab387", -- Peach
    description = "Environment setup and management",
    default_cwd = "$CORE_ENV",
  },
  objective = {
    name = "objective",
    display_name = "Objective",
    shortname = "OBJ",
    icon = wezterm.nerdfonts.md_target,
    color = "#f38ba8", -- Red
    description = "Goal tracking and task management",
    default_cwd = "$CORE_LIFE",
  },
  personal = {
    name = "personal",
    display_name = "Personal",
    shortname = "PER",
    icon = wezterm.nerdfonts.md_account,
    color = "#cba6f7", -- Mauve
    description = "Personal projects and files",
    default_cwd = "$CORE_LIFE",
  },
  system = {
    name = "system",
    display_name = "System",
    shortname = "SYS",
    icon = wezterm.nerdfonts.md_monitor,
    color = "#94e2d5", -- Teal
    description = "System administration and monitoring",
    default_cwd = "$CORE_SYS",
  },
  testing = {
    name = "testing",
    display_name = "Testing",
    shortname = "TST",
    icon = wezterm.nerdfonts.md_flask,
    color = "#f5c2e7", -- Pink
    description = "Testing and experimentation",
    default_cwd = "$CORE_SYS/env",
  },
  network = {
    name = "network",
    display_name = "Network",
    shortname = "NET",
    icon = wezterm.nerdfonts.md_network,
    color = "#89dceb", -- Sky
    description = "Network administration and tools",
    default_cwd = "$CORE_SYS",
  },
  security = {
    name = "security",
    display_name = "Security",
    shortname = "SEC",
    icon = wezterm.nerdfonts.md_shield_check,
    color = "#f38ba8", -- Red
    description = "Security and pentesting tools",
    default_cwd = "$CORE_SYS",
  },
  work = {
    name = "work",
    display_name = "Work",
    shortname = "WRK",
    icon = wezterm.nerdfonts.md_briefcase,
    color = "#b4befe", -- Lavender
    description = "Work-related projects",
    default_cwd = "$CORE/.work",
  },
}

-- Get workspace info by name (called by tabline/tabs.lua, tmux_server.lua, etc.)
function M.get_workspace_info(workspace_name)
  return M.workspaces[workspace_name]
end

-- Check if a tmux server socket is active
function M.is_server_active(workspace_name)
  local uid = os.getenv("UID")
  if not uid then
    -- Fallback to getting UID
    local handle = io.popen("id -u")
    if handle then
      uid = handle:read("*a"):gsub("%s+$", "")
      handle:close()
    end
  end

  if not uid or uid == "" then
    wezterm.log_error("Failed to get UID for tmux socket detection")
    return false
  end

  local tmux_dir = "/tmp/tmux-" .. uid
  local socket_path = tmux_dir .. "/" .. workspace_name

  -- Use test -S to check if socket exists (more reliable than io.open for sockets)
  local handle = io.popen(string.format("test -S '%s' && echo exists", socket_path))
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:match("exists") ~= nil
  end

  return false
end


-- Get sessions for a specific tmux server
function M.list_workspace_sessions(workspace_name)
	local sessions = {}
	local handle = io.popen(
		string.format(
			[[tmux -L '%s' list-sessions -F '#{session_name}|#{session_windows}|#{session_attached}|#{session_created}' 2>/dev/null]],
			workspace_name
		)
	)

	if not handle then
		return sessions
	end

	for line in handle:lines() do
		local name, windows, attached, created = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
		if name then
			table.insert(sessions, {
				name = name,
				windows = tonumber(windows) or 0,
				attached = attached == "1",
				created = created or "",
				workspace = workspace_name,
			})
		end
	end

	handle:close()
	return sessions
end

-- Get workspace config file path
function M.get_workspace_config_path(workspace_name)
  if not M.workspaces[workspace_name] then
    workspace_name = "default"
    return paths.TMUX_CONFIG .. "tmux.conf"
  end
  return paths.TMUX_CONFIG .. "/workspaces/" .. workspace_name .. ".tmux"
end

-- Check if workspace config exists
function M.workspace_config_exists(workspace_name)
  local config_path = M.get_workspace_config_path(workspace_name)
  local f = io.open(config_path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Launch tmux with workspace config
function M.launch_workspace(window, pane, workspace_name, session_name)
  local workspace = M.workspaces[workspace_name]
  if not workspace then
    window:toast_notification("Tmux Workspace", "Unknown workspace: " .. workspace_name, nil, 3000)
    return nil
  end

  -- Check if config file exists
  if not M.workspace_config_exists(workspace_name) then
    window:toast_notification(
      "Tmux Workspace",
      "Config not found for: " .. workspace.display_name,
      nil,
      3000
    )
    return nil
  end

  local config_path = M.get_workspace_config_path(workspace_name)
  local mux_window = window:mux_window()
  if not mux_window then
    wezterm.log_error("Failed to get mux_window")
    return nil
  end

  -- Spawn new tab
  local tab, new_pane, _ = mux_window:spawn_tab({})

  -- Build tmux command to launch with specific config and socket
  -- If server already exists, just attach; otherwise create new session
  local is_active = M.is_server_active(workspace_name)
  local tmux_cmd

  if is_active then
    -- Server exists, attach to specific session if provided
    if session_name then
      tmux_cmd =
        string.format("tmux -L '%s' attach-session -t '%s'\n", workspace_name, session_name)
    else
      tmux_cmd = string.format("tmux -L '%s' attach-session\n", workspace_name)
    end
  else
    -- Start new server with config file
    tmux_cmd = string.format("tmux -f '%s' -L '%s' new-session\n", config_path, workspace_name)
  end

  new_pane:send_text(tmux_cmd)

  -- Store tab metadata
  if not wezterm.GLOBAL.custom_tabs then
    wezterm.GLOBAL.custom_tabs = {}
  end

  wezterm.GLOBAL.custom_tabs[tostring(tab:tab_id())] = {
    title = workspace.display_name,
    icon_key = workspace.icon,
    tmux_workspace = workspace_name,
    tmux_workspace_color = workspace.color,
  }

  if debug_config.is_enabled("debug_mods_tmux_workspaces") then
    wezterm.log_info(
      "[TMUX_WORKSPACES] Launched: "
        .. workspace.display_name
        .. " (socket: "
        .. workspace_name
        .. ")"
    )
  end

  window:toast_notification(
    "Tmux Workspace",
    (is_active and "Attached to: " or "Launched: ") .. workspace.display_name,
    nil,
    2000
  )
  return tab
end

return M
