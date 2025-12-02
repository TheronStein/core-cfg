local wezterm = require("wezterm")
local mux = wezterm.mux

local M = {}

M.workspace_dir = wezterm.config_dir .. "/.state/workspaces"

-- Ensure directory exists
function M.ensure_dir()
	os.execute("mkdir -p " .. M.workspace_dir)
end

-- Get path for workspace definition file
function M.get_workspace_file(name)
	return string.format("%s/%s.json", M.workspace_dir, name)
end

-- Save workspace definition
function M.save_workspace(name, definition)
	M.ensure_dir()

	local file = io.open(M.get_workspace_file(name), "w")
	if file then
		file:write(wezterm.json_encode(definition))
		file:close()
		wezterm.log_info("Saved workspace: " .. name)
		return true
	end

	wezterm.log_error("Failed to save workspace: " .. name)
	return false
end

-- Load workspace definition
function M.load_workspace(name)
	local file = io.open(M.get_workspace_file(name), "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	local success, definition = pcall(wezterm.json_parse, content)
	if success then
		return definition
	end

	wezterm.log_error("Failed to parse workspace: " .. name)
	return nil
end

-- List all saved workspaces
function M.list_workspaces()
	M.ensure_dir()

	local workspaces = {}
	local handle = io.popen("ls " .. M.workspace_dir .. "/*.json 2>/dev/null")

	if handle then
		for filename in handle:lines() do
			local name = filename:match("([^/]+)%.json$")
			if name then
				table.insert(workspaces, name)
			end
		end
		handle:close()
	end

	return workspaces
end

-- Delete workspace definition
function M.delete_workspace(name)
	local file_path = M.get_workspace_file(name)
	local success = os.remove(file_path)

	if success then
		wezterm.log_info("Deleted workspace: " .. name)
	else
		wezterm.log_error("Failed to delete workspace: " .. name)
	end

	return success
end

-- Capture current window state as workspace definition
function M.capture_current(window, name)
	local mux_window = window:mux_window()
	if not mux_window then
		return nil
	end

	local tabs = {}

	for _, tab in ipairs(mux_window:tabs()) do
		local panes = {}

		for _, pane in ipairs(tab:panes()) do
			table.insert(panes, {
				cwd = pane:get_current_working_dir() or wezterm.home_dir,
			})
		end

		table.insert(tabs, {
			title = tab:get_title(),
			panes = panes,
		})
	end

	local definition = {
		name = name,
		created = os.time(),
		tabs = tabs,
	}

	return definition
end

-- Spawn workspace from definition
function M.spawn_from_definition(definition)
	if not definition or not definition.tabs or #definition.tabs == 0 then
		return nil
	end

	-- Create first tab
	local first_tab_def = definition.tabs[1]
	local first_pane_def = first_tab_def.panes[1]

	local tab, pane, window = mux.spawn_window({
		workspace = definition.name,
		cwd = first_pane_def.cwd,
	})

	if first_tab_def.title then
		tab:set_title(first_tab_def.title)
	end

	-- Create additional panes in first tab (splits)
	for i = 2, #first_tab_def.panes do
		pane:split({
			cwd = first_tab_def.panes[i].cwd,
		})
	end

	-- Create remaining tabs
	for i = 2, #definition.tabs do
		local tab_def = definition.tabs[i]
		local new_tab, new_pane = window:spawn_tab({
			cwd = tab_def.panes[1].cwd,
		})

		if tab_def.title then
			new_tab:set_title(tab_def.title)
		end

		-- Create panes in this tab
		for j = 2, #tab_def.panes do
			new_pane:split({
				cwd = tab_def.panes[j].cwd,
			})
		end
	end

	return window
end

-- Check if workspace exists in mux and spawn if not
function M.ensure_workspace(name)
	-- Check if already loaded
	for _, w in ipairs(mux.all_windows()) do
		if w:get_workspace() == name then
			return true
		end
	end

	-- Try to load from disk
	local definition = M.load_workspace(name)
	if definition then
		M.spawn_from_definition(definition)
		return true
	end

	return false
end

return M
