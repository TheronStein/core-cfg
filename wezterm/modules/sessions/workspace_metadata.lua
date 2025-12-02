-- ~/.core/.sys/cfg/wezterm/modules/sessions/workspace_metadata.lua
-- Workspace metadata management (color, icon, theme, timestamps)
-- Persistent storage of workspace-specific settings

local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

-- Metadata directory
local metadata_dir = paths.WEZTERM_DATA .. "/workspace-metadata"

-- Ensure metadata directory exists
local function ensure_metadata_dir()
	os.execute('mkdir -p "' .. metadata_dir .. '"')
	return true
end

-- Get metadata file path for workspace
local function get_metadata_path(workspace_name)
	return metadata_dir .. "/" .. workspace_name .. ".json"
end

-- Default metadata structure
local function default_metadata(workspace_name)
	return {
		name = workspace_name,
		icon = "",
		color = "",
		theme = "",
		created_at = os.date("%Y-%m-%d %H:%M:%S"),
		modified_at = os.date("%Y-%m-%d %H:%M:%S"),
	}
end

-- Read metadata for workspace
local function read_metadata(workspace_name)
	local metadata_path = get_metadata_path(workspace_name)
	local file = io.open(metadata_path, "r")

	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()

	if content == "" then
		return nil
	end

	local success, metadata = pcall(wezterm.json_parse, content)
	if not success or not metadata then
		wezterm.log_warn("Failed to parse metadata file: " .. metadata_path)
		return nil
	end

	return metadata
end

-- Write metadata for workspace
local function write_metadata(workspace_name, metadata)
	ensure_metadata_dir()
	local metadata_path = get_metadata_path(workspace_name)

	-- Update modified timestamp
	metadata.modified_at = os.date("%Y-%m-%d %H:%M:%S")

	local file = io.open(metadata_path, "w")
	if not file then
		wezterm.log_error("Failed to write metadata file: " .. metadata_path)
		return false
	end

	local json_str = wezterm.json_encode(metadata)
	file:write(json_str)
	file:close()

	wezterm.log_info("Saved metadata for workspace: " .. workspace_name)
	return true
end

-- Get workspace metadata (creates default if not exists)
function M.get_metadata(workspace_name)
	local metadata = read_metadata(workspace_name)
	if not metadata then
		-- Create default metadata
		metadata = default_metadata(workspace_name)
		write_metadata(workspace_name, metadata)
	end
	return metadata
end

-- Update metadata fields
function M.update_metadata(workspace_name, updates)
	local metadata = M.get_metadata(workspace_name)

	-- Apply updates
	for key, value in pairs(updates) do
		if key ~= "created_at" and key ~= "name" then -- Don't allow changing these
			metadata[key] = value
		end
	end

	return write_metadata(workspace_name, metadata)
end

-- Get workspace icon
function M.get_icon(workspace_name)
	local metadata = M.get_metadata(workspace_name)
	return metadata.icon or ""
end

-- Set workspace icon
function M.set_icon(workspace_name, icon)
	return M.update_metadata(workspace_name, { icon = icon or "" })
end

-- Get workspace color
function M.get_color(workspace_name)
	local metadata = M.get_metadata(workspace_name)
	return metadata.color or ""
end

-- Set workspace color
function M.set_color(workspace_name, color)
	return M.update_metadata(workspace_name, { color = color or "" })
end

-- Get workspace theme
function M.get_theme(workspace_name)
	local metadata = M.get_metadata(workspace_name)
	return metadata.theme or ""
end

-- Set workspace theme
function M.set_theme(workspace_name, theme)
	wezterm.log_info("Setting theme for workspace '" .. workspace_name .. "': " .. (theme or ""))
	return M.update_metadata(workspace_name, { theme = theme or "" })
end

-- Delete metadata for workspace
function M.delete_metadata(workspace_name)
	local metadata_path = get_metadata_path(workspace_name)
	local success = os.remove(metadata_path)

	if success then
		wezterm.log_info("Deleted metadata for workspace: " .. workspace_name)
	end

	return success
end

-- List all workspaces with metadata
function M.list_all_metadata()
	ensure_metadata_dir()
	local all_metadata = {}

	local handle = io.popen('ls -1 "' .. metadata_dir .. '"/*.json 2>/dev/null')
	if not handle then
		return all_metadata
	end

	for file in handle:lines() do
		local workspace_name = file:match("([^/]+)%.json$")
		if workspace_name then
			local metadata = read_metadata(workspace_name)
			if metadata then
				table.insert(all_metadata, metadata)
			end
		end
	end

	handle:close()

	-- Sort by modified_at (most recent first)
	table.sort(all_metadata, function(a, b)
		return (a.modified_at or "") > (b.modified_at or "")
	end)

	return all_metadata
end

-- Clean up metadata for non-existent workspaces
function M.cleanup_orphaned_metadata()
	local active_workspaces = {}
	for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
		active_workspaces[ws] = true
	end

	local count = 0
	local all_metadata = M.list_all_metadata()

	for _, metadata in ipairs(all_metadata) do
		if not active_workspaces[metadata.name] then
			wezterm.log_info("Cleaning orphaned metadata: " .. metadata.name)
			M.delete_metadata(metadata.name)
			count = count + 1
		end
	end

	wezterm.log_info("Cleaned up " .. count .. " orphaned metadata files")
	return count
end

-- Show workspace metadata browser
function M.show_metadata_browser(window, pane)
	local all_metadata = M.list_all_metadata()

	if #all_metadata == 0 then
		window:toast_notification("WezTerm", "No workspace metadata found", nil, 2000)
		return
	end

	local choices = {
		{ id = "__header__", label = "=== Workspace Metadata ===" },
		{ id = "__separator__", label = "─────────────────────────────" },
	}

	for _, metadata in ipairs(all_metadata) do
		local icon_display = (metadata.icon and metadata.icon ~= "") and (metadata.icon .. " ") or ""
		local color_display = (metadata.color and metadata.color ~= "") and "🎨 " or ""
		local theme_display = (metadata.theme and metadata.theme ~= "") and ("🌈" .. metadata.theme .. " ") or ""

		local label = string.format(
			"%s%s%s%s (modified: %s)",
			icon_display,
			color_display,
			metadata.name,
			theme_display ~= "" and " - " .. theme_display or "",
			metadata.modified_at or "unknown"
		)

		table.insert(choices, {
			id = metadata.name,
			label = label,
		})
	end

	table.insert(choices, { id = "__separator2__", label = "─────────────────────────────" })
	table.insert(choices, { id = "__cleanup__", label = "🧹 Clean Up Orphaned Metadata" })

	window:perform_action(
		wezterm.action.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id == "__cleanup__" then
					local cleaned = M.cleanup_orphaned_metadata()
					win:toast_notification("WezTerm", "Cleaned " .. cleaned .. " orphaned metadata files", nil, 2000)
				elseif id and id:sub(1, 2) ~= "__" then
					-- Show metadata details
					local metadata = M.get_metadata(id)
					local details = string.format(
						"Workspace: %s\nIcon: %s\nColor: %s\nTheme: %s\nCreated: %s\nModified: %s",
						metadata.name,
						metadata.icon or "(none)",
						metadata.color or "(none)",
						metadata.theme or "(none)",
						metadata.created_at or "(unknown)",
						metadata.modified_at or "(unknown)"
					)
					win:toast_notification("WezTerm", details, nil, 5000)
				end
			end),
			title = "📊 Workspace Metadata (" .. #all_metadata .. " workspaces)",
			choices = choices,
			fuzzy = true,
		}),
		pane
	)
end

-- Sync workspace icon to/from global state
-- This maintains compatibility with existing workspace_manager code
function M.sync_icon_to_global(workspace_name)
	local icon = M.get_icon(workspace_name)
	if not wezterm.GLOBAL.workspace_icons then
		wezterm.GLOBAL.workspace_icons = {}
	end
	wezterm.GLOBAL.workspace_icons[workspace_name] = icon
	return icon
end

function M.sync_icon_from_global(workspace_name)
	if wezterm.GLOBAL.workspace_icons and wezterm.GLOBAL.workspace_icons[workspace_name] then
		local icon = wezterm.GLOBAL.workspace_icons[workspace_name]
		M.set_icon(workspace_name, icon)
		return icon
	end
	return ""
end

-- Initialize: ensure metadata directory exists
function M.init()
	ensure_metadata_dir()
	wezterm.log_info("Workspace metadata system initialized")
end

return M
