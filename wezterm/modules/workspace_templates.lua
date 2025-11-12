-- ~/.core/cfg/wezterm/modules/workspace_templates.lua
-- Workspace template system - save/load workspace layouts with tabs, panes, and directories

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Template storage directory
local template_dir = wezterm.home_dir .. "/.core/cfg/wezterm/.data/workspace-templates"

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
		-- The calling code will handle the first pane separately
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

-- Save current workspace as template
local function save_workspace_template(window, pane, template_name, icon)
	wezterm.log_info("=== SAVE WORKSPACE TEMPLATE: " .. template_name .. " ===")

	ensure_template_dir()

	local workspace = window:active_workspace()
	local mux_window = window:mux_window()

	if not mux_window then
		window:toast_notification("WezTerm", "Cannot get window info", nil, 4000)
		return
	end

	local tabs = mux_window:tabs()
	local template_data = {
		name = template_name,
		icon = icon or "",
		saved_at = os.date("%Y-%m-%d %H:%M:%S"),
		tabs = {},
	}

	for i, tab in ipairs(tabs) do
		local tab_panes = tab:panes()
		local tab_id = tostring(tab:tab_id())

		-- Get custom tab data if it exists
		local custom_tab_data = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]
		local tab_title = tab:get_title() or "Tab " .. i
		local tab_icon = custom_tab_data and custom_tab_data.icon_key

		-- Get pane tree structure
		local pane_tree = tab:get_pane_tree()
		local pane_tree_data = build_pane_tree(pane_tree, tab_panes)

		local tab_data = {
			title = tab_title,
			icon = tab_icon,
			pane_tree = pane_tree_data, -- Save the tree structure
		}

		table.insert(template_data.tabs, tab_data)
	end

	local template_file = template_dir .. "/" .. template_name .. ".json"
	local json_str = wezterm.json_encode(template_data)

	local file, err = io.open(template_file, "w")
	if not file then
		window:toast_notification("WezTerm", "Failed to save: " .. tostring(err), nil, 4000)
		return
	end

	file:write(json_str)
	file:close()

	wezterm.log_info("Template saved with " .. #template_data.tabs .. " tabs")
	window:toast_notification("WezTerm", "✅ Template saved: " .. template_name, nil, 4000)
end

-- Prompt to save workspace as template with icon selection
function M.prompt_save_template(window, pane)
	local workspace = window:active_workspace()
	local default_name = workspace ~= "default" and workspace or ""

	-- First, prompt for template name
	window:perform_action(
		act.PromptInputLine({
			description = "💾 Save workspace template as:",
			initial_value = default_name,
			action = wezterm.action_callback(function(win, p, name)
				if not name or name == "" then
					win:toast_notification("WezTerm", "Cancelled", nil, 2000)
					return
				end

				-- Then, prompt for icon selection via nerdfont browser
				-- For now, just prompt for icon text
				win:perform_action(
					act.PromptInputLine({
						description = "🎨 Enter icon (or leave empty):",
						action = wezterm.action_callback(function(inner_win, inner_pane, icon)
							save_workspace_template(inner_win, inner_pane, name, icon or "")
						end),
					}),
					p
				)
			end),
		}),
		pane
	)
end

-- Load template into a new workspace
local function load_template_into_workspace(window, pane, template_name, workspace_name)
	wezterm.log_info("=== LOAD WORKSPACE TEMPLATE: " .. template_name .. " into " .. workspace_name .. " ===")

	local template_file = template_dir .. "/" .. template_name .. ".json"
	local file = io.open(template_file, "r")

	if not file then
		window:toast_notification("WezTerm", "❌ Template not found", nil, 4000)
		return
	end

	local content = file:read("*all")
	file:close()

	local template = wezterm.json_parse(content)
	if not template or not template.tabs then
		window:toast_notification("WezTerm", "❌ Invalid template file", nil, 4000)
		return
	end

	wezterm.log_info("Loading " .. #template.tabs .. " tabs into workspace " .. workspace_name)

	-- Spawn initial window and first tab with first pane
	local first_tab_data = template.tabs[1]

	-- Get the first leaf pane's cwd from the tree
	local function get_first_leaf_cwd(tree)
		if tree.is_leaf then
			return tree.cwd
		else
			return get_first_leaf_cwd(tree.children[1])
		end
	end

	local first_cwd = wezterm.home_dir
	if first_tab_data.pane_tree then
		first_cwd = extract_path(get_first_leaf_cwd(first_tab_data.pane_tree))
	elseif first_tab_data.panes and #first_tab_data.panes > 0 then
		-- Fallback for old format
		first_cwd = extract_path(first_tab_data.panes[1].cwd)
	end

	local first_tab, first_pane, new_window = wezterm.mux.spawn_window({
		workspace = workspace_name,
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

	-- Restore panes using tree structure or fall back to old method
	if first_tab_data.pane_tree then
		wezterm.log_info("  Restoring pane tree for tab 1")
		restore_pane_tree(first_tab_data.pane_tree, first_pane)
	elseif first_tab_data.panes then
		-- Fallback for old format (linear horizontal splits)
		local current_pane = first_pane
		for j = 2, #first_tab_data.panes do
			local cwd = extract_path(first_tab_data.panes[j].cwd)
			wezterm.log_info("  Creating pane " .. j .. " in tab 1 -> " .. cwd)
			local split_pane = current_pane:split({
				direction = "Right",
				cwd = cwd,
				size = 1.0 / #first_tab_data.panes,
			})
			split_pane:send_text("clear\n")
			wezterm.sleep_ms(150)
			current_pane = split_pane
		end
	end

	-- Restore additional tabs
	for i = 2, #template.tabs do
		local tab_data = template.tabs[i]

		-- Get first cwd from tree or old format
		local tab_first_cwd = wezterm.home_dir
		if tab_data.pane_tree then
			tab_first_cwd = extract_path(get_first_leaf_cwd(tab_data.pane_tree))
		elseif tab_data.panes and #tab_data.panes > 0 then
			tab_first_cwd = extract_path(tab_data.panes[1].cwd)
		end

		wezterm.log_info("Tab " .. i)
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

		-- Restore panes using tree structure or fall back to old method
		if tab_data.pane_tree then
			wezterm.log_info("  Restoring pane tree for tab " .. i)
			restore_pane_tree(tab_data.pane_tree, new_tab_pane)
		elseif tab_data.panes then
			-- Fallback for old format
			local current_pane = new_tab_pane
			for j = 2, #tab_data.panes do
				local cwd = extract_path(tab_data.panes[j].cwd)
				wezterm.log_info("  Creating pane " .. j .. " -> " .. cwd)
				local split_pane = current_pane:split({
					direction = "Right",
					cwd = cwd,
					size = 1.0 / #tab_data.panes,
				})
				split_pane:send_text("clear\n")
				wezterm.sleep_ms(150)
				current_pane = split_pane
			end
		end
	end

	wezterm.log_info("=== LOAD TEMPLATE COMPLETE ===")
	window:toast_notification("WezTerm", "✅ Loaded template: " .. template_name, nil, 4000)
end

-- Show template selector and load into new or existing workspace
function M.load_template(window, pane)
	local templates = list_templates()

	if #templates == 0 then
		window:toast_notification("WezTerm", "No workspace templates found", nil, 4000)
		return
	end

	local choices = {}
	for _, template_name in ipairs(templates) do
		-- Try to load template to get icon
		local template_file = template_dir .. "/" .. template_name .. ".json"
		local file = io.open(template_file, "r")
		local icon = ""

		if file then
			local content = file:read("*all")
			file:close()
			local success, template_data = pcall(wezterm.json_parse, content)
			if success and template_data and template_data.icon then
				icon = template_data.icon
				if icon ~= "" then
					icon = icon .. " "
				end
			end
		end

		table.insert(choices, { label = icon .. template_name, id = template_name })
	end

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if not id or id == "" then
					return
				end

				-- Prompt for workspace name
				win:perform_action(
					act.PromptInputLine({
						description = "🆕 Load template '" .. id .. "' into workspace:",
						initial_value = id,
						action = wezterm.action_callback(function(inner_win, inner_pane, workspace_name)
							if workspace_name and workspace_name ~= "" then
								load_template_into_workspace(inner_win, inner_pane, id, workspace_name)
							end
						end),
					}),
					p
				)
			end),
			title = "📋 Load Workspace Template",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Delete template
function M.delete_template(window, pane)
	local templates = list_templates()

	if #templates == 0 then
		window:toast_notification("WezTerm", "No workspace templates found", nil, 4000)
		return
	end

	local choices = {}
	for _, template_name in ipairs(templates) do
		-- Try to load template to get icon
		local template_file = template_dir .. "/" .. template_name .. ".json"
		local file = io.open(template_file, "r")
		local icon = ""

		if file then
			local content = file:read("*all")
			file:close()
			local success, template_data = pcall(wezterm.json_parse, content)
			if success and template_data and template_data.icon then
				icon = template_data.icon
				if icon ~= "" then
					icon = icon .. " "
				end
			end
		end

		table.insert(choices, { label = icon .. template_name, id = template_name })
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

-- Show template management menu
function M.show_menu(window, pane)
	local template_count = #list_templates()

	local choices = {
		{ id = "save", label = "💾 Save Current Workspace as Template" },
		{ id = "load", label = "📂 Load Template into New Workspace" },
		{ id = "delete", label = "🗑️  Delete Template" },
		{ id = "separator", label = "─────────────────────────────" },
		{ id = "info", label = "📊 Templates: " .. template_count },
	}

	window:perform_action(
		act.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id == "save" then
					M.prompt_save_template(win, p)
				elseif id == "load" then
					M.load_template(win, p)
				elseif id == "delete" then
					M.delete_template(win, p)
				end
			end),
			title = "📋 Workspace Templates",
			choices = choices,
			fuzzy = false,
		}),
		pane
	)
end

return M
