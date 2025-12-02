-- ~/.core/.sys/configs/wezterm/modules/workspace_manager.lua
-- Unified Workspace Manager - handles workspaces and templates in one place

local wezterm = require("wezterm")
local act = wezterm.action
local paths = require("utils.paths")

-- Try to load resurrect module for proper pane layout handling
local has_resurrect, pane_tree_mod = pcall(require, "resurrect.pane_tree")
local has_tab_state, tab_state_mod = pcall(require, "resurrect.tab_state")

local M = {}

-- Template storage directory
local template_dir = paths.WEZTERM_DATA .. "/workspace-templates"

-- Ensure template directory exists
local function ensure_template_dir()
	os.execute('mkdir -p "' .. template_dir .. '"')
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

-- Recursively build pane tree structure
local function build_pane_tree(pane_node, all_panes)
	if pane_node.is_leaf then
		-- Leaf node - get the actual pane info
		local pane = all_panes[pane_node.index]
		if pane then
			local raw_cwd = pane:get_current_working_dir()
			local cwd = extract_path(raw_cwd)
			return {
				is_leaf = true,
				cwd = cwd,
				title = pane:get_title() or "",
			}
		end
	else
		-- Branch node - recursively process children
		local children = {}
		for _, child in ipairs(pane_node) do
			table.insert(children, build_pane_tree(child, all_panes))
		end
		return {
			is_leaf = false,
			direction = pane_node.direction, -- "Horizontal" or "Vertical"
			children = children,
			size = pane_node.size or 0.5,
		}
	end
end

-- Recursively restore pane tree structure
local function restore_pane_tree(pane_tree, parent_pane)
	if pane_tree.is_leaf then
		-- This is a leaf - no split needed, just return the parent pane
		return parent_pane
	else
		-- This is a branch - create splits for children
		local panes = {}
		for i, child in ipairs(pane_tree.children) do
			if i == 1 then
				-- First child uses the parent pane
				if child.is_leaf then
					table.insert(panes, parent_pane)
				else
					-- First child is also a branch, recurse
					local result_pane = restore_pane_tree(child, parent_pane)
					table.insert(panes, result_pane)
				end
			else
				-- Create splits for remaining children
				local reference_pane = panes[#panes]
				local direction = pane_tree.direction == "Horizontal" and "Bottom" or "Right"

				if child.is_leaf then
					-- Create a simple split
					local new_pane = reference_pane:split({
						direction = direction,
						cwd = extract_path(child.cwd),
						size = child.size or (1.0 / #pane_tree.children),
					})
					new_pane:send_text("clear\n")
					wezterm.sleep_ms(50)
					table.insert(panes, new_pane)
				else
					-- Child is a branch, need to split then recurse
					local split_pane = reference_pane:split({
						direction = direction,
						cwd = wezterm.home_dir, -- Will be overridden by recursion
						size = child.size or (1.0 / #pane_tree.children),
					})
					split_pane:send_text("clear\n")
					wezterm.sleep_ms(50)
					local result_pane = restore_pane_tree(child, split_pane)
					table.insert(panes, result_pane)
				end
			end
		end
		return panes[#panes] -- Return the last pane
	end
end

-- List available workspaces
local function list_workspaces()
	local workspaces = wezterm.mux.get_workspace_names()
	table.sort(workspaces)
	return workspaces
end

-- List available templates
local function list_templates()
	ensure_template_dir()
	local templates = {}
	local handle = io.popen('ls -1 "' .. template_dir .. '"/*.json 2>/dev/null')

	if handle then
		for file in handle:lines() do
			local name = file:match("([^/]+)%.json$")
			if name then
				table.insert(templates, name)
			end
		end
		handle:close()
	end

	table.sort(templates)
	return templates
end

-- Get workspace icon
local function get_workspace_icon(workspace_name)
	if wezterm.GLOBAL.workspace_icons and wezterm.GLOBAL.workspace_icons[workspace_name] then
		return wezterm.GLOBAL.workspace_icons[workspace_name]
	end
	return ""
end

-- Set workspace icon
local function set_workspace_icon(workspace_name, icon)
	if not wezterm.GLOBAL.workspace_icons then
		wezterm.GLOBAL.workspace_icons = {}
	end
	wezterm.GLOBAL.workspace_icons[workspace_name] = icon or ""

	-- Also save to persistent metadata
	local workspace_metadata = require("modules.sessions.workspace_metadata")
	workspace_metadata.set_icon(workspace_name, icon or "")
end

-- Get template icon and metadata
local function get_template_metadata(template_name)
	local template_file = template_dir .. "/" .. template_name .. ".json"
	local file = io.open(template_file, "r")

	if file then
		local content = file:read("*all")
		file:close()
		local success, template_data = pcall(wezterm.json_parse, content)
		if success and template_data then
			return {
				icon = template_data.icon or "",
				workspace_icon = template_data.icon or "",
				saved_at = template_data.saved_at,
				tab_count = template_data.tabs and #template_data.tabs or 0,
			}
		end
	end

	return { icon = "", workspace_icon = "", tab_count = 0 }
end

-- ==================== WORKSPACE ACTIONS ====================

-- Create new workspace
local function create_workspace(window, pane)
	local tab_rename = require("modules.tabs.tab_rename")

	-- Prompt for workspace name first
	window:perform_action(
		act.PromptInputLine({
			description = "🆕 Create workspace name:",
			action = wezterm.action_callback(function(win, p, workspace_name)
				if not workspace_name or workspace_name == "" then
					return
				end

				-- Show icon picker
				tab_rename.show_icon_set_menu(win, p, function(inner_win, inner_pane, full_title, icon, title)
					-- Store workspace icon in global state
					set_workspace_icon(workspace_name, icon or "")

					local display_name = (icon and icon ~= "") and (icon .. " " .. workspace_name) or workspace_name

					-- Switch to the new workspace (will create it if it doesn't exist)
					inner_win:perform_action(act.SwitchToWorkspace({ name = workspace_name }), inner_pane)

					-- Emit workspace-created event to trigger auto-save
					wezterm.emit("workspace-created", inner_win, workspace_name)

					inner_win:toast_notification("WezTerm", "✅ Created workspace: " .. display_name, nil, 2000)
				end)
			end),
		}),
		pane
	)
end

-- Switch workspace
local function switch_workspace(window, pane)
	local workspaces = list_workspaces()
	local current_workspace = window:active_workspace()

	if #workspaces == 0 then
		window:toast_notification("WezTerm", "No workspaces available", nil, 2000)
		return
	end

	local choices = {}
	for _, ws in ipairs(workspaces) do
		local icon = get_workspace_icon(ws)
		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		local prefix = (ws == current_workspace) and "▶ " or "  "
		table.insert(choices, { label = prefix .. icon_prefix .. ws, id = ws })
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

-- Close/Kill workspace
local function close_workspace(window, pane)
	local workspaces = list_workspaces()
	local current_workspace = window:active_workspace()

	if #workspaces <= 1 then
		window:toast_notification("WezTerm", "Cannot close the only workspace", nil, 2000)
		return
	end

	local choices = {}
	for _, ws in ipairs(workspaces) do
		local icon = get_workspace_icon(ws)
		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		local marker = (ws == current_workspace) and " [current]" or ""
		table.insert(choices, { label = icon_prefix .. ws .. marker, id = ws })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					local is_current = (id == win:active_workspace())

					-- If closing current workspace, switch to another workspace first
					if is_current then
						local other_workspace = nil
						for _, ws in ipairs(workspaces) do
							if ws ~= id then
								other_workspace = ws
								break
							end
						end

						if other_workspace then
							win:perform_action(act.SwitchToWorkspace({ name = other_workspace }), p)
							wezterm.sleep_ms(200)
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
						for _, tab in ipairs(tabs) do
							for _, tab_pane in ipairs(tab:panes()) do
								tab_pane:activate()
								win:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), tab_pane)
							end
						end
					end

					win:toast_notification(
						"WezTerm",
						"🗑️  Closed workspace '" .. id .. "' (" .. tabs_closed .. " tabs closed)",
						nil,
						3000
					)
				end
			end),
			title = "🗑️  Close Workspace",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Rename workspace
local function rename_workspace(window, pane)
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

				-- Show icon picker using the tab_rename workflow
				tab_rename.show_icon_set_menu(win, p, function(inner_win, inner_pane, full_title, icon, title)
					-- Move all tabs from current workspace to new workspace
					local tabs_moved = 0
					for _, mux_win in ipairs(wezterm.mux.all_windows()) do
						if mux_win:get_workspace() == current then
							for _, tab in ipairs(mux_win:tabs()) do
								tab:set_workspace(new_name)
								tabs_moved = tabs_moved + 1
							end
						end
					end

					-- Store workspace icon in global state
					set_workspace_icon(new_name, icon or "")

					-- Remove old workspace icon if it existed
					if wezterm.GLOBAL.workspace_icons and wezterm.GLOBAL.workspace_icons[current] then
						wezterm.GLOBAL.workspace_icons[current] = nil
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

-- Set workspace color
local function set_workspace_color(window, pane)
	local workspaces = list_workspaces()
	local current_workspace = window:active_workspace()

	if #workspaces == 0 then
		window:toast_notification("WezTerm", "No workspaces available", nil, 2000)
		return
	end

	-- Get workspace metadata module
	local workspace_metadata = require("modules.sessions.workspace_metadata")

	local choices = {}
	for _, ws in ipairs(workspaces) do
		local metadata = workspace_metadata.get_metadata(ws)
		local icon = metadata.icon or ""
		local color = metadata.color or ""
		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		local color_indicator = (color and color ~= "") and "🎨 " or ""
		local prefix = (ws == current_workspace) and "▶ " or "  "
		table.insert(choices, { label = prefix .. color_indicator .. icon_prefix .. ws, id = ws })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, workspace_id)
				if not workspace_id then
					return
				end

				-- Get workspace metadata for preview
				local metadata = workspace_metadata.get_metadata(workspace_id)
				local icon = metadata.icon or ""

				-- Create callback file for color picker result
				local callback_file = wezterm.config_dir .. "/.data/workspace-color-callback-" .. workspace_id .. ".tmp"

				-- Launch the color picker browser
				win:perform_action(
					wezterm.action.SpawnCommandInNewTab({
						args = {
							paths.WEZTERM_SCRIPTS .. "/tab-color-browser/color-browser.sh",
							workspace_id,
							workspace_id,  -- Use workspace name as title
							icon,
							"", -- No tmux workspace for workspace colors
							callback_file,
						},
					}),
					p
				)

				-- Watch for color selection result
				local function watch_for_color(iterations)
					if iterations > 60 then
						-- Timeout after 30 seconds
						os.remove(callback_file)
						return
					end

					local f = io.open(callback_file, "r")
					if f then
						local color = f:read("*line")
						f:close()
						os.remove(callback_file)

						if color and color ~= "" then
							if color == "CLEAR" then
								-- Clear workspace color
								workspace_metadata.set_color(workspace_id, nil)
								win:toast_notification("Workspace Color", "Cleared color for " .. workspace_id, nil, 2000)
							else
								-- Set workspace color
								workspace_metadata.set_color(workspace_id, color)

								local updated_metadata = workspace_metadata.get_metadata(workspace_id)
								local icon_display = (updated_metadata.icon and updated_metadata.icon ~= "") and (updated_metadata.icon .. " ") or ""
								win:toast_notification(
									"Workspace Color",
									"Set color for: " .. icon_display .. workspace_id,
									nil,
									2000
								)
							end

							-- Mark workspace dirty for auto-save
							win:perform_action(wezterm.action.EmitEvent("workspace-mark-dirty"), p)

							-- Close the color picker tab
							wezterm.time.call_after(0.2, function()
								local mux_window = win:mux_window()
								if mux_window then
									for _, tab in ipairs(mux_window:tabs()) do
										local panes = tab:panes()
										if #panes > 0 then
											local pane_obj = panes[1]
											local process = pane_obj:get_foreground_process_name()
											if process and process:match("color%-browser%.sh") then
												tab:activate()
												wezterm.time.call_after(0.05, function()
													win:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), pane_obj)
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
							watch_for_color(iterations + 1)
						end)
					end
				end

				-- Start watching for color selection
				wezterm.time.call_after(0.5, function()
					watch_for_color(0)
				end)
			end),
			title = "🎨 Set Workspace Color",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Change workspace icon
local function change_workspace_icon(window, pane)
	local workspaces = list_workspaces()
	local current_workspace = window:active_workspace()

	if #workspaces == 0 then
		window:toast_notification("WezTerm", "No workspaces available", nil, 2000)
		return
	end

	local choices = {}
	for _, ws in ipairs(workspaces) do
		local icon = get_workspace_icon(ws)
		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		local prefix = (ws == current_workspace) and "▶ " or "  "
		table.insert(choices, { label = prefix .. icon_prefix .. ws, id = ws })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, workspace_id)
				if not workspace_id then
					return
				end

				-- Show icon picker
				local tab_rename = require("modules.tabs.tab_rename")
				tab_rename.show_icon_set_menu(win, p, function(inner_win, inner_pane, full_title, icon, title)
					-- Update workspace icon
					set_workspace_icon(workspace_id, icon or "")

					local display_name = (icon and icon ~= "") and (icon .. " " .. workspace_id) or workspace_id
					inner_win:toast_notification("WezTerm", "✅ Updated icon for: " .. display_name, nil, 2000)
				end)
			end),
			title = "🎨 Change Workspace Icon",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- ==================== SESSION ACTIONS ====================

-- Session storage directory
local session_storage_dir = paths.WEZTERM_DATA .. "/workspace-sessions"

-- Ensure session storage directory exists
local function ensure_session_storage_dir()
	os.execute('mkdir -p "' .. session_storage_dir .. '"')
	return true
end

-- Save current workspace as a session
local function save_current_workspace_session(window, pane)
	local workspace = window:active_workspace()
	local default_name = workspace ~= "default" and workspace or ""

	-- Prompt for session name
	window:perform_action(
		act.PromptInputLine({
			description = "💾 Save workspace session as:",
			initial_value = default_name,
			action = wezterm.action_callback(function(win, p, session_name)
				if not session_name or session_name == "" then
					win:toast_notification("WezTerm", "Cancelled", nil, 2000)
					return
				end

				ensure_session_storage_dir()

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
					modified_at = os.date("%Y-%m-%d %H:%M:%S"),
					tab_count = #tabs,
					auto_save = false, -- Manual sessions don't auto-save
					tabs = {},
				}

				for i, tab in ipairs(tabs) do
					local tab_panes = tab:panes()
					local tab_id = tostring(tab:tab_id())

					-- Get custom tab data
					local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
					local tab_title = custom_tab_data and custom_tab_data.title or tab:get_title() or "Tab " .. i
					local tab_icon = custom_tab_data and custom_tab_data.icon_key or ""

					-- Get tab color
					local tab_color_picker = require("modules.tabs.tab_color_picker")
					local tab_color = tab_color_picker.get_tab_color(tab_id)

					local tab_data = {
						title = tab_title,
						icon = tab_icon or "",
						color = tab_color,
						panes = {},
					}

					-- Save panes
					for j, pane_obj in ipairs(tab_panes) do
						local raw_cwd = pane_obj:get_current_working_dir()
						local cwd = extract_path(raw_cwd)

						table.insert(tab_data.panes, {
							cwd = cwd,
							title = pane_obj:get_title() or "",
						})
					end

					table.insert(session_data.tabs, tab_data)
				end

				local session_file = session_storage_dir .. "/" .. session_name .. ".json"
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

-- List available sessions
local function list_workspace_sessions()
	ensure_session_storage_dir()
	local sessions = {}
	local handle = io.popen('ls -1 "' .. session_storage_dir .. '"/*.json 2>/dev/null')

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

-- Load a workspace session
local function load_workspace_session(window, pane)
	local sessions = list_workspace_sessions()

	if #sessions == 0 then
		window:toast_notification("WezTerm", "No saved workspace sessions", nil, 4000)
		return
	end

	-- Build session list with icons and metadata
	local choices = {}
	for _, session_name in ipairs(sessions) do
		local session_file = session_storage_dir .. "/" .. session_name .. ".json"
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
				local session_file = session_storage_dir .. "/" .. session_id .. ".json"
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

				wezterm.log_info("Restoring session: " .. session_id .. " with " .. #session.tabs .. " tabs")

				-- Determine target workspace name
				local target_workspace = session.workspace_name or session_id

				-- Spawn first tab
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

					-- Apply theme
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
			title = "📂 Load Workspace Session",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Delete a workspace session
local function delete_workspace_session(window, pane)
	local sessions = list_workspace_sessions()

	if #sessions == 0 then
		window:toast_notification("WezTerm", "No saved workspace sessions", nil, 4000)
		return
	end

	local choices = {}
	for _, session_name in ipairs(sessions) do
		local session_file = session_storage_dir .. "/" .. session_name .. ".json"
		local file = io.open(session_file, "r")
		local icon = ""

		if file then
			local content = file:read("*all")
			file:close()
			local success, session_data = pcall(wezterm.json_parse, content)
			if success and session_data then
				icon = session_data.icon or ""
			end
		end

		local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
		table.insert(choices, { label = icon_prefix .. session_name, id = session_name })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					os.remove(session_storage_dir .. "/" .. id .. ".json")
					win:toast_notification("WezTerm", "🗑️  Deleted session: " .. id, nil, 4000)
				end
			end),
			title = "🗑️  Delete Workspace Session",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- ==================== TEMPLATE ACTIONS ====================

-- Save current workspace as template
local function save_template(window, pane)
	local workspace = window:active_workspace()
	local default_name = workspace ~= "default" and workspace or ""

	-- Get workspace metadata (icon, color, theme)
	local workspace_metadata = require("modules.sessions.workspace_metadata")
	local metadata = workspace_metadata.get_metadata(workspace)
	local workspace_icon = metadata.icon or get_workspace_icon(workspace)

	wezterm.log_info("=== SAVE WORKSPACE TEMPLATE ===")

	-- Save Neovim sessions first (if enabled)
	local config = window:effective_config()
	if config.workspace_nvim_integration then
		local nvim_integration = require("modules.sessions.neovim_integration")
		local saved_nvim = nvim_integration.save_workspace_nvim_sessions(window, workspace)
		if saved_nvim > 0 then
			wezterm.log_info("Saved " .. saved_nvim .. " Neovim sessions before template creation")
		end
	end

	ensure_template_dir()

	-- Prompt for template name
	window:perform_action(
		act.PromptInputLine({
			description = "💾 Save workspace template as:",
			initial_value = default_name,
			action = wezterm.action_callback(function(win, p, template_name)
				if not template_name or template_name == "" then
					win:toast_notification("WezTerm", "Cancelled", nil, 2000)
					return
				end

				local mux_window = win:mux_window()
				if not mux_window then
					win:toast_notification("WezTerm", "Cannot get window info", nil, 4000)
					return
				end

				local tabs = mux_window:tabs()
				local template_data = {
					name = template_name,
					icon = workspace_icon or "",
					color = metadata.color or "",  -- NEW: Save workspace color
					theme = metadata.theme or "",  -- NEW: Save workspace theme
					workspace_name = workspace,
					saved_at = os.date("%Y-%m-%d %H:%M:%S"),
					tabs = {},
				}

				for i, tab in ipairs(tabs) do
					local tab_panes = tab:panes()
					local tab_id = tostring(tab:tab_id())

					-- Get custom tab data from global state
					local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]

					-- Get tab title: prefer custom title, then tab's actual title, then fallback
					local tab_title
					if custom_tab_data and custom_tab_data.title and custom_tab_data.title ~= "" then
						tab_title = custom_tab_data.title
					else
						local actual_title = tab:get_title()
						-- Filter out generic titles that aren't useful
						if actual_title and actual_title ~= "" and not actual_title:match("^Tab %d+$") then
							tab_title = actual_title
						else
							tab_title = "Tab " .. i
						end
					end

					local tab_icon = custom_tab_data and custom_tab_data.icon_key or ""

					wezterm.log_info("Saving tab " .. i .. ": title=" .. tab_title .. ", icon=" .. tostring(tab_icon))

					local tab_data = {
						title = tab_title,
						icon = tab_icon or "",
					}

					-- Use resurrect module for proper pane layout if available
					if has_resurrect and has_tab_state then
						local tab_info = tab_state_mod.get_tab_state(tab)
						-- Store the pane tree structure from resurrect
						tab_data.pane_tree = tab_info.pane_tree
						wezterm.log_info("  Using resurrect pane tree for tab " .. i)
					else
						-- Fallback: save panes in simple list format
						local panes_data = {}
						for _, pane in ipairs(tab_panes) do
							local raw_cwd = pane:get_current_working_dir()
							local cwd = extract_path(raw_cwd)
							table.insert(panes_data, {
								cwd = cwd,
								title = pane:get_title() or "",
							})
						end
						tab_data.panes = panes_data
						wezterm.log_info("  Using simple panes list for tab " .. i)
					end

					table.insert(template_data.tabs, tab_data)
				end

				local template_file = template_dir .. "/" .. template_name .. ".json"
				local json_str = wezterm.json_encode(template_data)

				local file, err = io.open(template_file, "w")
				if not file then
					win:toast_notification("WezTerm", "Failed to save: " .. tostring(err), nil, 4000)
					return
				end

				file:write(json_str)
				file:close()

				wezterm.log_info("Template saved with " .. #template_data.tabs .. " tabs")

				local display_icon = (workspace_icon and workspace_icon ~= "") and (workspace_icon .. " ") or ""
				win:toast_notification("WezTerm", "✅ Template saved: " .. display_icon .. template_name, nil, 4000)
			end),
		}),
		pane
	)
end

-- Load template (shows list with load/delete options per template)
local function load_template(window, pane)
	local templates = list_templates()

	if #templates == 0 then
		window:toast_notification("WezTerm", "No workspace templates found", nil, 4000)
		return
	end

	-- Build template list with icons
	local choices = {}
	for _, template_name in ipairs(templates) do
		local metadata = get_template_metadata(template_name)
		local icon_prefix = (metadata.icon and metadata.icon ~= "") and (metadata.icon .. " ") or ""
		table.insert(choices, {
			label = icon_prefix .. template_name .. " (" .. metadata.tab_count .. " tabs)",
			id = template_name,
		})
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, template_id)
				if not template_id or template_id == "" then
					return
				end

				-- Show context menu: Load or Delete
				local context_choices = {
					{ id = "load", label = "📂 Load Template" },
					{ id = "delete", label = "🗑️  Delete Template" },
					{ id = "cancel", label = "❌ Cancel" },
				}

				win:perform_action(
					act.InputSelector({
						action = wezterm.action_callback(function(inner_win, inner_pane, action_id)
							if action_id == "load" then
								-- Prompt for workspace name
								inner_win:perform_action(
									act.PromptInputLine({
										description = "🆕 Load template '" .. template_id .. "' into workspace:",
										initial_value = template_id,
										action = wezterm.action_callback(function(final_win, final_pane, workspace_name)
											if workspace_name and workspace_name ~= "" then
												-- Load the template
												local template_file = template_dir .. "/" .. template_id .. ".json"
												local file = io.open(template_file, "r")

												if not file then
													final_win:toast_notification("WezTerm", "❌ Template not found", nil, 4000)
													return
												end

												local content = file:read("*all")
												file:close()

												local template = wezterm.json_parse(content)
												if not template or not template.tabs then
													final_win:toast_notification("WezTerm", "❌ Invalid template file", nil, 4000)
													return
												end

												wezterm.log_info("Loading " .. #template.tabs .. " tabs into workspace " .. workspace_name)

												-- Restore workspace metadata (color, theme)
												local workspace_metadata = require("modules.sessions.workspace_metadata")
												if template.color and template.color ~= "" then
													workspace_metadata.set_color(workspace_name, template.color)
													wezterm.log_info("Restored workspace color: " .. template.color)
												end
												if template.theme and template.theme ~= "" then
													workspace_metadata.set_theme(workspace_name, template.theme)
													-- Also apply theme to workspace
													local workspace_themes = require("modules.sessions.themes")
													workspace_themes.set_workspace_theme(workspace_name, template.theme)
													wezterm.log_info("Restored workspace theme: " .. template.theme)
												end

												-- Spawn first tab
												local first_tab_data = template.tabs[1]
												local first_cwd = wezterm.home_dir

												-- Extract CWD from different formats
												if first_tab_data.panes and #first_tab_data.panes > 0 then
													first_cwd = extract_path(first_tab_data.panes[1].cwd)
												elseif first_tab_data.pane_tree and first_tab_data.pane_tree.cwd then
													-- Resurrect format: root of tree has cwd
													first_cwd = extract_path(first_tab_data.pane_tree.cwd)
												end

												local first_tab, first_pane, new_window = wezterm.mux.spawn_window({
													workspace = workspace_name,
													cwd = first_cwd,
												})

												first_pane:send_text("clear\n")
												wezterm.sleep_ms(150)

												-- Store workspace icon
												set_workspace_icon(workspace_name, template.icon or "")

												-- Initialize custom_tabs global if needed
												if not wezterm.GLOBAL.custom_tabs then
													wezterm.GLOBAL.custom_tabs = {}
												end

												-- Store custom tab data
												wezterm.GLOBAL.custom_tabs[tostring(first_tab:tab_id())] = {
													title = first_tab_data.title,
													icon_key = first_tab_data.icon or "",
												}
												first_tab:set_title(first_tab_data.title)

												-- Restore pane layout
												if first_tab_data.pane_tree and has_tab_state then
													-- Use resurrect module for proper layout restoration
													wezterm.log_info("  Restoring tab 1 using resurrect pane tree")
													local tab_state = {
														title = first_tab_data.title,
														pane_tree = first_tab_data.pane_tree,
													}
													tab_state_mod.restore_tab(first_tab, tab_state, { pane = first_pane })
												elseif first_tab_data.panes then
													-- Fallback: simple horizontal splits
													wezterm.log_info("  Restoring tab 1 using simple panes list")
													for j = 2, #first_tab_data.panes do
														local pane_cwd = extract_path(first_tab_data.panes[j].cwd)
														local split_pane = first_pane:split({
															direction = "Right",
															cwd = pane_cwd,
														})
														split_pane:send_text("clear\n")
														wezterm.sleep_ms(150)
													end
												end

												-- Restore additional tabs
												for i = 2, #template.tabs do
													local tab_data = template.tabs[i]
													local tab_first_cwd = wezterm.home_dir

													-- Extract CWD from different formats
													if tab_data.panes and #tab_data.panes > 0 then
														tab_first_cwd = extract_path(tab_data.panes[1].cwd)
													elseif tab_data.pane_tree and tab_data.pane_tree.cwd then
														-- Resurrect format: root of tree has cwd
														tab_first_cwd = extract_path(tab_data.pane_tree.cwd)
													end

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

													-- Restore pane layout
													if tab_data.pane_tree and has_tab_state then
														-- Use resurrect module for proper layout restoration
														wezterm.log_info("  Restoring tab " .. i .. " using resurrect pane tree")
														local tab_state = {
															title = tab_data.title,
															pane_tree = tab_data.pane_tree,
														}
														tab_state_mod.restore_tab(new_tab, tab_state, { pane = new_tab_pane })
													elseif tab_data.panes then
														-- Fallback: simple horizontal splits
														wezterm.log_info("  Restoring tab " .. i .. " using simple panes list")
														for j = 2, #tab_data.panes do
															local pane_cwd = extract_path(tab_data.panes[j].cwd)
															local split_pane = new_tab_pane:split({
																direction = "Right",
																cwd = pane_cwd,
															})
															split_pane:send_text("clear\n")
															wezterm.sleep_ms(150)
														end
													end
												end

												wezterm.log_info("=== LOAD TEMPLATE COMPLETE ===")
												final_win:toast_notification("WezTerm", "✅ Loaded template: " .. template_id, nil, 4000)
											end
										end),
									}),
									inner_pane
								)
							elseif action_id == "delete" then
								-- Delete the template
								os.remove(template_dir .. "/" .. template_id .. ".json")
								inner_win:toast_notification("WezTerm", "🗑️  Deleted template: " .. template_id, nil, 4000)
							end
						end),
						title = "📋 Template: " .. template_id,
						choices = context_choices,
						fuzzy = false,
					}),
					p
				)
			end),
			title = "📋 Workspace Templates (Select to Load/Delete)",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Delete template (dedicated deletion menu)
local function delete_template(window, pane)
	local templates = list_templates()

	if #templates == 0 then
		window:toast_notification("WezTerm", "No workspace templates found", nil, 4000)
		return
	end

	local choices = {}
	for _, template_name in ipairs(templates) do
		local metadata = get_template_metadata(template_name)
		local icon_prefix = (metadata.icon and metadata.icon ~= "") and (metadata.icon .. " ") or ""
		table.insert(choices, {
			label = icon_prefix .. template_name,
			id = template_name,
		})
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id then
					os.remove(template_dir .. "/" .. id .. ".json")
					win:toast_notification("WezTerm", "🗑️  Deleted template: " .. id, nil, 4000)
				end
			end),
			title = "🗑️  Delete Workspace Template",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- ==================== TEMPLATES SUBMENU ====================

local function show_templates_menu(window, pane)
	local templates = list_templates()
	local current_workspace = window:active_workspace()

	local choices = {
		{ id = "back", label = "← Back to Workspace Management" },
		{ id = "separator0", label = "─────────────────────────────" },
		{ id = "actions_header", label = "─── ⚡ TEMPLATE ACTIONS ───" },
		{ id = "template_create", label = "💾 Create Template from Current Session" },
		{ id = "template_load", label = "📂 Load Template" },
		{ id = "template_delete", label = "🗑️  Delete Template" },
		{ id = "separator1", label = "─────────────────────────────" },
		{ id = "templates_header", label = "─── 📋 TEMPLATES (" .. #templates .. ") ───" },
	}

	-- Add template list
	if #templates > 0 then
		for _, template_name in ipairs(templates) do
			local metadata = get_template_metadata(template_name)
			local icon_prefix = (metadata.icon and metadata.icon ~= "") and (metadata.icon .. " ") or ""
			table.insert(choices, {
				id = "template:" .. template_name,
				label = "  " .. icon_prefix .. template_name .. " (" .. metadata.tab_count .. " tabs)",
			})
		end
	else
		table.insert(choices, { id = "no_templates", label = "  (No templates saved)" })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id == "back" then
					M.show_menu(win, p)
				elseif id == "template_create" then
					save_template(win, p)
				elseif id == "template_load" then
					load_template(win, p)
				elseif id == "template_delete" then
					delete_template(win, p)
				elseif id and id:match("^template:") then
					local template_name = id:gsub("^template:", "")
					-- Load the selected template
					load_template_by_name(win, p, template_name)
				end
			end),
			title = "📋 Template Management",
			choices = choices,
			fuzzy = false,
		}),
		pane
	)
end

-- ==================== MAIN MENU ====================

function M.show_menu(window, pane)
	local workspaces = list_workspaces()
	local templates = list_templates()
	local current_workspace = window:active_workspace()

	local choices = {
		{ id = "back", label = "← Go Back to Main Menu" },
		{ id = "separator0", label = "─────────────────────────────" },
		{ id = "actions_header", label = "─── ⚡ WORKSPACE ACTIONS ───" },
		{ id = "workspace_create", label = "🆕 Create Workspace" },
		{ id = "workspace_switch", label = "📂 Switch Workspace" },
		{ id = "workspace_close", label = "🗑️  Close Workspace" },
		{ id = "workspace_rename", label = "✏️  Rename Workspace" },
		{ id = "workspace_icon", label = "🎨 Change Icon" },
		{ id = "workspace_color", label = "🌈 Set Color" },
		{ id = "separator1", label = "─────────────────────────────" },
		{ id = "sessions_header", label = "─── 💾 SESSIONS ───" },
		{ id = "session_save", label = "💾 Save Current Session" },
		{ id = "session_load", label = "📂 Load Session" },
		{ id = "separator2", label = "─────────────────────────────" },
		{ id = "templates_menu", label = "📋 Template Management →" },
		{ id = "separator3", label = "─────────────────────────────" },
		{ id = "workspaces_header", label = "─── 🌐 WORKSPACE SESSIONS (" .. #workspaces .. ") ───" },
	}

	-- Add workspace sessions list (active workspaces)
	if #workspaces > 0 then
		for _, ws in ipairs(workspaces) do
			local icon = get_workspace_icon(ws)
			local icon_prefix = (icon and icon ~= "") and (icon .. " ") or ""
			local prefix = (ws == current_workspace) and "▶ " or "  "
			table.insert(choices, {
				id = "workspace:" .. ws,
				label = prefix .. icon_prefix .. ws,
			})
		end
	else
		table.insert(choices, { id = "no_workspaces", label = "  (No workspace sessions)" })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id == "back" then
					-- Go back to main session manager menu
					local session_manager = require("modules.sessions.manager")
					session_manager.show_menu(win, p)
				elseif id == "workspace_create" then
					create_workspace(win, p)
				elseif id == "workspace_switch" then
					switch_workspace(win, p)
				elseif id == "workspace_close" then
					close_workspace(win, p)
				elseif id == "workspace_rename" then
					rename_workspace(win, p)
				elseif id == "workspace_icon" then
					change_workspace_icon(win, p)
				elseif id == "workspace_color" then
					set_workspace_color(win, p)
				elseif id == "session_save" then
					-- Manual session save (complete)
					save_current_workspace_session(win, p)
				elseif id == "session_load" then
					-- Session load (complete)
					M.show_bash_session_list(win, p)
				elseif id == "templates_menu" then
					-- Show templates submenu
					show_templates_menu(win, p)
				elseif id and id:match("^workspace:") then
					local workspace_name = id:gsub("^workspace:", "")
					-- Switch to the selected workspace
					win:perform_action(act.SwitchToWorkspace({ name = workspace_name }), p)
					wezterm.emit("workspace-switched", win, workspace_name)
				end
			end),
			title = "🌐 Workspace Manager [" .. current_workspace .. "]",
			choices = choices,
			fuzzy = false,
		}),
		pane
	)
end

-- Export functions
M.create_workspace = create_workspace
M.switch_workspace = switch_workspace
M.close_workspace = close_workspace
M.rename_workspace = rename_workspace
M.change_workspace_icon = change_workspace_icon
M.set_workspace_color = set_workspace_color  -- NEW: Color function
M.save_template = save_template
M.load_template = load_template
M.delete_template = delete_template

-- Show bash menu for workspace management (shows full menu with all options)
function M.show_bash_menu(window, pane)
	-- Show the full workspace management menu
	-- The "Load Session" option in the menu will call show_bash_session_list()
	M.show_menu(window, pane)
end

-- Show bash FZF list for workspace sessions
function M.show_bash_session_list(window, pane)
	local sessions = list_workspace_sessions()

	if #sessions == 0 then
		window:toast_notification("WezTerm", "No saved workspace sessions", nil, 4000)
		return
	end

	-- Create callback file
	local callback_file = wezterm.config_dir .. "/.data/workspace-session-callback.tmp"

	-- Launch bash list script
	window:perform_action(
		wezterm.action.SpawnCommandInNewTab({
			args = {
				paths.WEZTERM_SCRIPTS .. "/workspace-sessions/list.sh",
				callback_file,
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

				-- Parse action: "load:name", "delete:name", "rename:name"
				local action_type, session_name = action:match("^([^:]+):(.+)$")

				if action_type == "load" then
					-- Load session
					local session_file = session_storage_dir .. "/" .. session_name .. ".json"
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

					-- Determine target workspace
					local target_workspace = session.workspace_name or session_name

					-- Spawn first tab
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

					-- Initialize custom_tabs
					if not wezterm.GLOBAL.custom_tabs then
						wezterm.GLOBAL.custom_tabs = {}
					end

					-- Store custom tab data for first tab
					wezterm.GLOBAL.custom_tabs[tostring(first_tab:tab_id())] = {
						title = first_tab_data.title,
						icon_key = first_tab_data.icon or "",
					}
					first_tab:set_title(first_tab_data.title)

					-- Restore tab color
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

						wezterm.GLOBAL.custom_tabs[tostring(new_tab:tab_id())] = {
							title = tab_data.title,
							icon_key = tab_data.icon or "",
						}
						new_tab:set_title(tab_data.title)

						if tab_data.color then
							local tab_color_picker = require("modules.tabs.tab_color_picker")
							tab_color_picker.set_tab_color(tostring(new_tab:tab_id()), tab_data.color)
						end

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

					win:toast_notification("WezTerm", "✅ Restored session: " .. session_name, nil, 4000)

				elseif action_type == "save" then
					-- Save current workspace
					save_current_workspace_session(win, p)

				elseif action_type == "create" then
					-- Create new workspace
					create_workspace(win, p)

				elseif action_type == "delete" then
					-- Delete session
					os.remove(session_storage_dir .. "/" .. session_name .. ".json")
					win:toast_notification("WezTerm", "🗑️  Deleted session: " .. session_name, nil, 4000)

				elseif action_type == "rename" then
					-- Rename session - prompt for new name
					win:perform_action(
						wezterm.action.PromptInputLine({
							description = "Rename session to:",
							action = wezterm.action_callback(function(inner_win, inner_pane, new_name)
								if new_name and new_name ~= "" and new_name ~= session_name then
									local old_file = session_storage_dir .. "/" .. session_name .. ".json"
									local new_file = session_storage_dir .. "/" .. new_name .. ".json"

									-- Read old session
									local f = io.open(old_file, "r")
									if f then
										local content = f:read("*all")
										f:close()

										local session_data = wezterm.json_parse(content)
										if session_data then
											-- Update name
											session_data.name = new_name
											session_data.modified_at = os.date("%Y-%m-%d %H:%M:%S")

											-- Write to new file
											local nf = io.open(new_file, "w")
											if nf then
												nf:write(wezterm.json_encode(session_data))
												nf:close()

												-- Remove old file
												os.remove(old_file)

												inner_win:toast_notification(
													"WezTerm",
													"✏️  Renamed to: " .. new_name,
													nil,
													4000
												)
											end
										end
									end
								end
							end)
						}),
						p
					)
				end

				-- Close the list tab
				wezterm.time.call_after(0.2, function()
					local mux_window = win:mux_window()
					if mux_window then
						for _, tab in ipairs(mux_window:tabs()) do
							local panes = tab:panes()
							if #panes > 0 then
								local pane_obj = panes[1]
								local process = pane_obj:get_foreground_process_name()
								if process and process:match("list%.sh") then
									tab:activate()
									wezterm.time.call_after(0.05, function()
										win:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), pane_obj)
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
