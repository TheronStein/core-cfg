-- ~/.core/.sys/configs/wezterm/modules/tmux_sessions.lua
-- Tmux session management - spawn tabs that attach to tmux sessions

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Check if tmux is available
function M.is_tmux_available()
	local handle = io.popen("command -v tmux 2>/dev/null")
	if not handle then
		return false
	end
	local result = handle:read("*a")
	handle:close()
	return result ~= ""
end

-- List all tmux sessions with metadata
-- Optional socket_name parameter for specific tmux server
function M.list_sessions(socket_name)
	if not M.is_tmux_available() then
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
		local name, windows, attached, created, group = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]*)")
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
		string.format([[tmux list-windows -t '%s' -F '#{window_index}:#{window_name}:#{window_panes}' 2>/dev/null]], session_name)
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
	if not M.is_tmux_available() then
		return false, "tmux not available"
	end

	cwd = cwd or wezterm.home_dir
	local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""

	local cmd = string.format([[tmux %snew-session -d -s '%s' -c '%s' 2>/dev/null]], socket_flag, session_name, cwd)
	local result = os.execute(cmd)

	return result == 0 or result == true, result == 0 or result == true and "Session created" or "Failed to create session"
end

-- Check if a session exists
-- Optional socket_name parameter for specific tmux server
function M.session_exists(session_name, socket_name)
	if not M.is_tmux_available() then
		return false
	end

	local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""
	local handle = io.popen(string.format([[tmux %shas-session -t '%s' 2>/dev/null && echo "exists"]], socket_flag, session_name))
	if not handle then
		return false
	end

	local result = handle:read("*a")
	handle:close()

	return result:match("exists") ~= nil
end

-- Helper: Convert icon key to actual character, or return as-is if already a character
local function resolve_icon(icon_value)
	if not icon_value or icon_value == "" then
		return wezterm.nerdfonts.md_bash -- Default to bash icon
	end

	-- If it's already a single unicode character (not a key), return it
	if #icon_value <= 4 then -- Unicode chars are typically 1-4 bytes in UTF-8
		return icon_value
	end

	-- Try to resolve as nerdfonts key (e.g., "md_bash" -> actual character)
	local resolved = wezterm.nerdfonts[icon_value]
	if resolved then
		wezterm.log_info("Resolved icon key '" .. icon_value .. "' to character")
		return resolved
	end

	-- Fallback: return as-is (might be the character itself)
	return icon_value
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
			wezterm.log_info("Created new tmux session: " .. session_name .. (socket_name and " (socket: " .. socket_name .. ")" or ""))
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

	-- Generate temporary view name for this terminal
	local view_name = generate_view_name(session_name)

	-- Create independent view using session grouping
	-- The view session will be destroyed when detached (detach-on-destroy)
	local attach_cmd = string.format(
		"tmux %snew-session -t '%s' -s '%s' \\; set-option -t '%s' detach-on-destroy on\n",
		socket_flag,
		session_name,
		view_name,
		view_name
	)
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
			icon_key = resolve_icon(template.icon), -- Resolve icon to character
			tmux_session = session_name,
			tmux_view = view_name, -- Store the temporary view name
			tmux_workspace = socket_name, -- Store the workspace/socket name
		}
		wezterm.log_info("Spawned tab with template: " .. (template.title or session_name) .. " (view: " .. view_name .. ")")
	else
		-- No template found, use generic bash icon
		wezterm.GLOBAL.custom_tabs[tostring(tab:tab_id())] = {
			title = session_name,
			icon_key = wezterm.nerdfonts.md_bash, -- Actual bash icon character
			tmux_session = session_name,
			tmux_view = view_name, -- Store the temporary view name
			tmux_workspace = socket_name, -- Store the workspace/socket name
		}
		wezterm.log_info("Spawned tab with tmux session (no template): " .. session_name .. " (view: " .. view_name .. ")")
	end

	return tab
end

-- Spawn tab with session and optionally set custom name/icon
-- This function is used when loading templates with explicit icon/title
-- Optional socket_name parameter for specific tmux server
function M.spawn_tab_with_custom_session(window, pane, session_name, tab_name, icon, create_if_missing, socket_name)
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
			wezterm.log_info("Created new tmux session: " .. session_name .. (socket_name and " (socket: " .. socket_name .. ")" or ""))
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

	-- Generate temporary view name for this terminal
	local view_name = generate_view_name(session_name)

	-- Create independent view using session grouping
	-- The view session will be destroyed when detached (detach-on-destroy)
	local attach_cmd = string.format(
		"tmux %snew-session -t '%s' -s '%s' \\; set-option -t '%s' detach-on-destroy on\n",
		socket_flag,
		session_name,
		view_name,
		view_name
	)
	new_pane:send_text(attach_cmd)

	-- Use the explicitly provided name/icon (from template)
	if not wezterm.GLOBAL.custom_tabs then
		wezterm.GLOBAL.custom_tabs = {}
	end

	wezterm.GLOBAL.custom_tabs[tostring(tab:tab_id())] = {
		title = tab_name or session_name,
		icon_key = resolve_icon(icon), -- Resolve icon to character
		tmux_session = session_name,
		tmux_view = view_name, -- Store the temporary view name
		tmux_workspace = socket_name, -- Store the workspace/socket name
	}

	wezterm.log_info("Spawned tab with custom tmux session: " .. (tab_name or session_name) .. " (view: " .. view_name .. ")")
	return tab
end

-- Show tmux session selector
-- Optional socket_name parameter to show sessions from specific workspace
function M.show_session_selector(window, pane, socket_name)
	local sessions = M.list_sessions(socket_name)

	if #sessions == 0 then
		local workspace_info = socket_name and " in workspace '" .. socket_name .. "'" or ""
		window:toast_notification("Tmux", "No tmux sessions found" .. workspace_info, nil, 3000)
		return
	end

	local choices = {}

	-- Header with workspace info if applicable
	local header_text = socket_name and ("Sessions in workspace: " .. socket_name) or "Select a tmux session to attach:"
	table.insert(choices, {
		label = header_text,
		id = "__header__",
	})

	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator__",
	})

	-- Add sessions
	for _, session in ipairs(sessions) do
		local status_icon = session.attached and "📌" or "○"
		local label = string.format("%s %s (%d windows)", status_icon, session.name, session.windows)

		table.insert(choices, {
			label = label,
			id = session.name,
		})
	end

	-- Add create new option
	table.insert(choices, {
		label = "─────────────────────────────",
		id = "__separator2__",
	})

	table.insert(choices, {
		label = "➕ Create new session",
		id = "__create__",
	})

	local title = socket_name and ("📺 Tmux Sessions (" .. socket_name .. ")") or "📺 Tmux Sessions"

	window:perform_action(
		act.InputSelector({
			title = title,
			choices = choices,
			fuzzy = true,
			action = wezterm.action_callback(function(win, p, id)
				if not id or id:sub(1, 2) == "__" then
					if id == "__create__" then
						M.prompt_create_session(win, p, socket_name)
					end
					return
				end

				-- Spawn tab with selected session (with socket if specified)
				local tab = M.spawn_tab_with_session(win, p, id, false, socket_name)
				if tab then
					win:toast_notification("Tmux", "Attached to session: " .. id, nil, 2000)
				end
			end),
		}),
		pane
	)
end

-- Prompt to create a new session
-- Optional socket_name parameter for specific tmux server
function M.prompt_create_session(window, pane, socket_name)
	local description = socket_name
			and ("Enter new tmux session name (workspace: " .. socket_name .. "):")
		or "Enter new tmux session name:"

	window:perform_action(
		act.PromptInputLine({
			description = description,
			action = wezterm.action_callback(function(win, p, session_name)
				if not session_name or session_name == "" then
					return
				end

				-- Check if session already exists
				if M.session_exists(session_name, socket_name) then
					win:toast_notification("Tmux", "Session already exists: " .. session_name, nil, 3000)
					return
				end

				-- Create and attach to session (with socket if specified)
				local tab = M.spawn_tab_with_session(win, p, session_name, true, socket_name)
				if tab then
					win:toast_notification("Tmux", "Created and attached to: " .. session_name, nil, 2000)
				end
			end),
		}),
		pane
	)
end

-- Kill a tmux session
function M.kill_session(session_name)
	if not M.is_tmux_available() then
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
	if M.session_exists(view_name) then
		wezterm.log_info("Cleaning up temporary tmux view: " .. view_name)
		M.kill_session(view_name)
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
			if not M.session_exists(session_name, socket_name) then
				wezterm.log_info("Tmux session '" .. session_name .. "' no longer exists, marking tab for closure")
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
	if not M.is_tmux_available() then
		return
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

	-- Get list of all tmux sockets/workspaces to check
	local sockets_to_check = { nil } -- nil = default socket

	-- Try to load tmux workspaces to check workspace-specific sockets
	local ok, tmux_workspaces = pcall(require, "modules.tmux.workspaces")
	if ok and tmux_workspaces and tmux_workspaces.workspaces then
		for workspace_name, _ in pairs(tmux_workspaces.workspaces) do
			table.insert(sockets_to_check, workspace_name)
		end
	end

	-- Check all sockets (default + workspaces)
	for _, socket_name in ipairs(sockets_to_check) do
		local all_sessions = M.list_sessions(socket_name)

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
				if not is_tracked and not session_info.attached then
					-- This is an orphaned view - kill it
					local socket_info = socket_name and (" [socket: " .. socket_name .. "]") or ""
					wezterm.log_info(
						"Cleaning up orphaned view session: "
							.. session_name
							.. " (group: "
							.. (session_info.group or "none")
							.. ")"
							.. socket_info
					)

					-- Build kill command with socket flag if needed
					local socket_flag = socket_name and string.format("-L '%s' ", socket_name) or ""
					local kill_cmd = string.format([[tmux %skill-session -t '%s' 2>/dev/null]], socket_flag, session_name)

					if os.execute(kill_cmd) == 0 or os.execute(kill_cmd) == true then
						cleaned_count = cleaned_count + 1
					else
						wezterm.log_warn("Failed to kill orphaned view session: " .. session_name)
					end
				elseif is_tracked or session_info.attached then
					-- Log why we're skipping this session (debug only)
					local reason = is_tracked and "tracked" or "attached"
					-- wezterm.log_info("Skipping cleanup of " .. reason .. " view session: " .. session_name)
				end
			end
		end
	end

	if cleaned_count > 0 then
		wezterm.log_info("Cleaned up " .. cleaned_count .. " orphaned view session(s)")
	end

	return cleaned_count
end

-- Show workspace selector first, then session selector
-- This provides a two-step workflow: workspace -> sessions
function M.show_workspace_then_session_selector(window, pane)
	-- Try to load tmux workspaces module
	local ok, tmux_workspaces = pcall(require, "modules.tmux.workspaces")
	if not ok or not tmux_workspaces then
		window:toast_notification("Tmux", "Workspace module not available", nil, 3000)
		wezterm.log_error("Failed to load tmux_workspaces module")
		return
	end

	local choices = {}

	-- Header
	table.insert(choices, {
		label = wezterm.nerdfonts.md_server .. " Select Tmux Workspace",
		id = "__header__",
	})

	table.insert(choices, {
		label = "═══════════════════════════════════════════════════",
		id = "__separator__",
	})

	-- Sort workspaces alphabetically
	local sorted_names = {}
	for name, _ in pairs(tmux_workspaces.workspaces) do
		table.insert(sorted_names, name)
	end
	table.sort(sorted_names)

	-- Add each workspace with status info
	for _, name in ipairs(sorted_names) do
		local workspace = tmux_workspaces.workspaces[name]
		local is_active = tmux_workspaces.is_server_active(name)
		local config_exists = tmux_workspaces.workspace_config_exists(name)

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
			local sessions = M.list_sessions(name)
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

	-- Show workspace selector
	window:perform_action(
		act.InputSelector({
			title = "📡 Tmux Workspaces - Select to browse sessions",
			choices = choices,
			fuzzy = true,
			description = "Select a workspace to view its sessions",
			action = wezterm.action_callback(function(win, p, workspace_id)
				-- Ignore headers/separators
				if not workspace_id or workspace_id:sub(1, 2) == "__" then
					return
				end

				-- Check if workspace is active
				local is_active = tmux_workspaces.is_server_active(workspace_id)
				if not is_active then
					-- Launch the workspace
					local workspace = tmux_workspaces.workspaces[workspace_id]
					win:toast_notification(
						"Tmux",
						"Launching workspace: " .. workspace.display_name,
						nil,
						2000
					)
					tmux_workspaces.launch_workspace(win, p, workspace_id)
					return
				end

				-- Show sessions for this workspace
				M.show_session_selector(win, p, workspace_id)
			end),
		}),
		pane
	)
end

return M
