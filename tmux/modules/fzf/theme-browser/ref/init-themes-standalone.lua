#!/usr/bin/env lua
-- ~/.core/cfg/wezterm/scripts/init-themes-standalone.lua
-- Standalone theme initializer that doesn't require WezTerm running

-- Simple JSON encoder (no external dependencies)
local function escape_string(s)
	s = s:gsub("\\", "\\\\")
	s = s:gsub('"', '\\"')
	s = s:gsub("\n", "\\n")
	s = s:gsub("\r", "\\r")
	s = s:gsub("\t", "\\t")
	return s
end

local function simple_json_encode(t, indent)
	indent = indent or 0
	local spaces = string.rep("  ", indent)

	if type(t) == "string" then
		return '"' .. escape_string(t) .. '"'
	elseif type(t) == "number" then
		return tostring(t)
	elseif type(t) == "boolean" then
		return tostring(t)
	elseif type(t) == "nil" then
		return "null"
	elseif type(t) == "table" then
		-- Check if array
		local is_array = true
		local count = 0
		for k, v in pairs(t) do
			count = count + 1
			if type(k) ~= "number" or k ~= count then
				is_array = false
				break
			end
		end

		if is_array then
			if count == 0 then
				return "[]"
			end
			local parts = {}
			for i, v in ipairs(t) do
				table.insert(parts, simple_json_encode(v, indent + 1))
			end
			return "[" .. table.concat(parts, ",") .. "]"
		else
			local parts = {}
			for k, v in pairs(t) do
				local key = '"' .. escape_string(tostring(k)) .. '"'
				local value = simple_json_encode(v, indent + 1)
				table.insert(parts, key .. ":" .. value)
			end
			if #parts == 0 then
				return "{}"
			end
			return "{" .. table.concat(parts, ",") .. "}"
		end
	end

	return "null"
end

-- Get all WezTerm themes (hardcoded list of common themes)
local function get_default_themes()
	return {
		-- Dark themes
		"Tokyo Night",
		"Tokyo Night Moon",
		"Tokyo Night Storm",
		"Dracula",
		"Dracula (Official)",
		"Dracula+",
		"Gruvbox Dark",
		"GruvboxDark",
		"GruvboxDarkHard",
		"Nord",
		"nord",
		"One Dark",
		"OneDark",
		"OneHalfDark",
		"Solarized Dark",
		"Solarized Darcula",
		"Solarized Dark - Patched",
		"Catppuccin Mocha",
		"Catppuccin Macchiato",
		"Catppuccin Frappe",
		"Rose Pine",
		"Rose Pine Moon",
		"rose-pine",
		"rose-pine-moon",
		"Material",
		"MaterialDark",
		"MaterialDarker",
		"MaterialOcean",
		"Palenight",
		"Material Palenight",
		"Ayu Dark",
		"Ayu Mirage",
		"Monokai",
		"Monokai Remastered",
		"Monokai Soda",
		"Tomorrow Night",
		"Tomorrow Night Eighties",
		"Tomorrow Night Blue",
		"Zenburn",
		"zenburn",
		"Everforest Dark",
		"Kanagawa",
		"Nightfox",
		"duskfox",
		"nordfox",
		"terafox",
		"carbonfox",
		"GitHub Dark",
		"Doom One",
		"DoomOne",
		"Spacemacs",
		"Synthwave",
		"SynthwaveAlpha",
		"synthwave-everything",

		-- Light themes
		"Solarized Light",
		"Catppuccin Latte",
		"Rose Pine Dawn",
		"rose-pine-dawn",
		"Ayu Light",
		"Github",
		"GitHub Light",
		"Tomorrow",
		"One Light",
		"OneHalfLight",
		"Gruvbox Light",
		"Material Lighter",
		"Papercolor Light",
		"Everforest Light",
		"dawnfox",
		"dayfox",

		-- High contrast
		"High Contrast",
		"Windows High Contrast",

		-- Others
		"Apprentice",
		"Ashes",
		"Atom",
		"Bespin",
		"Brewer",
		"Bright",
		"Chalk",
		"Circus",
		"Classic",
		"Codeschool",
		"Cupcake",
		"Default",
		"Eighties",
		"Embers",
		"Flat",
		"Forest",
		"Fruit Soda",
		"Helios",
		"Hopscotch",
		"Horizon",
		"Hybrid",
		"Isotope",
		"Kimber",
		"Marrakesh",
		"Materia",
		"Mellow Purple",
		"Mexico",
		"Mocha",
		"Ocean",
		"Paraiso",
		"PhD",
		"Pop",
		"Railscasts",
		"Rebecca",
		"Seti",
		"Shapeshifter",
		"Silk",
		"Solar Flare",
		"Summerfruit",
		"Twilight",
		"Unikitty",
		"Woodland",
		"XCode Dusk",
	}
end

-- Analyze theme name to determine metadata
local function analyze_theme(name)
	local metadata = {
		category = "dark",
		brightness = 128,
		temperature = "neutral",
		saturation = "normal",
	}

	local lower = name:lower()

	-- Determine category
	if
		lower:match("light")
		or lower:match("dawn")
		or lower:match("latte")
		or lower:match("day")
		or lower:match("bright")
		or lower:match("paper")
	then
		metadata.category = "light"
		metadata.brightness = 200
	elseif lower:match("high.?contrast") or lower:match("hc") then
		metadata.category = "high-contrast"
		metadata.brightness = 20
	elseif lower:match("pastel") or lower:match("soft") then
		metadata.category = "pastel"
		metadata.brightness = 160
	else
		metadata.category = "dark"
		metadata.brightness = 60
	end

	-- Determine temperature
	if lower:match("warm") or lower:match("orange") or lower:match("autumn") then
		metadata.temperature = "warm"
	elseif lower:match("cool") or lower:match("blue") or lower:match("winter") or lower:match("nord") then
		metadata.temperature = "cool"
	end

	return metadata
end

-- Generate tags for theme
local function generate_tags(name)
	local tags = {}
	local lower = name:lower()

	local tag_patterns = {
		"dark",
		"light",
		"monokai",
		"solarized",
		"gruvbox",
		"dracula",
		"catppuccin",
		"tokyo",
		"nord",
		"material",
		"ocean",
		"forest",
		"neon",
		"retro",
		"vintage",
	}

	for _, pattern in ipairs(tag_patterns) do
		if lower:match(pattern) then
			table.insert(tags, pattern)
		end
	end

	return tags
end

-- Main
local function main()
	local home = os.getenv("HOME") or os.getenv("USERPROFILE")
	local data_dir = home .. "/.core/cfg/wezterm/data"
	local themes_file = data_dir .. "/themes.json"

	-- Check if already exists
	local f = io.open(themes_file, "r")
	if f then
		f:close()
		print("Theme data already exists at: " .. themes_file)
		print("Delete it first if you want to reinitialize")
		return
	end

	print("Initializing WezTerm theme data...")

	-- Create directory
	os.execute("mkdir -p " .. data_dir)

	-- Get themes
	local theme_list = get_default_themes()

	-- Build theme data
	local theme_data = {
		version = "1.0",
		generated = os.date("%Y-%m-%d %H:%M:%S"),
		themes = {},
	}

	for _, name in ipairs(theme_list) do
		local theme_info = {
			name = name,
			colors = {
				background = "#1a1b26", -- Default colors
				foreground = "#c0caf5",
				cursor_bg = "#c0caf5",
				cursor_fg = "#1a1b26",
			},
			metadata = analyze_theme(name),
			tags = generate_tags(name),
			is_favorite = false,
			is_deleted = false,
			added_date = os.time(),
		}

		table.insert(theme_data.themes, theme_info)
	end

	-- Sort alphabetically
	table.sort(theme_data.themes, function(a, b)
		return a.name < b.name
	end)

	-- Write to file
	local f = io.open(themes_file, "w")
	if f then
		f:write(simple_json_encode(theme_data))
		f:close()
		print("Initialized " .. #theme_data.themes .. " themes")
		print("Saved to: " .. themes_file)

		-- Also create the export file
		local export_file = "/tmp/wezterm_themes_export.json"
		local export_data = {
			themes = {},
			favorites = {},
			deleted = {},
			current_session = "default",
			current_theme = nil,
		}

		for _, theme in ipairs(theme_data.themes) do
			table.insert(export_data.themes, {
				name = theme.name,
				category = theme.metadata.category,
				brightness = theme.metadata.brightness,
				temperature = theme.metadata.temperature,
				is_favorite = false,
				tags = theme.tags,
			})
		end

		f = io.open(export_file, "w")
		if f then
			f:write(simple_json_encode(export_data))
			f:close()
			print("Created export at: " .. export_file)
		end
	else
		print("Failed to write theme data")
		os.exit(1)
	end
end

main()
