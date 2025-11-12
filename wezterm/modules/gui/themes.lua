local wezterm = require("wezterm")
local M = {}

-- Paths
local home = os.getenv("HOME")
local data_dir = home .. "/.core/cfg/wezterm/.data"
M.themes_file = data_dir .. "/themes.json"
M.favorites_file = data_dir .. "/favorite-themes.json"
M.deleted_file = data_dir .. "/deleted-themes.json"
M.preview_file = "/tmp/wezterm_theme_preview.txt"

-- Ensure data directory exists
local function ensure_dir()
	os.execute("mkdir -p " .. data_dir)
end

-- Get only dark themes
local function get_dark_themes()
	local schemes = wezterm.color.get_builtin_schemes()
	local dark = {}

	for name, scheme in pairs(schemes) do
		-- Parse background color
		local bg = wezterm.color.parse(scheme.background)
		-- Extract HSLA information
		local h, s, l, a = bg:hsla()
		-- l is lightness: 0 = darkest, 1 = lightest
		-- Only include themes with lightness < 0.4
		if l < 0.4 then
			table.insert(dark, name)
		end
	end

	table.sort(dark)
	return dark
end

-- Load JSON file
local function load_json(filepath)
	local f = io.open(filepath, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()

	local ok, data = pcall(wezterm.json_parse, content)
	if ok and data then
		return data
	end
	return nil
end

-- Save JSON file
local function save_json(filepath, data)
	local f = io.open(filepath, "w")
	if not f then
		return false
	end
	f:write(wezterm.json_encode(data))
	f:close()
	return true
end

-- Initialize theme data
function M.setup()
	ensure_dir()

	-- Check if themes already exist
	local existing = load_json(M.themes_file)
	if existing then
		wezterm.log_info("Theme data already exists")
		return true
	end

	-- Get dark themes
	local dark_themes = get_dark_themes()

	-- Create theme data structure
	local theme_data = {
		version = "1.0",
		generated = os.date("%Y-%m-%d %H:%M:%S"),
		themes = dark_themes,
		count = #dark_themes,
	}

	-- Save themes
	if save_json(M.themes_file, theme_data) then
		wezterm.log_info("Initialized " .. #dark_themes .. " dark themes")

		-- Initialize empty favorites and deleted
		save_json(M.favorites_file, { themes = {} })
		save_json(M.deleted_file, { themes = {} })

		return true
	end

	return false
end

-- Load themes list
function M.load_themes()
	local data = load_json(M.themes_file)
	if not data then
		M.init_themes()
		data = load_json(M.themes_file)
	end
	return data and data.themes or {}
end

-- Load favorites
function M.load_favorites()
	local data = load_json(M.favorites_file)
	return data and data.themes or {}
end

-- Load deleted themes
function M.load_deleted()
	local data = load_json(M.deleted_file)
	return data and data.themes or {}
end

-- Add to favorites
function M.add_favorite(theme_name)
	local favorites = M.load_favorites()

	-- Check if already in favorites
	for _, name in ipairs(favorites) do
		if name == theme_name then
			return true
		end
	end

	table.insert(favorites, theme_name)
	table.sort(favorites)

	return save_json(M.favorites_file, { themes = favorites })
end

-- Remove from favorites
function M.remove_favorite(theme_name)
	local favorites = M.load_favorites()
	local new_favorites = {}

	for _, name in ipairs(favorites) do
		if name ~= theme_name then
			table.insert(new_favorites, name)
		end
	end

	return save_json(M.favorites_file, { themes = new_favorites })
end

-- Mark theme as deleted
function M.mark_deleted(theme_name)
	local deleted = M.load_deleted()

	-- Check if already deleted
	for _, name in ipairs(deleted) do
		if name == theme_name then
			return true
		end
	end

	table.insert(deleted, theme_name)
	table.sort(deleted)

	return save_json(M.deleted_file, { themes = deleted })
end

-- Get active themes (not deleted)
function M.get_active_themes()
	local all_themes = M.load_themes()
	local deleted = M.load_deleted()
	local active = {}

	-- Create lookup table for deleted themes
	local deleted_lookup = {}
	for _, name in ipairs(deleted) do
		deleted_lookup[name] = true
	end

	-- Filter out deleted themes
	for _, name in ipairs(all_themes) do
		if not deleted_lookup[name] then
			table.insert(active, name)
		end
	end

	return active
end

-- Watch preview file and update theme
function M.start_preview_watcher(window)
	local function check_preview()
		local f = io.open(M.preview_file, "r")
		if f then
			local theme = f:read("*line")
			f:close()

			if theme and theme ~= "" and theme ~= "INIT" then
				local overrides = window:get_config_overrides() or {}
				overrides.color_scheme = theme
				window:set_config_overrides(overrides)
			end
		end

		wezterm.time.call_after(0.1, check_preview)
	end

	check_preview()
end

return M
