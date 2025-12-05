-- Tab Metadata Persistence System
-- Auto-saves tab metadata (title, icon, color, cwd) when changes occur
-- Provides hooks for real-time updates

local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

-- Storage file for tab metadata
local storage_file = paths.WEZTERM_DATA .. "/tabs/metadata.json"

-- Ensure storage directory exists
local function ensure_storage_dir()
	os.execute('mkdir -p "' .. paths.WEZTERM_DATA .. '/tabs"')
end

-- Load all tab metadata from disk
function M.load_all()
	ensure_storage_dir()

	local file = io.open(storage_file, "r")
	if not file then
		return {}
	end

	local content = file:read("*all")
	file:close()

	if content == "" then
		return {}
	end

	local success, data = pcall(wezterm.json_parse, content)
	if not success then
		wezterm.log_error("[TAB_METADATA] Failed to parse metadata file: " .. tostring(data))
		return {}
	end

	return data or {}
end

-- Save all tab metadata to disk
function M.save_all(metadata)
	ensure_storage_dir()

	local json_str = wezterm.json_encode(metadata)

	local file, err = io.open(storage_file, "w")
	if not file then
		wezterm.log_error("[TAB_METADATA] Failed to save metadata: " .. tostring(err))
		return false
	end

	file:write(json_str)
	file:close()

	return true
end

-- Get metadata for a specific tab
function M.get_tab(tab_id)
	local all_metadata = M.load_all()
	return all_metadata[tostring(tab_id)]
end

-- Update metadata for a specific tab
function M.update_tab(tab_id, metadata)
	local all_metadata = M.load_all()
	local tab_id_str = tostring(tab_id)

	-- Merge with existing data
	if not all_metadata[tab_id_str] then
		all_metadata[tab_id_str] = {}
	end

	for key, value in pairs(metadata) do
		all_metadata[tab_id_str][key] = value
	end

	-- Add timestamp
	all_metadata[tab_id_str].updated_at = os.date("%Y-%m-%d %H:%M:%S")

	M.save_all(all_metadata)
	wezterm.log_info("[TAB_METADATA] Updated tab " .. tab_id_str .. ": " .. wezterm.json_encode(metadata))
end

-- Remove metadata for a tab
function M.remove_tab(tab_id)
	local all_metadata = M.load_all()
	all_metadata[tostring(tab_id)] = nil
	M.save_all(all_metadata)
end

-- Capture current state of a tab
function M.capture_tab_state(tab)
	local tab_id = tab:tab_id()
	local panes = tab:panes()

	-- Get tab title
	local custom_tabs = wezterm.GLOBAL.custom_tabs
	local custom_data = custom_tabs and custom_tabs[tostring(tab_id)]
	local title = (custom_data and custom_data.title) or tab:get_title() or ""

	-- Get tab icon
	local icon = (custom_data and custom_data.icon_key) or ""

	-- Get tab color
	local tab_color_picker = require("modules.tabs.tab_color_picker")
	local color = tab_color_picker.get_tab_color(tostring(tab_id))

	-- Get CWD from first pane
	local cwd = ""
	if #panes > 0 then
		local raw_cwd = panes[1]:get_current_working_dir()
		if raw_cwd then
			if type(raw_cwd) == "table" and raw_cwd.file_path then
				cwd = raw_cwd.file_path
			else
				cwd = tostring(raw_cwd):gsub("^file://[^/]+", ""):gsub("^file://", "")
			end
		end
	end

	-- Get workspace
	local mux_window = tab:window()
	local workspace = "default"
	if mux_window then
		workspace = mux_window:get_workspace() or "default"
	end

	local metadata = {
		title = title,
		icon = icon,
		color = color,
		cwd = cwd,
		workspace = workspace,
		pane_count = #panes,
	}

	M.update_tab(tab_id, metadata)
	return metadata
end

-- Setup hooks to auto-capture tab metadata on changes
function M.setup_hooks()
	-- Hook: When tab title changes (via user-var or direct set_title)
	wezterm.on("tab-title-changed", function(tab)
		wezterm.log_info("[TAB_METADATA] Tab title changed, capturing state")
		M.capture_tab_state(tab)
	end)

	-- Hook: When tab color changes
	wezterm.on("tab-color-changed", function(tab)
		wezterm.log_info("[TAB_METADATA] Tab color changed, capturing state")
		M.capture_tab_state(tab)
	end)

	-- Hook: When tab icon changes
	wezterm.on("tab-icon-changed", function(tab)
		wezterm.log_info("[TAB_METADATA] Tab icon changed, capturing state")
		M.capture_tab_state(tab)
	end)

	-- Hook: When tab is closed
	wezterm.on("mux-tab-closed", function(tab_id)
		wezterm.log_info("[TAB_METADATA] Tab closed, removing metadata")
		M.remove_tab(tab_id)
	end)

	wezterm.log_info("[TAB_METADATA] Hooks installed for auto-capture")
end

-- Capture all tabs in current window
function M.capture_all_tabs(window)
	local mux_window = window:mux_window()
	if not mux_window then
		return
	end

	local tabs = mux_window:tabs()
	for _, tab in ipairs(tabs) do
		M.capture_tab_state(tab)
	end

	wezterm.log_info("[TAB_METADATA] Captured " .. #tabs .. " tabs")
end

return M
