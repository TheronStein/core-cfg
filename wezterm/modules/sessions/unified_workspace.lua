-- Unified Workspace-Session Manager
-- Treats workspaces and sessions as a single concept
-- One workspace per WezTerm client (strict isolation)
--
-- Core Principles:
-- 1. Workspace = Session (same thing, not separate concepts)
-- 2. Each WezTerm client is bound to ONE workspace
-- 3. "Create workspace" renames default → initializes new session
-- 4. "Switch workspace" spawns/focuses different client
-- 5. Menu only shows workspaces without running clients

local wezterm = require("wezterm")
local act = wezterm.action
local paths = require("utils.paths")
local isolation = require("modules.sessions.workspace_isolation")

local M = {}

-- Session storage directory
local session_dir = paths.WEZTERM_DATA .. "/sessions"

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Ensure session directory exists
local function ensure_session_dir()
	os.execute('mkdir -p "' .. session_dir .. '"')
	return true
end

-- Extract path from file:// URL or return as-is
local function extract_path(cwd)
	if not cwd then
		return wezterm.home_dir
	end

	-- Handle table format with file_path
	if type(cwd) == "table" and cwd.file_path then
		return cwd.file_path
	end

	-- Convert to string
	cwd = tostring(cwd)

	-- Handle file:// URLs
	if cwd:match("^file://") then
		local path = cwd:gsub("^file://[^/]+", "") or cwd:gsub("^file://", "")
		return path
	end

	return cwd
end

-- Get workspace icon from global state
local function get_workspace_icon(workspace_name)
	if wezterm.GLOBAL.workspace_icons and wezterm.GLOBAL.workspace_icons[workspace_name] then
		return wezterm.GLOBAL.workspace_icons[workspace_name]
	end
	return ""
end

-- Set workspace icon in global state and metadata
local function set_workspace_icon(workspace_name, icon)
	if not wezterm.GLOBAL.workspace_icons then
		wezterm.GLOBAL.workspace_icons = {}
	end
	wezterm.GLOBAL.workspace_icons[workspace_name] = icon or ""

	-- Also save to persistent metadata
	local workspace_metadata = require("modules.sessions.workspace_metadata")
	workspace_metadata.set_icon(workspace_name, icon or "")
end

-- List all workspace names (from mux)
local function list_all_workspaces()
	local workspaces = wezterm.mux.get_workspace_names()
	table.sort(workspaces)
	return workspaces
end

-- List ONLY workspaces that don't have a running client
-- This is key for the isolation model
local function list_available_workspaces()
	local all_workspaces = list_all_workspaces()
	local running_clients = isolation.get_running_clients()

	-- Build set of running workspace names
	local running = {}
	for _, client in ipairs(running_clients) do
		running[client.workspace] = true
	end

	-- Filter to only available (not running) workspaces
	local available = {}
	for _, ws in ipairs(all_workspaces) do
		if not running[ws] then
			table.insert(available, ws)
		end
	end

	return available
end

-- List saved session files
local function list_session_files()
	ensure_session_dir()
	local sessions = {}
	local handle = io.popen('ls -1 "' .. session_dir .. '"/*.json 2>/dev/null')

	if handle then
		for file in handle:lines() do
			local name = file:match("([^/]+)%.json$")
			if name then
				table.insert(sessions, name)
			end
		end
		handle:close()
	end

	table.sort(sessions)
	return sessions
end

-- Build a map of workspace -> window_id for running clients
-- This caches the expensive `wezterm cli list` call
local function get_running_workspace_map()
	local running_map = {}

	-- Use pcall to safely handle any errors from isolation module
	local success, clients = pcall(isolation.get_running_clients)
	if not success then
		wezterm.log_warn("[UNIFIED_WORKSPACE] Failed to get running clients: " .. tostring(clients))
		return running_map
	end

	if not clients then
		return running_map
	end

	for _, client in ipairs(clients) do
		if client.workspace and client.window_id then
			running_map[client.workspace] = client.window_id
		end
	end

	return running_map
end

-- ============================================================================
-- CORE WORKSPACE OPERATIONS
-- ============================================================================

-- Create workspace (renames default if in default, otherwise spawns new client)
function M.create_workspace(window, pane)
	local current_workspace = window:active_workspace()
	local tab_rename = require("modules.tabs.tab_rename")

	-- Prompt for workspace name
	window:perform_action(
		act.PromptInputLine({
			description = "🆕 Create workspace name:",
			action = wezterm.action_callback(function(win, p, workspace_name)
				if not workspace_name or workspace_name == "" then
					return
				end

				-- Check if workspace already exists (safe check)
				local success, existing_window_id = pcall(isolation.find_client_for_workspace, workspace_name)
				if success and existing_window_id then
					win:toast_notification(
						"WezTerm",
						"⚠️  Workspace '" .. workspace_name .. "' already running (window " .. existing_window_id .. ")",
						nil,
						3000
					)
					return
				end

				-- Show icon picker
				tab_rename.show_icon_set_menu(win, p, function(inner_win, inner_pane, full_title, icon, title)
					-- Store workspace icon
					set_workspace_icon(workspace_name, icon or "")

					local display_name = (icon and icon ~= "") and (icon .. " " .. workspace_name) or workspace_name

					-- If we're in default workspace, RENAME it instead of creating new
					if current_workspace == "default" then
						wezterm.log_info("[UNIFIED_WORKSPACE] Renaming default workspace to: " .. workspace_name)

						-- Switch to the new workspace name (this effectively renames it for the current window)
						inner_win:perform_action(act.SwitchToWorkspace({ name = workspace_name }), inner_pane)

						-- Count tabs in current window
						local mux_window = inner_win:mux_window()
						local tabs_moved = mux_window and #mux_window:tabs() or 0

						inner_win:toast_notification(
							"WezTerm",
							"✅ Initialized workspace: " .. display_name .. " (" .. tabs_moved .. " tabs)",
							nil,
							3000
						)
					else
						-- We're in a named workspace, spawn NEW isolated client
						wezterm.log_info("[UNIFIED_WORKSPACE] Creating isolated workspace: " .. workspace_name)

						local spawn_success, spawn_result = pcall(isolation.spawn_workspace_client, workspace_name)

						if spawn_success and spawn_result then
							inner_win:toast_notification("WezTerm", "✅ Created isolated workspace: " .. display_name, nil, 3000)
							wezterm.emit("workspace-created", inner_win, workspace_name)
						else
							inner_win:toast_notification("WezTerm", "❌ Failed to create workspace: " .. tostring(spawn_result), nil, 3000)
						end
					end
				end)
			end),
		}),
		pane
	)
end

-- Switch workspace (spawns/focuses different client)
function M.switch_workspace(window, pane)
	local all_workspaces = list_all_workspaces()
	local current_workspace = window:active_workspace()

	if #all_workspaces == 0 then
		window:toast_notification("WezTerm", "No workspaces available", nil, 2000)
		return
	end

	-- Cache running clients ONCE (this was the crash culprit!)
	local running_map = get_running_workspace_map()

	-- Build choices with visual indicators
	local choices = {}
	for _, ws in ipairs(all_workspaces) do
		local icon = get_workspace_icon(ws)
		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		local prefix = (ws == current_workspace) and "▶ " or "  "

		-- Use cached map instead of calling find_client for each workspace
		local running_indicator = running_map[ws] and " 🟢" or ""

		table.insert(choices, {
			label = prefix .. icon_prefix .. ws .. running_indicator,
			id = ws
		})
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					-- Always use isolation mode
					wezterm.log_info("[UNIFIED_WORKSPACE] Switching to workspace: " .. id)
					local success, result = pcall(isolation.switch_to_workspace, id)

					if success and result then
						win:toast_notification("WezTerm", "📂 Switched to workspace: " .. id, nil, 2000)
					else
						win:toast_notification("WezTerm", "❌ Failed to switch workspace: " .. tostring(result), nil, 2000)
					end
				end
			end),
			title = "📂 Switch Workspace",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Rename current workspace
function M.rename_workspace(window, pane)
	local current = window:active_workspace()
	local initial_value = (current == "default") and "" or current
	local tab_rename = require("modules.tabs.tab_rename")

	-- Prompt for new workspace name
	window:perform_action(
		act.PromptInputLine({
			description = "✏️  Rename workspace '" .. current .. "' to:",
			initial_value = initial_value,
			action = wezterm.action_callback(function(win, p, new_name)
				if not new_name or new_name == "" or new_name == current then
					return
				end

				-- Show icon picker
				tab_rename.show_icon_set_menu(win, p, function(inner_win, inner_pane, full_title, icon, title)
					-- Store workspace icon
					set_workspace_icon(new_name, icon or "")

					-- Remove old workspace icon if it existed
					if wezterm.GLOBAL.workspace_icons and wezterm.GLOBAL.workspace_icons[current] then
						wezterm.GLOBAL.workspace_icons[current] = nil
					end

					-- Switch to the new workspace name (this renames it for the current window)
					inner_win:perform_action(act.SwitchToWorkspace({ name = new_name }), inner_pane)

					-- Count tabs in current window
					local mux_window = inner_win:mux_window()
					local tabs_moved = mux_window and #mux_window:tabs() or 0

					local display_name = (icon and icon ~= "") and (icon .. " " .. new_name) or new_name
					local message = (current == "default")
						and "✅ Initialized workspace: " .. display_name .. " (" .. tabs_moved .. " tabs)"
						or "✅ Renamed to: " .. display_name .. " (" .. tabs_moved .. " tabs)"

					inner_win:toast_notification("WezTerm", message, nil, 3000)
				end)
			end),
		}),
		pane
	)
end

-- Close workspace (kills client)
function M.close_workspace(window, pane)
	local workspaces = list_all_workspaces()
	local current_workspace = window:active_workspace()

	if #workspaces <= 1 then
		window:toast_notification("WezTerm", "Cannot close the only workspace", nil, 2000)
		return
	end

	-- Cache running clients ONCE
	local running_map = get_running_workspace_map()

	local choices = {}
	for _, ws in ipairs(workspaces) do
		local icon = get_workspace_icon(ws)
		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		local marker = (ws == current_workspace) and " [current]" or ""

		-- Use cached map
		local running_indicator = running_map[ws] and " 🟢" or ""

		table.insert(choices, {
			label = icon_prefix .. ws .. marker .. running_indicator,
			id = ws
		})
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					wezterm.log_info("[UNIFIED_WORKSPACE] Closing workspace: " .. id)

					local success, result = pcall(isolation.close_workspace_client, id)

					if success and result then
						win:toast_notification("WezTerm", "🗑️  Closed workspace: " .. id, nil, 3000)
					else
						win:toast_notification("WezTerm", "❌ Failed to close workspace: " .. tostring(result), nil, 3000)
					end
				end
			end),
			title = "🗑️  Close Workspace",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- ============================================================================
-- SESSION SAVE/LOAD OPERATIONS
-- ============================================================================

-- Save current workspace state as a session
function M.save_session(window, pane)
	local workspace = window:active_workspace()
	local default_name = workspace ~= "default" and workspace or ""

	-- Prompt for session name
	window:perform_action(
		act.PromptInputLine({
			description = "💾 Save session as:",
			initial_value = default_name,
			action = wezterm.action_callback(function(win, p, session_name)
				if not session_name or session_name == "" then
					win:toast_notification("WezTerm", "Cancelled", nil, 2000)
					return
				end

				ensure_session_dir()

				local mux_window = win:mux_window()
				if not mux_window then
					win:toast_notification("WezTerm", "Cannot get window info", nil, 4000)
					return
				end

				-- Get workspace metadata (icon, color, theme)
				local workspace_metadata = require("modules.sessions.workspace_metadata")
				local metadata = workspace_metadata.get_metadata(workspace)

				local tabs = mux_window:tabs()
				local session_data = {
					name = session_name,
					workspace_name = workspace,
					icon = metadata.icon or "",
					color = metadata.color or "",
					theme = metadata.theme or "",
					saved_at = os.date("%Y-%m-%d %H:%M:%S"),
					tab_count = #tabs,
					tabs = {},
				}

				for i, tab in ipairs(tabs) do
					local tab_id = tostring(tab:tab_id())
					local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
					local tab_title = custom_tab_data and custom_tab_data.title or tab:get_title() or "Tab " .. i
					local tab_icon = custom_tab_data and custom_tab_data.icon_key or ""

					-- Get tab color
					local tab_color_picker = require("modules.tabs.tab_color_picker")
					local tab_color = tab_color_picker.get_tab_color(tab_id)

					local tab_panes = tab:panes()
					local panes_data = {}

					for j, pane_obj in ipairs(tab_panes) do
						local raw_cwd = pane_obj:get_current_working_dir()
						local cwd = extract_path(raw_cwd)

						table.insert(panes_data, {
							cwd = cwd,
							title = pane_obj:get_title() or "",
						})
					end

					table.insert(session_data.tabs, {
						title = tab_title,
						icon = tab_icon or "",
						color = tab_color,
						panes = panes_data,
					})
				end

				local session_file = session_dir .. "/" .. session_name .. ".json"
				local json_str = wezterm.json_encode(session_data)

				local file, err = io.open(session_file, "w")
				if not file then
					win:toast_notification("WezTerm", "Failed to save: " .. tostring(err), nil, 4000)
					return
				end

				file:write(json_str)
				file:close()

				wezterm.log_info("Session saved with " .. #session_data.tabs .. " tabs")

				local display_icon = (metadata.icon and metadata.icon ~= "") and (metadata.icon .. " ") or ""
				win:toast_notification("WezTerm", "✅ Session saved: " .. display_icon .. session_name, nil, 4000)
			end),
		}),
		pane
	)
end

-- Load a session (spawns new client if workspace not running)
function M.load_session(window, pane)
	local sessions = list_session_files()

	if #sessions == 0 then
		window:toast_notification("WezTerm", "No saved sessions", nil, 4000)
		return
	end

	-- Build session list with metadata
	local choices = {}
	for _, session_name in ipairs(sessions) do
		local session_file = session_dir .. "/" .. session_name .. ".json"
		local file = io.open(session_file, "r")
		local icon = ""
		local tab_count = 0
		local saved_at = ""

		if file then
			local content = file:read("*all")
			file:close()
			local success, session_data = pcall(wezterm.json_parse, content)
			if success and session_data then
				icon = session_data.icon or ""
				tab_count = session_data.tab_count or (#session_data.tabs or 0)
				saved_at = session_data.saved_at or ""
			end
		end

		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		local label = string.format("%s%s (%d tabs) - %s", icon_prefix, session_name, tab_count, saved_at)
		table.insert(choices, { label = label, id = session_name })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, session_id)
				if not session_id or session_id == "" then
					return
				end

				-- Load the session
				local session_file = session_dir .. "/" .. session_id .. ".json"
				local file = io.open(session_file, "r")

				if not file then
					win:toast_notification("WezTerm", "❌ Session not found", nil, 4000)
					return
				end

				local content = file:read("*all")
				file:close()

				local session = wezterm.json_parse(content)
				if not session or not session.tabs then
					win:toast_notification("WezTerm", "❌ Invalid session file", nil, 4000)
					return
				end

				wezterm.log_info("Loading session: " .. session_id .. " with " .. #session.tabs .. " tabs")

				-- Determine target workspace name
				local target_workspace = session.workspace_name or session_id

				-- Check if workspace already has a running client (safe check)
				local success, existing_client = pcall(isolation.find_client_for_workspace, target_workspace)

				if success and existing_client then
					-- Workspace already running, warn user
					win:toast_notification(
						"WezTerm",
						"⚠️  Workspace '" .. target_workspace .. "' already running (window " .. existing_client .. ")",
						nil,
						4000
					)
					-- Focus the existing client instead
					pcall(isolation.focus_workspace_client, target_workspace)
					return
				end

				-- Spawn new client and restore session
				local first_tab_data = session.tabs[1]
				local first_cwd = extract_path(first_tab_data.panes[1].cwd)
				local first_tab, first_pane, new_window = wezterm.mux.spawn_window({
					workspace = target_workspace,
					cwd = first_cwd,
				})

				first_pane:send_text("clear\n")
				wezterm.sleep_ms(150)

				-- Restore workspace metadata
				if session.color and session.color ~= "" then
					local workspace_metadata = require("modules.sessions.workspace_metadata")
					workspace_metadata.set_color(target_workspace, session.color)
				end

				if session.theme and session.theme ~= "" then
					local workspace_metadata = require("modules.sessions.workspace_metadata")
					workspace_metadata.set_theme(target_workspace, session.theme)

					local workspace_themes = require("modules.sessions.themes")
					workspace_themes.set_workspace_theme(target_workspace, session.theme)
				end

				if session.icon and session.icon ~= "" then
					set_workspace_icon(target_workspace, session.icon)
				end

				-- Initialize custom_tabs global
				if not wezterm.GLOBAL.custom_tabs then
					wezterm.GLOBAL.custom_tabs = {}
				end

				-- Store custom tab data for first tab
				wezterm.GLOBAL.custom_tabs[tostring(first_tab:tab_id())] = {
					title = first_tab_data.title,
					icon_key = first_tab_data.icon or "",
				}
				first_tab:set_title(first_tab_data.title)

				-- Restore tab color if saved
				if first_tab_data.color then
					local tab_color_picker = require("modules.tabs.tab_color_picker")
					tab_color_picker.set_tab_color(tostring(first_tab:tab_id()), first_tab_data.color)
				end

				-- Restore additional panes in first tab
				for j = 2, #first_tab_data.panes do
					local cwd = extract_path(first_tab_data.panes[j].cwd)
					local split_pane = first_pane:split({
						direction = "Right",
						cwd = cwd,
					})
					split_pane:send_text("clear\n")
					wezterm.sleep_ms(150)
				end

				-- Restore additional tabs
				for i = 2, #session.tabs do
					local tab_data = session.tabs[i]
					local tab_first_cwd = extract_path(tab_data.panes[1].cwd)
					local new_tab, new_tab_pane, _ = new_window:spawn_tab({
						cwd = tab_first_cwd,
					})
					new_tab_pane:send_text("clear\n")
					wezterm.sleep_ms(150)

					-- Store custom tab data
					wezterm.GLOBAL.custom_tabs[tostring(new_tab:tab_id())] = {
						title = tab_data.title,
						icon_key = tab_data.icon or "",
					}
					new_tab:set_title(tab_data.title)

					-- Restore tab color
					if tab_data.color then
						local tab_color_picker = require("modules.tabs.tab_color_picker")
						tab_color_picker.set_tab_color(tostring(new_tab:tab_id()), tab_data.color)
					end

					-- Restore additional panes
					for j = 2, #tab_data.panes do
						local cwd = extract_path(tab_data.panes[j].cwd)
						local split_pane = new_tab_pane:split({
							direction = "Right",
							cwd = cwd,
						})
						split_pane:send_text("clear\n")
						wezterm.sleep_ms(150)
					end
				end

				wezterm.log_info("Session restored: " .. session_id)
				win:toast_notification("WezTerm", "✅ Restored session: " .. session_id, nil, 4000)
			end),
			title = "📂 Load Session",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- ============================================================================
-- MAIN MENU
-- ============================================================================

function M.show_menu(window, pane)
	local all_workspaces = list_all_workspaces()
	local current_workspace = window:active_workspace()

	-- **FIX: Cache running clients ONCE** - this was causing the deadlock!
	local running_map = get_running_workspace_map()

	local choices = {
		{ id = "separator0", label = "─────────────────────────────" },
		{ id = "actions_header", label = "─── ⚡ WORKSPACE ACTIONS ───" },
		{ id = "workspace_create", label = "🆕 Create Workspace" },
		{ id = "workspace_switch", label = "📂 Switch Workspace" },
		{ id = "workspace_close", label = "🗑️  Close Workspace" },
		{ id = "workspace_rename", label = "✏️  Rename Current Workspace" },
		{ id = "separator1", label = "─────────────────────────────" },
		{ id = "sessions_header", label = "─── 💾 SESSIONS ───" },
		{ id = "session_save", label = "💾 Save Current Session" },
		{ id = "session_load", label = "📂 Load Session" },
		{ id = "separator2", label = "─────────────────────────────" },
		{ id = "workspaces_header", label = "─── 🌐 ACTIVE WORKSPACES (" .. #all_workspaces .. ") ───" },
	}

	-- Add workspace list with visual indicators
	if #all_workspaces > 0 then
		for _, ws in ipairs(all_workspaces) do
			local icon = get_workspace_icon(ws)
			local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
			local prefix = (ws == current_workspace) and "▶ " or "  "

			-- **FIX: Use cached map instead of calling isolation for each workspace**
			local running_indicator = running_map[ws] and " 🟢" or ""

			table.insert(choices, {
				id = "workspace:" .. ws,
				label = prefix .. icon_prefix .. ws .. running_indicator,
			})
		end
	else
		table.insert(choices, { id = "no_workspaces", label = "  (No workspaces)" })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id == "workspace_create" then
					M.create_workspace(win, p)
				elseif id == "workspace_switch" then
					M.switch_workspace(win, p)
				elseif id == "workspace_close" then
					M.close_workspace(win, p)
				elseif id == "workspace_rename" then
					M.rename_workspace(win, p)
				elseif id == "session_save" then
					M.save_session(win, p)
				elseif id == "session_load" then
					M.load_session(win, p)
				elseif id and id:match("^workspace:") then
					local workspace_name = id:gsub("^workspace:", "")
					-- Switch to the selected workspace
					M.switch_workspace_to(win, p, workspace_name)
				end
			end),
			title = "🌐 Workspace Manager [" .. current_workspace .. "]",
			choices = choices,
			fuzzy = false,
		}),
		pane
	)
end

-- Helper to switch directly to a named workspace
function M.switch_workspace_to(window, pane, workspace_name)
	wezterm.log_info("[UNIFIED_WORKSPACE] Direct switch to workspace: " .. workspace_name)
	local success, result = pcall(isolation.switch_to_workspace, workspace_name)

	if success and result then
		window:toast_notification("WezTerm", "📂 Switched to workspace: " .. workspace_name, nil, 2000)
	else
		window:toast_notification("WezTerm", "❌ Failed to switch workspace: " .. tostring(result), nil, 2000)
	end
end

-- ============================================================================
-- PANE MANAGEMENT (from old session_manager)
-- ============================================================================

-- Move pane to another tab
function M.move_pane_to_tab(window, pane)
	local mux_window = window:mux_window()
	if not mux_window then
		window:toast_notification("WezTerm", "Cannot get window info", nil, 2000)
		return
	end

	local tabs = mux_window:tabs()
	local current_tab = window:active_tab()

	-- Build list of target tabs (excluding current tab)
	local choices = {}
	for i, tab in ipairs(tabs) do
		if tab:tab_id() ~= current_tab:tab_id() then
			local tab_id = tostring(tab:tab_id())
			local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
			local tab_title = custom_tab_data and custom_tab_data.title or tab:get_title() or "Tab " .. i
			local tab_icon = custom_tab_data and custom_tab_data.icon_key or ""
			local icon_prefix = (tab_icon and tab_icon ~= "") and (tab_icon .. " ") or ""

			table.insert(choices, {
				label = icon_prefix .. tab_title,
				id = tostring(tab:tab_id()),
			})
		end
	end

	if #choices == 0 then
		window:toast_notification("WezTerm", "No other tabs available", nil, 2000)
		return
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, target_tab_id)
				if target_tab_id then
					-- Move pane to target tab
					win:perform_action(act.MoveTab(tonumber(target_tab_id)), p)
					win:toast_notification("WezTerm", "✅ Moved pane to tab", nil, 2000)
				end
			end),
			title = "📦 Move Pane to Tab",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Grab pane from another tab
function M.grab_pane_from_tab(window, pane)
	local mux_window = window:mux_window()
	if not mux_window then
		window:toast_notification("WezTerm", "Cannot get window info", nil, 2000)
		return
	end

	local tabs = mux_window:tabs()
	local current_tab = window:active_tab()

	-- Build list of source tabs (excluding current tab)
	local choices = {}
	for i, tab in ipairs(tabs) do
		if tab:tab_id() ~= current_tab:tab_id() then
			local panes_count = #tab:panes()
			if panes_count > 0 then
				local tab_id = tostring(tab:tab_id())
				local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
				local tab_title = custom_tab_data and custom_tab_data.title or tab:get_title() or "Tab " .. i
				local tab_icon = custom_tab_data and custom_tab_data.icon_key or ""
				local icon_prefix = (tab_icon and tab_icon ~= "") and (tab_icon .. " ") or ""

				table.insert(choices, {
					label = icon_prefix .. tab_title .. " (" .. panes_count .. " panes)",
					id = tostring(tab:tab_id()),
				})
			end
		end
	end

	if #choices == 0 then
		window:toast_notification("WezTerm", "No other tabs with panes", nil, 2000)
		return
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, source_tab_id)
				if source_tab_id then
					-- Implementation: grab first pane from source tab
					for _, tab in ipairs(tabs) do
						if tostring(tab:tab_id()) == source_tab_id then
							local source_panes = tab:panes()
							if #source_panes > 0 then
								-- Activate source pane and move it
								source_panes[1]:activate()
								win:perform_action(act.MoveTab(current_tab:tab_id()), source_panes[1])
								win:toast_notification("WezTerm", "✅ Grabbed pane from tab", nil, 2000)
							end
							break
						end
					end
				end
			end),
			title = "🎣 Grab Pane from Tab",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Move pane to its own tab
function M.move_pane_to_own_tab(window, pane)
	local current_tab = window:active_tab()
	local panes = current_tab:panes()

	if #panes <= 1 then
		window:toast_notification("WezTerm", "Only one pane in this tab", nil, 2000)
		return
	end

	-- Get pane's CWD
	local cwd = pane:get_current_working_dir()
	if cwd then
		cwd = extract_path(cwd)
	end

	-- Create new tab
	local new_tab, new_pane, _ = window:mux_window():spawn_tab({
		cwd = cwd,
	})

	-- Move current pane to new tab
	window:perform_action(act.MoveTab(new_tab:tab_id()), pane)
	window:toast_notification("WezTerm", "✅ Moved pane to new tab", nil, 2000)
end

return M
