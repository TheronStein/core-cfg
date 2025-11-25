-- ~/.core/.sys/configs/wezterm/modules/tmux_workspaces.lua
-- Tmux workspace management - handles multiple tmux servers with dedicated configs

local wezterm = require("wezterm")
local act = wezterm.action
local debug_config = require("config.debug")

local M = {}

-- Workspace definitions with metadata
M.workspaces = {
	configuration = {
		name = "configuration",
		display_name = "Configuration",
		shortname = "CFG",
		icon = wezterm.nerdfonts.md_cog,
		color = "#89b4fa", -- Blue
		description = "System configuration and dotfiles",
		default_cwd = "$HOME/.core/cfg",
	},
	development = {
		name = "development",
		display_name = "Development",
		shortname = "DEV",
		icon = wezterm.nerdfonts.md_code_braces,
		color = "#a6e3a1", -- Green
		description = "Software development projects",
		default_cwd = "$HOME/.core/dev",
	},
	documentation = {
		name = "documentation",
		display_name = "Documentation",
		shortname = "DOC",
		icon = wezterm.nerdfonts.md_book_open_variant,
		color = "#f9e2af", -- Yellow
		description = "Documentation and knowledge base",
		default_cwd = "$HOME/docs",
	},
	environment = {
		name = "environment",
		display_name = "Environment",
		shortname = "ENV",
		icon = wezterm.nerdfonts.md_application_cog,
		color = "#fab387", -- Peach
		description = "Environment setup and management",
		default_cwd = "$HOME",
	},
	objective = {
		name = "objective",
		display_name = "Objective",
		shortname = "OBJ",
		icon = wezterm.nerdfonts.md_target,
		color = "#f38ba8", -- Red
		description = "Goal tracking and task management",
		default_cwd = "$HOME/objectives",
	},
	personal = {
		name = "personal",
		display_name = "Personal",
		shortname = "PER",
		icon = wezterm.nerdfonts.md_account,
		color = "#cba6f7", -- Mauve
		description = "Personal projects and files",
		default_cwd = "$HOME/personal",
	},
	system = {
		name = "system",
		display_name = "System",
		shortname = "SYS",
		icon = wezterm.nerdfonts.md_monitor,
		color = "#94e2d5", -- Teal
		description = "System administration and monitoring",
		default_cwd = "$HOME",
	},
	testing = {
		name = "testing",
		display_name = "Testing",
		shortname = "TST",
		icon = wezterm.nerdfonts.md_flask,
		color = "#f5c2e7", -- Pink
		description = "Testing and experimentation",
		default_cwd = "$HOME/test",
	},
	network = {
		name = "network",
		display_name = "Network",
		shortname = "NET",
		icon = wezterm.nerdfonts.md_network,
		color = "#89dceb", -- Sky
		description = "Network administration and tools",
		default_cwd = "$HOME",
	},
	security = {
		name = "security",
		display_name = "Security",
		shortname = "SEC",
		icon = wezterm.nerdfonts.md_shield_check,
		color = "#f38ba8", -- Red
		description = "Security and pentesting tools",
		default_cwd = "$HOME",
	},
	work = {
		name = "work",
		display_name = "Work",
		shortname = "WRK",
		icon = wezterm.nerdfonts.md_briefcase,
		color = "#b4befe", -- Lavender
		description = "Work-related projects",
		default_cwd = "$HOME/work",
	},
}

-- Get workspace config file path
function M.get_workspace_config_path(workspace_name)
	return wezterm.home_dir .. "/.core/.sys/configs/tmux/workspaces/" .. workspace_name .. ".tmux"
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

-- Launch tmux with workspace config
function M.launch_workspace(window, pane, workspace_name, session_name)
	local workspace = M.workspaces[workspace_name]
	if not workspace then
		window:toast_notification("Tmux Workspace", "Unknown workspace: " .. workspace_name, nil, 3000)
		return nil
	end

	-- Check if config file exists
	if not M.workspace_config_exists(workspace_name) then
		window:toast_notification("Tmux Workspace", "Config not found for: " .. workspace.display_name, nil, 3000)
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
			tmux_cmd = string.format("tmux -L '%s' attach-session -t '%s'\n", workspace_name, session_name)
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
		wezterm.log_info("[TMUX_WORKSPACES] Launched: " .. workspace.display_name .. " (socket: " .. workspace_name .. ")")
	end

	window:toast_notification(
		"Tmux Workspace",
		(is_active and "Attached to: " or "Launched: ") .. workspace.display_name,
		nil,
		2000
	)

	return tab
end

-- Show workspace browser/selector
function M.show_workspace_browser(window, pane)
	local choices = {}

	-- Header
	table.insert(choices, {
		label = wezterm.nerdfonts.md_server .. " Tmux Workspaces",
		id = "__header__",
	})

	table.insert(choices, {
		label = "═══════════════════════════════════════════════════",
		id = "__separator__",
	})

	-- Sort workspaces alphabetically
	local sorted_names = {}
	for name, _ in pairs(M.workspaces) do
		table.insert(sorted_names, name)
	end
	table.sort(sorted_names)

	-- Add each workspace
	for _, name in ipairs(sorted_names) do
		local workspace = M.workspaces[name]
		local is_active = M.is_server_active(name)
		local config_exists = M.workspace_config_exists(name)

		-- Status indicators
		local status_icon = is_active and "●" or "○"
		local status_text = is_active and "active" or "inactive"

		if not config_exists then
			status_icon = "⚠"
			status_text = "no config"
		end

		-- Get session count if active
		local session_info = ""
		if is_active then
			local sessions = M.list_workspace_sessions(name)
			if #sessions > 0 then
				session_info = string.format(" (%d session%s)", #sessions, #sessions == 1 and "" or "s")
			end
		end

		local label = string.format(
			"%s  %s %s - %s%s",
			status_icon,
			workspace.icon,
			workspace.display_name,
			status_text,
			session_info
		)

		table.insert(choices, {
			label = label,
			id = name,
		})
	end

	-- Footer
	table.insert(choices, {
		label = "═══════════════════════════════════════════════════",
		id = "__separator2__",
	})

	table.insert(choices, {
		label = wezterm.nerdfonts.md_information .. " Legend: ● active | ○ inactive | ⚠ no config",
		id = "__legend__",
	})

	-- Show selector
	window:perform_action(
		act.InputSelector({
			title = "📡 Tmux Workspaces",
			choices = choices,
			fuzzy = true,
			description = "Select a workspace to launch or attach",
			action = wezterm.action_callback(function(win, p, id)
				-- Ignore headers/separators
				if not id or id:sub(1, 2) == "__" then
					return
				end

				-- Launch the selected workspace
				M.launch_workspace(win, p, id)
			end),
		}),
		pane
	)
end

-- Show unified TMUX Management menu (server start/kill + session attach)
function M.show_workspace_handler_menu(window, pane, from_main_menu)
	local choices = {}
	local used_keys = {}
	local default_choice_index = nil

	-- Back to main menu option (shown but not default)
	if from_main_menu then
		table.insert(choices, {
			label = wezterm.nerdfonts.md_arrow_left .. " Go Back to Main Menu",
			id = "back_to_main",
		})
	end

	-- Attach to Server option (this should be the default selection)
	default_choice_index = #choices + 1
	table.insert(choices, {
		label = wezterm.nerdfonts.md_monitor .. " Attach to Server",
		id = "attach_server",
	})

	-- Kill Server Socket option
	table.insert(choices, {
		label = wezterm.nerdfonts.md_server_remove .. " Kill Server Socket",
		id = "kill_socket",
	})

	-- Separator
	table.insert(choices, {
		label = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
		id = "__separator__",
	})

	-- Sort workspaces alphabetically
	local sorted_names = {}
	for name, _ in pairs(M.workspaces) do
		table.insert(sorted_names, name)
	end
	table.sort(sorted_names)

	-- Add each workspace server with toggle functionality
	for _, name in ipairs(sorted_names) do
		local workspace = M.workspaces[name]
		local is_active = M.is_server_active(name)
		local config_exists = M.workspace_config_exists(name)

		-- Status icon
		local status_icon = is_active and "●" or "○"

		-- Get session count if active
		local session_info = ""
		if is_active then
			local sessions = M.list_workspace_sessions(name)
			if #sessions > 0 then
				session_info = string.format(" (%d session%s)", #sessions, #sessions == 1 and "" or "s")
			end
		end

		-- Try to assign a shortcut key
		local shortcut = ""
		if config_exists then
			-- Try first letter of name
			local first_letter = name:sub(1, 1):upper()
			if not used_keys[first_letter] then
				shortcut = first_letter .. ": "
				used_keys[first_letter] = true
			else
				-- Try subsequent letters
				for i = 2, #name do
					local letter = name:sub(i, i):upper()
					if not used_keys[letter] then
						shortcut = letter .. ": "
						used_keys[letter] = true
						break
					end
				end
			end
		end

		local label = string.format(
			"%s%s %s %s%s",
			shortcut,
			status_icon,
			workspace.icon,
			workspace.display_name,
			session_info
		)

		table.insert(choices, {
			label = label,
			id = config_exists and ("toggle:" .. name) or "__disabled__",
		})
	end

	-- Build alphabet string from used keys
	local alphabet_keys = {}
	for key, _ in pairs(used_keys) do
		table.insert(alphabet_keys, key:lower())
	end
	local alphabet = table.concat(alphabet_keys, "")

	-- Show selector
	window:perform_action(
		act.InputSelector({
			title = "🖥️  TMUX Management",
			choices = choices,
			fuzzy = false,
			alphabet = alphabet,
			-- Default to "Attach to Server" option
			action = wezterm.action_callback(function(win, p, id, label)
				if not id then
					return
				end

				if id == "back_to_main" and from_main_menu then
					-- Go back to main session menu
					local session_manager = require("modules.sessions.manager")
					session_manager.show_menu(win, p)
					return
				elseif id == "attach_server" then
					-- Show server selection, then session selection
					M.show_server_then_session_selector(win, p)
					return
				elseif id == "kill_socket" then
					-- Show list of all active sockets for killing
					M.show_kill_socket_menu(win, p)
					return
				elseif id:match("^toggle:") then
					-- Toggle server on/off
					local workspace_name = id:match("^toggle:(.+)$")
					local is_active = M.is_server_active(workspace_name)

					if is_active then
						M.kill_workspace_server(workspace_name)
						if debug_config.is_enabled("debug_mods_tmux_workspaces") then
						wezterm.log_info("[TMUX_WORKSPACES] Killed: " .. workspace_name)
					end
					else
						M.start_workspace_server(workspace_name)
						if debug_config.is_enabled("debug_mods_tmux_workspaces") then
							wezterm.log_info("[TMUX_WORKSPACES] Started: " .. workspace_name)
						end
					end

					-- Refresh menu
					wezterm.sleep_ms(500)
					M.show_workspace_handler_menu(win, p, from_main_menu)
				end
			end),
		}),
		pane
	)
end

-- Show server selection, then session selection (fzf-style)
function M.show_server_then_session_selector(window, pane)
	local choices = {}

	-- Get all active servers
	local active_servers = {}
	for name, workspace in pairs(M.workspaces) do
		if M.is_server_active(name) then
			table.insert(active_servers, {
				name = name,
				workspace = workspace,
			})
		end
	end

	-- Sort by name
	table.sort(active_servers, function(a, b)
		return a.name < b.name
	end)

	if #active_servers == 0 then
		if debug_config.is_enabled("debug_mods_tmux_workspaces") then
		wezterm.log_warn("[TMUX_WORKSPACES] No active tmux servers found")
	end
		return
	end

	-- Build choices
	for _, server in ipairs(active_servers) do
		local sessions = M.list_workspace_sessions(server.name)
		local session_count = #sessions

		local label = string.format(
			"%s %s (%d session%s)",
			server.workspace.icon,
			server.workspace.display_name,
			session_count,
			session_count == 1 and "" or "s"
		)

		table.insert(choices, {
			label = label,
			id = server.name,
		})
	end

	window:perform_action(
		act.InputSelector({
			title = "📡 Select Tmux Server",
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, server_name)
				if not server_name then
					return
				end

				-- Now show sessions for this server
				M.show_session_selector(win, p, server_name)
			end),
		}),
		pane
	)
end

-- Show session selector for a specific server
function M.show_session_selector(window, pane, server_name)
	local sessions = M.list_workspace_sessions(server_name)
	local choices = {}

	if #sessions == 0 then
		if debug_config.is_enabled("debug_mods_tmux_workspaces") then
		wezterm.log_warn("[TMUX_WORKSPACES] No sessions found on server: " .. server_name)
	end
		return
	end

	-- Build choices
	for _, session in ipairs(sessions) do
		local attached_icon = session.attached and "●" or "○"
		local label = string.format(
			"%s %s (%d window%s)",
			attached_icon,
			session.name,
			session.windows,
			session.windows == 1 and "" or "s"
		)

		table.insert(choices, {
			label = label,
			id = session.name,
		})
	end

	window:perform_action(
		act.InputSelector({
			title = "📺 Select Session on " .. server_name,
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, session_name)
				if not session_name then
					return
				end

				-- Attach to the selected session
				M.launch_workspace(win, p, server_name, session_name)
			end),
		}),
		pane
	)
end

-- Show menu to kill server sockets
function M.show_kill_socket_menu(window, pane)
	local choices = {}

	-- Get all active servers from /tmp/
	local uid = os.getenv("UID")
	if not uid then
		local handle = io.popen("id -u")
		if handle then
			uid = handle:read("*a"):gsub("%s+$", "")
			handle:close()
		end
	end

	if not uid or uid == "" then
		wezterm.log_error("Failed to get UID")
		return
	end

	local tmux_dir = "/tmp/tmux-" .. uid
	local handle = io.popen(string.format("ls -1 '%s' 2>/dev/null", tmux_dir))

	if not handle then
		if debug_config.is_enabled("debug_mods_tmux_workspaces") then
		wezterm.log_warn("[TMUX_WORKSPACES] No tmux sockets found in " .. tmux_dir)
	end
		return
	end

	local sockets = {}
	for socket_name in handle:lines() do
		-- Get workspace info if available
		local workspace = M.workspaces[socket_name]
		local display_name = workspace and workspace.display_name or socket_name
		local icon = workspace and workspace.icon or wezterm.nerdfonts.md_server

		-- Get session count
		local sessions = M.list_workspace_sessions(socket_name)
		local session_info = string.format(" (%d session%s)", #sessions, #sessions == 1 and "" or "s")

		table.insert(sockets, {
			label = string.format("%s %s%s", icon, display_name, session_info),
			id = socket_name,
		})
	end
	handle:close()

	if #sockets == 0 then
		if debug_config.is_enabled("debug_mods_tmux_workspaces") then
		wezterm.log_warn("[TMUX_WORKSPACES] No active tmux sockets found")
	end
		return
	end

	window:perform_action(
		act.InputSelector({
			title = "🗑️  Kill Tmux Server Socket",
			choices = sockets,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, socket_name)
				if not socket_name then
					return
				end

				-- Kill the server
				M.kill_workspace_server(socket_name)
				if debug_config.is_enabled("debug_mods_tmux_workspaces") then
				wezterm.log_info("[TMUX_WORKSPACES] Killed server: " .. socket_name)
			end
			end),
		}),
		pane
	)
end

-- Get workspace info for a given tmux server socket name
function M.get_workspace_info(socket_name)
	return M.workspaces[socket_name]
end

-- Kill a workspace server
function M.kill_workspace_server(workspace_name)
	if debug_config.is_enabled("debug_mods_tmux_workspaces") then
		wezterm.log_info("[TMUX_WORKSPACES] Killing server: " .. workspace_name)
	end
	local cmd = string.format("tmux -L '%s' kill-server", workspace_name)
	local success, exit_type, exit_code = os.execute(cmd)
	if success then
		if debug_config.is_enabled("debug_mods_tmux_workspaces") then
			wezterm.log_info("[TMUX_WORKSPACES] Successfully killed server: " .. workspace_name)
		end
	else
		if debug_config.is_enabled("debug_mods_tmux_workspaces") then
			wezterm.log_error("[TMUX_WORKSPACES] Failed to kill server: " .. workspace_name .. " (exit_code: " .. tostring(exit_code) .. ")")
		end
	end

	-- Also try to remove the socket file directly if kill-server failed
	local uid = os.getenv("UID")
	if not uid then
		local handle = io.popen("id -u")
		if handle then
			uid = handle:read("*a"):gsub("%s+$", "")
			handle:close()
		end
	end

	if uid and uid ~= "" then
		local socket_path = "/tmp/tmux-" .. uid .. "/" .. workspace_name
		os.execute("rm -f '" .. socket_path .. "' 2>/dev/null")
	end
end

-- Start a workspace server
function M.start_workspace_server(workspace_name)
	local workspace = M.workspaces[workspace_name]
	if not workspace then
		wezterm.log_error("Unknown workspace: " .. workspace_name)
		return
	end

	local config_path = M.get_workspace_config_path(workspace_name)
	if not M.workspace_config_exists(workspace_name) then
		wezterm.log_error("Config not found for: " .. workspace.display_name)
		return
	end

	-- Start server with workspace config - session name matches workspace name
	local cmd = string.format("tmux -f '%s' -L '%s' new-session -d -s '%s' 2>/dev/null", config_path, workspace_name, workspace_name)
	os.execute(cmd)
	if debug_config.is_enabled("debug_mods_tmux_workspaces") then
		wezterm.log_info("[TMUX_WORKSPACES] Started server: " .. workspace_name .. " with config: " .. config_path)
	end
end

return M
