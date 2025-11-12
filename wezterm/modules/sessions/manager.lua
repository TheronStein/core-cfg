local wezterm = require("wezterm")
local act = wezterm.action
local M = {}

-- Session storage directory
local session_dir = wezterm.home_dir .. "/.core/cfg/wezterm/.data/sessions"

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
		wezterm.log_info("Converted " .. cwd .. " to " .. path)
		return path
	end

	return cwd
end

-- Save current session
local function save_session_internal(window, pane, session_name)
	wezterm.log_info("=== SAVE SESSION: " .. session_name .. " ===")

	ensure_session_dir()

	local workspace = window:active_workspace()
	local mux_window = window:mux_window()

	if not mux_window then
		window:toast_notification("WezTerm", "Cannot get window info", nil, 4000)
		return
	end

	local tabs = mux_window:tabs()
	local session_data = {
		name = session_name,
		workspace = workspace,
		saved_at = os.date("%Y-%m-%d %H:%M:%S"),
		tabs = {},
	}

	for i, tab in ipairs(tabs) do
		local tab_panes = tab:panes()
		local tab_id = tostring(tab:tab_id())

		-- Get custom tab data if it exists
		local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
		local tab_title = tab:get_title() or "Tab " .. i
		local icon = custom_tab_data and custom_tab_data.icon_key

		local tab_data = {
			title = tab_title,
			icon = icon,
			panes = {},
		}

		for j, pane in ipairs(tab_panes) do
			local raw_cwd = pane:get_current_working_dir()
			local cwd = extract_path(raw_cwd)

			table.insert(tab_data.panes, {
				cwd = cwd,
				title = pane:get_title() or "",
			})
		end

		table.insert(session_data.tabs, tab_data)
	end

	local session_file = session_dir .. "/" .. session_name .. ".json"
	local json_str = wezterm.json_encode(session_data)

	local file, err = io.open(session_file, "w")
	if not file then
		window:toast_notification("WezTerm", "Failed to save: " .. tostring(err), nil, 4000)
		return
	end

	file:write(json_str)
	file:close()

	wezterm.log_info("Session saved with " .. #session_data.tabs .. " tabs")
	window:toast_notification("WezTerm", "✅ Saved: " .. session_name, nil, 4000)
end

-- Prompt for session name
local function prompt_save(window, pane)
	local workspace = window:active_workspace()
	local default_name = workspace ~= "default" and workspace or ""

	window:perform_action(
		act.PromptInputLine({
			description = "💾 Save session as:",
			initial_value = default_name,
			action = wezterm.action_callback(function(win, p, line)
				if line and line ~= "" then
					save_session_internal(win, p, line)
				else
					win:toast_notification("WezTerm", "Cancelled", nil, 2000)
				end
			end),
		}),
		pane
	)
end

-- List sessions
local function list_sessions()
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

-- Restore session
local function restore_session(window, pane, session_name)
	wezterm.log_info("=== RESTORE SESSION: " .. session_name .. " ===")

	local session_file = session_dir .. "/" .. session_name .. ".json"
	local file = io.open(session_file, "r")

	if not file then
		window:toast_notification("WezTerm", "❌ Session not found", nil, 4000)
		return
	end

	local content = file:read("*all")
	file:close()

	local session = wezterm.json_parse(content)
	if not session or not session.tabs then
		window:toast_notification("WezTerm", "❌ Invalid session file", nil, 4000)
		return
	end

	wezterm.log_info("Restoring " .. #session.tabs .. " tabs in workspace " .. (session.workspace or session_name))

	-- Spawn initial window and first tab with first pane
	local first_tab_data = session.tabs[1]
	local first_cwd = extract_path(first_tab_data.panes[1].cwd)
	local first_tab, first_pane, new_window = wezterm.mux.spawn_window({
		workspace = session.workspace or session_name,
		cwd = first_cwd,
	})

	first_pane:send_text("clear\n")
	wezterm.sleep_ms(150)

	-- Always initialize custom_tabs global if needed
	if not wezterm.GLOBAL.custom_tabs then
		wezterm.GLOBAL.custom_tabs = {}
	end

	-- Store custom tab data (title and icon)
	wezterm.GLOBAL.custom_tabs[tostring(first_tab:tab_id())] = {
		title = first_tab_data.title,
		icon_key = first_tab_data.icon or "",
	}

	-- Also set the title directly (backup method)
	first_tab:set_title(first_tab_data.title)

	-- Restore additional panes in first tab (chain horizontal splits)
	local current_pane = first_pane
	for j = 2, #first_tab_data.panes do
		local cwd = extract_path(first_tab_data.panes[j].cwd)
		wezterm.log_info("  Creating pane " .. j .. " in tab 1 -> " .. cwd)
		local split_pane = current_pane:split({
			direction = "Right", -- Change to 'Bottom' for vertical splits
			cwd = cwd,
			size = 1.0 / #first_tab_data.panes, -- Even split; optional
		})
		split_pane:send_text("clear\n")
		wezterm.sleep_ms(150)
		current_pane = split_pane -- Chain from new pane for linear layout
	end

	-- Restore additional tabs
	for i = 2, #session.tabs do
		local tab_data = session.tabs[i]
		local tab_first_cwd = extract_path(tab_data.panes[1].cwd)
		wezterm.log_info("Tab " .. i .. ": " .. #tab_data.panes .. " panes")
		local new_tab, new_tab_pane, _ = new_window:spawn_tab({
			cwd = tab_first_cwd,
		})
		new_tab_pane:send_text("clear\n")
		wezterm.sleep_ms(150)

		-- Always initialize custom_tabs global if needed
		if not wezterm.GLOBAL.custom_tabs then
			wezterm.GLOBAL.custom_tabs = {}
		end

		-- Store custom tab data (title and icon)
		wezterm.GLOBAL.custom_tabs[tostring(new_tab:tab_id())] = {
			title = tab_data.title,
			icon_key = tab_data.icon or "",
		}

		-- Also set the title directly (backup method)
		new_tab:set_title(tab_data.title)

		-- Additional panes in this tab
		local current_pane = new_tab_pane
		for j = 2, #tab_data.panes do
			local cwd = extract_path(tab_data.panes[j].cwd)
			wezterm.log_info("  Creating pane " .. j .. " -> " .. cwd)
			local split_pane = current_pane:split({
				direction = "Right", -- Consistent with above
				cwd = cwd,
				size = 1.0 / #tab_data.panes,
			})
			split_pane:send_text("clear\n")
			wezterm.sleep_ms(150)
			current_pane = split_pane
		end
	end

	wezterm.log_info("=== RESTORE COMPLETE ===")
	window:toast_notification("WezTerm", "✅ Restored: " .. session_name, nil, 4000)
end

-- Load session
local function load_session(window, pane)
	local sessions = list_sessions()

	if #sessions == 0 then
		window:toast_notification("WezTerm", "No saved sessions", nil, 4000)
		return
	end

	local choices = {}
	for _, session_name in ipairs(sessions) do
		-- Try to load session to get icon from first tab
		local session_file = session_dir .. "/" .. session_name .. ".json"
		local file = io.open(session_file, "r")
		local icon = ""

		if file then
			local content = file:read("*all")
			file:close()
			local success, session_data = pcall(wezterm.json_parse, content)
			if success and session_data and session_data.tabs and #session_data.tabs > 0 then
				icon = session_data.tabs[1].icon or ""
				if icon ~= "" then
					icon = icon .. " "
				end
			end
		end

		table.insert(choices, { label = icon .. session_name, id = session_name })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				wezterm.log_info("Load session callback - id: " .. tostring(id))
				if id and id ~= "" then
					restore_session(win, p, id)
				else
					wezterm.log_warn("Load session - no id selected")
				end
			end),
			title = "📂 Load Session",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Delete session
local function delete_session(window, pane)
	local sessions = list_sessions()

	if #sessions == 0 then
		window:toast_notification("WezTerm", "No saved sessions", nil, 4000)
		return
	end

	local choices = {}
	for _, session_name in ipairs(sessions) do
		-- Try to load session to get icon from first tab
		local session_file = session_dir .. "/" .. session_name .. ".json"
		local file = io.open(session_file, "r")
		local icon = ""

		if file then
			local content = file:read("*all")
			file:close()
			local success, session_data = pcall(wezterm.json_parse, content)
			if success and session_data and session_data.tabs and #session_data.tabs > 0 then
				icon = session_data.tabs[1].icon or ""
				if icon ~= "" then
					icon = icon .. " "
				end
			end
		end

		table.insert(choices, { label = icon .. session_name, id = session_name })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					os.remove(session_dir .. "/" .. id .. ".json")
					win:toast_notification("WezTerm", "🗑️  Deleted: " .. id, nil, 4000)
				end
			end),
			title = "🗑️  Delete Session",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Workspace management functions
local function list_workspaces()
	local workspaces = wezterm.mux.get_workspace_names()
	table.sort(workspaces)
	return workspaces
end

-- Move current tab to another workspace
local function move_tab_to_workspace(window, pane)
	local workspaces = list_workspaces()
	local current_workspace = window:active_workspace()
	local current_tab = window:active_tab()
	local mux_window = window:mux_window()

	if not current_tab or not mux_window then
		window:toast_notification("WezTerm", "No active tab", nil, 2000)
		return
	end

	-- Filter out current workspace
	local other_workspaces = {}
	for _, ws in ipairs(workspaces) do
		if ws ~= current_workspace then
			table.insert(other_workspaces, ws)
		end
	end

	-- Add option to create new workspace
	local choices = { { label = "🆕 Create New Workspace", id = "__new__" } }
	for _, ws in ipairs(other_workspaces) do
		table.insert(choices, { label = ws, id = ws })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if not id then
					return
				end

				-- Get fresh references
				local tab_to_move = win:active_tab()
				if not tab_to_move then
					return
				end

				-- Capture tab info before moving
				local tab_title = tab_to_move:get_title()
				local tab_id = tostring(tab_to_move:tab_id())
				local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
				local tab_icon = custom_tab_data and custom_tab_data.icon_key

				-- Get first pane's working directory
				local first_pane = tab_to_move:active_pane()
				local cwd = extract_path(first_pane:get_current_working_dir())

				local function do_move(target_ws)
					-- Create new tab in target workspace
					local new_tab, new_pane, new_window = wezterm.mux.spawn_window({
						workspace = target_ws,
						cwd = cwd,
					})

					-- Restore custom tab data
					if custom_tab_data then
						if not wezterm.GLOBAL.custom_tabs then
							wezterm.GLOBAL.custom_tabs = {}
						end
						wezterm.GLOBAL.custom_tabs[tostring(new_tab:tab_id())] = {
							title = custom_tab_data.title,
							icon_key = tab_icon or "",
						}
						new_tab:set_title(custom_tab_data.title)
					else
						new_tab:set_title(tab_title)
					end

					-- Close the original tab
					win:perform_action(act.CloseCurrentTab({ confirm = false }), p)

					win:toast_notification("WezTerm", "✅ Moved tab to: " .. target_ws, nil, 2000)
				end

				if id == "__new__" then
					-- Prompt for new workspace name
					win:perform_action(
						act.PromptInputLine({
							description = "🆕 New workspace name:",
							action = wezterm.action_callback(function(inner_win, inner_pane, line)
								if line and line ~= "" then
									do_move(line)
								end
							end),
						}),
						p
					)
				else
					do_move(id)
				end
			end),
			title = "📤 Move Tab to Workspace",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Grab a tab from another workspace
local function grab_tab_from_workspace(window, pane)
	local current_workspace = window:active_workspace()
	local mux_window = window:mux_window()

	if not mux_window then
		return
	end

	-- Collect all tabs from all workspaces except current
	-- Store tab info separately since InputSelector only accepts id and label
	local tab_info = {}
	local tab_choices = {}

	for _, mux_win in ipairs(wezterm.mux.all_windows()) do
		local workspace = mux_win:get_workspace()
		if workspace ~= current_workspace then
			for _, tab in ipairs(mux_win:tabs()) do
				local title = tab:get_title() or "Untitled"
				local tab_id = tab:tab_id()
				local pane_count = #tab:panes()
				local id_str = tostring(tab_id)

				-- Store metadata separately
				tab_info[id_str] = {
					workspace = workspace,
					window = mux_win,
					tab = tab,
				}

				table.insert(tab_choices, {
					label = string.format("[%s] %s (%d panes)", workspace, title, pane_count),
					id = id_str,
				})
			end
		end
	end

	if #tab_choices == 0 then
		window:toast_notification("WezTerm", "No tabs in other workspaces", nil, 2000)
		return
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if not id or not tab_info[id] then
					return
				end

				local info = tab_info[id]
				local source_workspace = info.workspace
				local target_workspace = win:active_workspace()
				local source_tab = info.tab

				-- Capture tab info before moving
				local tab_title = source_tab:get_title()
				local tab_id_str = tostring(source_tab:tab_id())
				local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id_str]
				local tab_icon = custom_tab_data and custom_tab_data.icon_key

				-- Get first pane's working directory
				local first_pane = source_tab:active_pane()
				local cwd = extract_path(first_pane:get_current_working_dir())

				-- Get source GUI window to close the tab later
				local source_gui_win = info.window:gui_window()

				-- Create new tab in current workspace
				local mux_win = win:mux_window()
				if mux_win then
					local new_tab, new_pane = mux_win:spawn_tab({
						cwd = cwd,
					})

					-- Restore custom tab data
					if custom_tab_data then
						if not wezterm.GLOBAL.custom_tabs then
							wezterm.GLOBAL.custom_tabs = {}
						end
						wezterm.GLOBAL.custom_tabs[tostring(new_tab:tab_id())] = {
							title = custom_tab_data.title,
							icon_key = tab_icon or "",
						}
						new_tab:set_title(custom_tab_data.title)
					else
						new_tab:set_title(tab_title)
					end

					-- Close the source tab
					if source_gui_win then
						source_tab:activate()
						source_gui_win:perform_action(act.CloseCurrentTab({ confirm = false }), first_pane)
					end

					win:toast_notification(
						"WezTerm",
						"✅ Grabbed tab from: " .. source_workspace,
						nil,
						2000
					)
				else
					win:toast_notification(
						"WezTerm",
						"❌ Failed to grab tab",
						nil,
						2000
					)
				end
			end),
			title = "📥 Grab Tab from Workspace",
			choices = tab_choices,
			fuzzy = true,
		}),
		pane
	)
end

local function create_workspace(window, pane)
	-- Use the tab_rename module's icon picker flow
	local tab_rename = require("modules.tab_rename")

	-- Prompt for workspace name first
	window:perform_action(
		act.PromptInputLine({
			description = "🆕 Create workspace name:",
			action = wezterm.action_callback(function(win, p, workspace_name)
				if not workspace_name or workspace_name == "" then
					return
				end

				-- Show icon picker using the tab_rename workflow
				-- This will guide through: icon set selection -> icon selection -> completion
				tab_rename.show_icon_set_menu(win, p, function(inner_win, inner_pane, full_title, icon, title)
					-- Create a new window in the new workspace
					local tab, pane_obj, new_window = wezterm.mux.spawn_window({
						workspace = workspace_name,
					})

					-- Store workspace icon in global state
					if icon and icon ~= "" then
						if not wezterm.GLOBAL.workspace_icons then
							wezterm.GLOBAL.workspace_icons = {}
						end
						wezterm.GLOBAL.workspace_icons[workspace_name] = icon
					end

					local display_name = (icon and icon ~= "") and (icon .. " " .. workspace_name) or workspace_name
					inner_win:toast_notification("WezTerm", "✅ Created workspace: " .. display_name, nil, 2000)
				end)
			end),
		}),
		pane
	)
end

local function switch_workspace(window, pane)
	local workspaces = list_workspaces()
	local current_workspace = window:active_workspace()

	if #workspaces == 0 then
		window:toast_notification("WezTerm", "No workspaces available", nil, 2000)
		return
	end

	local choices = {}
	for _, ws in ipairs(workspaces) do
		local prefix = (ws == current_workspace) and "▶ " or "  "
		table.insert(choices, { label = prefix .. ws, id = ws })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					win:perform_action(act.SwitchToWorkspace({ name = id }), p)
				end
			end),
			title = "📂 Switch Workspace",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

local function rename_workspace(window, pane)
	local current = window:active_workspace()
	local initial_value = (current == "default") and "" or current
	local tab_rename = require("modules.tab_rename")

	-- Prompt for new workspace name
	window:perform_action(
		act.PromptInputLine({
			description = "✏️  Rename workspace '" .. current .. "' to:",
			initial_value = initial_value,
			action = wezterm.action_callback(function(win, p, new_name)
				if not new_name or new_name == "" or new_name == current then
					return
				end

				-- Show icon picker using the tab_rename workflow
				tab_rename.show_icon_set_menu(win, p, function(inner_win, inner_pane, full_title, icon, title)
					-- Get all windows in the current workspace
					local mux_window = inner_win:mux_window()
					if not mux_window then
						inner_win:toast_notification("WezTerm", "❌ Cannot get window info", nil, 2000)
						return
					end

					-- Move all tabs from current workspace to new workspace
					local tabs_moved = 0
					for _, mux_win in ipairs(wezterm.mux.all_windows()) do
						if mux_win:get_workspace() == current then
							for _, tab in ipairs(mux_win:tabs()) do
								-- Move each tab to the new workspace
								tab:set_workspace(new_name)
								tabs_moved = tabs_moved + 1
							end
						end
					end

					-- Store workspace icon in global state
					if icon and icon ~= "" then
						if not wezterm.GLOBAL.workspace_icons then
							wezterm.GLOBAL.workspace_icons = {}
						end
						wezterm.GLOBAL.workspace_icons[new_name] = icon
					end

					-- Switch to the new workspace
					inner_win:perform_action(act.SwitchToWorkspace({ name = new_name }), inner_pane)

					local display_name = (icon and icon ~= "") and (icon .. " " .. new_name) or new_name
					local message = (current == "default")
						and "✅ Created workspace: " .. display_name .. " (" .. tabs_moved .. " tabs moved from default)"
						or "✅ Renamed to: " .. display_name .. " (" .. tabs_moved .. " tabs moved)"

					inner_win:toast_notification("WezTerm", message, nil, 3000)
				end)
			end),
		}),
		pane
	)
end

local function delete_workspace(window, pane)
	local workspaces = list_workspaces()
	local current_workspace = window:active_workspace()

	if #workspaces <= 1 then
		window:toast_notification("WezTerm", "Cannot delete the only workspace", nil, 2000)
		return
	end

	local choices = {}
	for _, ws in ipairs(workspaces) do
		-- Allow deleting any workspace, including current
		local marker = (ws == current_workspace) and " [current]" or ""
		table.insert(choices, { label = ws .. marker, id = ws })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					local is_current = (id == win:active_workspace())

					-- If deleting current workspace, switch to another workspace first
					if is_current then
						-- Find another workspace to switch to
						local other_workspace = nil
						for _, ws in ipairs(workspaces) do
							if ws ~= id then
								other_workspace = ws
								break
							end
						end

						if other_workspace then
							-- Switch to another workspace before deleting current
							win:perform_action(act.SwitchToWorkspace({ name = other_workspace }), p)
							wezterm.sleep_ms(200) -- Give it time to switch
						end
					end

					-- Close all windows in the target workspace
					local tabs_closed = 0
					local windows_to_close = {}

					-- Collect windows to close
					for _, mux_win in ipairs(wezterm.mux.all_windows()) do
						if mux_win:get_workspace() == id then
							table.insert(windows_to_close, mux_win)
						end
					end

					-- Close the windows
					for _, mux_win in ipairs(windows_to_close) do
						local tabs = mux_win:tabs()
						tabs_closed = tabs_closed + #tabs
						-- Close all panes in all tabs
						for _, tab in ipairs(tabs) do
							for _, tab_pane in ipairs(tab:panes()) do
								tab_pane:activate()
								win:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), tab_pane)
							end
						end
					end

					win:toast_notification(
						"WezTerm",
						"🗑️  Deleted workspace '" .. id .. "' (" .. tabs_closed .. " tabs closed)",
						nil,
						3000
					)
				end
			end),
			title = "🗑️  Delete Workspace (Select ANY workspace)",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Move current pane into its own tab
local function move_pane_to_own_tab(window, pane)
	local mux_window = window:mux_window()
	local current_tab = window:active_tab()

	if not mux_window or not current_tab then
		window:toast_notification("WezTerm", "Cannot get window/tab info", nil, 2000)
		return
	end

	local panes = current_tab:panes()
	if #panes <= 1 then
		window:toast_notification("WezTerm", "Only one pane in tab - already in own tab", nil, 2000)
		return
	end

	-- Get current pane's working directory
	local cwd = extract_path(pane:get_current_working_dir())
	local pane_id = pane:pane_id()

	-- Create new tab with current pane's working directory
	local new_tab, new_pane = mux_window:spawn_tab({ cwd = cwd })
	new_tab:set_title("Moved Pane")

	-- Activate the new tab first
	new_tab:activate()
	new_pane:activate()

	-- Now close the old pane by finding it
	for _, tab in ipairs(mux_window:tabs()) do
		for _, tab_pane in ipairs(tab:panes()) do
			if tab_pane:pane_id() == pane_id then
				tab_pane:activate()
				window:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), tab_pane)
				break
			end
		end
	end

	window:toast_notification("WezTerm", "✅ Moved pane to new tab", nil, 2000)
end

-- Move current pane into another tab
local function move_pane_to_tab(window, pane)
	local mux_window = window:mux_window()
	local current_tab = window:active_tab()

	if not mux_window or not current_tab then
		return
	end

	local current_panes = current_tab:panes()
	local pane_id = pane:pane_id()
	local is_only_pane = #current_panes <= 1

	-- Get all tabs except current (or all tabs if current pane is the only one)
	local tab_choices = {}
	for _, tab in ipairs(mux_window:tabs()) do
		-- If it's the only pane, allow moving to any tab including current
		-- Otherwise, exclude current tab
		if is_only_pane or tab:tab_id() ~= current_tab:tab_id() then
			local title = tab:get_title() or "Untitled"
			local pane_count = #tab:panes()
			local label = is_only_pane and tab:tab_id() == current_tab:tab_id()
				and string.format("%s (%d panes) [current]", title, pane_count)
				or string.format("%s (%d panes)", title, pane_count)
			table.insert(tab_choices, {
				label = label,
				id = tostring(tab:tab_id()),
			})
		end
	end

	if #tab_choices == 0 then
		window:toast_notification("WezTerm", "No other tabs available", nil, 2000)
		return
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if not id then
					return
				end

				local tab_id = tonumber(id)
				for _, tab in ipairs(mux_window:tabs()) do
					if tab:tab_id() == tab_id then
						-- Get the target tab's active pane to split from
						local target_pane = tab:active_pane()
						if target_pane then
							-- Get current pane's working directory
							local cwd = extract_path(pane:get_current_working_dir())

							-- Check if we're moving to the same tab (only happens when it's the only pane)
							if tab_id == current_tab:tab_id() and is_only_pane then
								-- Just create a split in the same tab, don't close the original
								local new_pane = target_pane:split({
									direction = "Right",
									cwd = cwd,
								})
								new_pane:activate()
								win:toast_notification("WezTerm", "✅ Split pane in current tab", nil, 2000)
								return
							end

							-- Activate target tab
							tab:activate()

							-- Create a split in the target tab
							local new_pane = target_pane:split({
								direction = "Right",
								cwd = cwd,
							})

							-- Close the original pane (only if not the same tab)
							win:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), p)

							win:toast_notification("WezTerm", "✅ Moved pane to tab: " .. (tab:get_title() or "Untitled"), nil, 2000)
							return
						end
					end
				end
			end),
			title = "📑 Move Pane to Tab",
			choices = tab_choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Grab a pane from another tab
local function grab_pane_from_tab(window, pane)
	local mux_window = window:mux_window()
	local current_tab = window:active_tab()

	if not mux_window or not current_tab then
		return
	end

	-- Collect all panes from other tabs
	local pane_choices = {}
	for _, tab in ipairs(mux_window:tabs()) do
		if tab:tab_id() ~= current_tab:tab_id() then
			local tab_title = tab:get_title() or "Untitled"
			local tab_panes = tab:panes()

			-- Collect all panes from other tabs
			for i, tab_pane in ipairs(tab_panes) do
				local pane_title = tab_pane:get_title() or ""
				local cwd = extract_path(tab_pane:get_current_working_dir())
				local cwd_short = cwd:match("([^/]+)/?$") or cwd

				-- Add indication if this is the only pane in its tab
				local pane_info = (#tab_panes == 1) and " [only pane - will close tab]" or ""

				table.insert(pane_choices, {
					label = string.format("[%s] Pane %d: %s (%s)%s", tab_title, i, pane_title, cwd_short, pane_info),
					id = string.format("%d:%d", tab:tab_id(), tab_pane:pane_id()),
					tab_id = tab:tab_id(),
					pane_id = tab_pane:pane_id(),
				})
			end
		end
	end

	if #pane_choices == 0 then
		window:toast_notification("WezTerm", "No panes available to grab", nil, 2000)
		return
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if not id then
					return
				end

				-- Parse the tab_id and pane_id
				local tab_id, pane_id = id:match("(%d+):(%d+)")
				tab_id = tonumber(tab_id)
				pane_id = tonumber(pane_id)

				if not tab_id or not pane_id then
					return
				end

				-- Find the source pane
				for _, tab in ipairs(mux_window:tabs()) do
					if tab:tab_id() == tab_id then
						for _, tab_pane in ipairs(tab:panes()) do
							if tab_pane:pane_id() == pane_id then
								-- Get pane's working directory
								local cwd = extract_path(tab_pane:get_current_working_dir())

								-- Create a split in current tab
								local new_pane = p:split({
									direction = "Right",
									cwd = cwd,
								})

								-- Activate and close the source pane
								tab_pane:activate()
								win:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), tab_pane)

								-- Activate the new pane
								new_pane:activate()

								win:toast_notification("WezTerm", "✅ Grabbed pane from tab", nil, 2000)
								return
							end
						end
					end
				end
			end),
			title = "📥 Grab Pane from Tab",
			choices = pane_choices,
			fuzzy = true,
		}),
		pane
	)
end

local function rename_tab_with_icon(window, pane)
	-- Use the new tab_rename module with comprehensive icon support
	local tab_rename = require("modules.tab_rename")
	tab_rename.rename_tab(window, pane)
end

-- Tab template functions
local function save_tab_template(window, pane)
	local tab_templates = require("modules.tab_templates")
	tab_templates.save_current_tab_as_template(window, pane)
end

local function load_tab_template(window, pane)
	local tab_templates = require("modules.tab_templates")
	tab_templates.load_template(window, pane)
end

local function manage_tab_templates(window, pane)
	local tab_templates = require("modules.tab_templates")
	-- Use the new unified menu from tab_templates module
	tab_templates.show_menu(window, pane)
end

-- Main menu
function M.show_menu(window, pane)
	local current_workspace = window:active_workspace()
	local workspace_count = #list_workspaces()
	local current_tab = window:active_tab()
	local tab_count = current_tab and #window:mux_window():tabs() or 0
	local pane_count = current_tab and #current_tab:panes() or 0

	local choices = {
		{ id = "separator0", label = "─── 📋 MANAGEMENT ───" },
		{ id = "workspace_management", label = "🌐 Workspace Management" },
		{ id = "tab_management", label = "📑 Tab Management" },
		{ id = "pane_management", label = "🪟 Pane Management" },
		{ id = "separator1", label = "─── 🎨 RESOURCES ───" },
		{ id = "keymaps", label = "⌨️  Keymaps" },
		{ id = "themes", label = "🎨 Themes" },
		{ id = "nerdfont_picker", label = "🔤 Nerdfont Picker" },
	}

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id == "workspace_management" then
					local workspace_manager = require("modules.workspace_manager")
					workspace_manager.show_menu(win, p)
				elseif id == "tab_management" then
					local tab_manager = require("modules.tab_manager")
					tab_manager.show_main_menu(win, p)
				elseif id == "pane_management" then
					-- Show pane management submenu
					local pane_choices = {
						{ id = "back", label = "← Go Back to Main Menu" },
						{ id = "separator", label = "─────────────────────────────" },
						{ id = "pane_own_tab", label = "🚀 Move Pane to Own Tab" },
						{ id = "pane_move", label = "📑 Move Pane to Tab" },
						{ id = "pane_grab", label = "📥 Grab Pane from Tab" },
					}
					win:perform_action(
						act.InputSelector({
							action = wezterm.action_callback(function(inner_win, inner_pane, pane_id)
								if pane_id == "back" then
									M.show_menu(inner_win, inner_pane)
								elseif pane_id == "pane_own_tab" then
									move_pane_to_own_tab(inner_win, inner_pane)
								elseif pane_id == "pane_move" then
									move_pane_to_tab(inner_win, inner_pane)
								elseif pane_id == "pane_grab" then
									grab_pane_from_tab(inner_win, inner_pane)
								end
							end),
							title = "🪟 Pane Management",
							choices = pane_choices,
							fuzzy = false,
						}),
						p
					)
				elseif id == "keymaps" then
					-- Open keymap browser script (same as LEADER+F4)
					win:perform_action(
						act.SpawnCommandInNewTab({
							args = { wezterm.home_dir .. "/.core/cfg/wezterm/scripts/keymap-browser/keymap-browser.sh" },
						}),
						p
					)
				elseif id == "themes" then
					-- Open theme browser script (same as LEADER+F5)
					local workspace = win:active_workspace() or "default"
					-- Start theme watcher for live preview
					win:perform_action(wezterm.action.EmitEvent("start-theme-watcher"), p)
					-- Small delay to ensure watcher starts
					wezterm.time.call_after(0.1, function()
						win:perform_action(
							act.SpawnCommandInNewTab({
								args = { wezterm.home_dir .. "/.core/cfg/wezterm/scripts/theme-browser/theme-browser.sh" },
								set_environment_variables = {
									WEZTERM_WORKSPACE = workspace,
									THEME_BROWSER_PREVIEW_MODE = "template",
								},
							}),
							p
						)
					end)
				elseif id == "nerdfont_picker" then
					-- Open nerdfont browser script (same as LEADER+F3)
					win:perform_action(
						act.SpawnCommandInNewTab({
							args = { wezterm.home_dir .. "/.core/cfg/wezterm/scripts/nerdfont-browser/wezterm-browser.sh" },
						}),
						p
					)
				end
			end),
			title = "📋 Session Manager",
			choices = choices,
			fuzzy = false,
		}),
		pane
	)
end

-- Export all functions
M.move_pane_to_own_tab = move_pane_to_own_tab
M.move_pane_to_tab = move_pane_to_tab
M.grab_pane_from_tab = grab_pane_from_tab
M.move_tab_to_workspace = move_tab_to_workspace
M.grab_tab_from_workspace = grab_tab_from_workspace
M.switch_workspace = switch_workspace
M.create_workspace = create_workspace
M.rename_workspace = rename_workspace
M.delete_workspace = delete_workspace

return M
