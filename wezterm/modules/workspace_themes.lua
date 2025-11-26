-- Workspace-specific theme manager
-- Manages themes per workspace with JSON persistence

local wezterm = require("wezterm")
local paths = require("utils.paths")
local debug_config = require("config.debug")
local DEBUG = debug_config.debug_mods_workspace or debug_config.debug_all

local M = {}

-- Path to workspace themes storage
M.themes_dir = paths.WEZTERM_STATE .. "/workspace-themes"
M.themes_file = M.themes_dir .. "/themes.json"

-- Ensure the themes directory exists
local function ensure_dir()
	local success, err = pcall(function()
		os.execute('mkdir -p "' .. M.themes_dir .. '"')
	end)
	if not success then
		if DEBUG then
			wezterm.log_error("Failed to create workspace themes directory: " .. tostring(err))
		end
	end
end

-- Load workspace themes from JSON
function M.load_themes()
	ensure_dir()

	local f = io.open(M.themes_file, "r")
	if not f then
		-- Return empty table if file doesn't exist yet
		return {}
	end

	local content = f:read("*all")
	f:close()

	if content == "" or content == nil then
		return {}
	end

	local success, themes = pcall(function()
		return wezterm.json_parse(content)
	end)

	if not success then
		if DEBUG then
			wezterm.log_error("Failed to parse workspace themes JSON: " .. tostring(themes))
		end
		return {}
	end

	return themes or {}
end

-- Save workspace themes to JSON
function M.save_themes(themes)
	ensure_dir()

	local json_content = wezterm.json_encode(themes)

	local f = io.open(M.themes_file, "w")
	if not f then
		if DEBUG then
			wezterm.log_error("Failed to open workspace themes file for writing: " .. M.themes_file)
		end
		return false
	end

	f:write(json_content)
	f:close()

	if DEBUG then
		wezterm.log_info("Saved workspace themes to " .. M.themes_file)
	end
	return true
end

-- Get theme for a specific workspace
function M.get_workspace_theme(workspace_name)
	if not workspace_name or workspace_name == "" then
		return nil
	end

	local themes = M.load_themes()
	return themes[workspace_name]
end

-- Set theme for a specific workspace
function M.set_workspace_theme(workspace_name, theme_name)
	if not workspace_name or workspace_name == "" then
		if DEBUG then
			wezterm.log_error("Invalid workspace name")
		end
		return false
	end

	if not theme_name or theme_name == "" then
		if DEBUG then
			wezterm.log_error("Invalid theme name")
		end
		return false
	end

	local themes = M.load_themes()
	themes[workspace_name] = {
		theme = theme_name,
		updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- ISO 8601 format
	}

	return M.save_themes(themes)
end

-- Remove theme for a specific workspace (revert to default)
function M.remove_workspace_theme(workspace_name)
	if not workspace_name or workspace_name == "" then
		return false
	end

	local themes = M.load_themes()
	themes[workspace_name] = nil

	return M.save_themes(themes)
end

-- Get all workspace themes
function M.get_all_themes()
	return M.load_themes()
end

-- Apply theme to current window based on workspace
function M.apply_workspace_theme(window, workspace_name)
	if not window or not workspace_name then
		return
	end

	local theme_data = M.get_workspace_theme(workspace_name)
	if not theme_data or not theme_data.theme then
		-- No specific theme for this workspace, don't change anything
		return
	end

	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = theme_data.theme

	window:set_config_overrides(overrides)
	if DEBUG then
		wezterm.log_info("Applied theme '" .. theme_data.theme .. "' to workspace '" .. workspace_name .. "'")
	end
end

return M
