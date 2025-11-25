-- Generate theme data for the theme browser
-- This script extracts all available WezTerm color schemes and their metadata
-- Usage: wezterm --config-file scripts/theme-browser/generate-themes-data.lua

local wezterm = require("wezterm")
local home = os.getenv("HOME")

-- Output file
local data_dir = home .. "/.core/.sys/configs/wezterm/scripts/theme-browser/data"
local output_file = data_dir .. "/themes.json"

-- Ensure data directory exists
os.execute('mkdir -p "' .. data_dir .. '"')

-- Get all builtin color schemes
local schemes = wezterm.color.get_builtin_schemes()

-- Build theme list with metadata
local themes = {}

for name, scheme in pairs(schemes) do
	-- Analyze the theme to categorize it
	local bg = scheme.background or "#000000"
	local fg = scheme.foreground or "#FFFFFF"

	-- Simple brightness calculation (0-255)
	local function hex_to_brightness(hex)
		local r = tonumber(hex:sub(2, 3), 16) or 0
		local g = tonumber(hex:sub(4, 5), 16) or 0
		local b = tonumber(hex:sub(6, 7), 16) or 0
		return (r * 0.299 + g * 0.587 + b * 0.114)
	end

	local brightness = hex_to_brightness(bg)

	-- Categorize theme
	local category = "dark"
	if brightness > 128 then
		category = "light"
	end

	-- Temperature (warm/cool/neutral) based on color balance
	local function hex_to_temperature(hex)
		local r = tonumber(hex:sub(2, 3), 16) or 0
		local g = tonumber(hex:sub(4, 5), 16) or 0
		local b = tonumber(hex:sub(6, 7), 16) or 0

		if r > g + 20 and r > b + 20 then
			return "warm"
		elseif b > r + 20 and b > g + 20 then
			return "cool"
		else
			return "neutral"
		end
	end

	local temperature = hex_to_temperature(bg)

	-- Add to themes list
	table.insert(themes, {
		name = name,
		category = category,
		brightness = math.floor(brightness),
		temperature = temperature,
		background = bg,
		foreground = fg,
		-- Add ANSI colors for preview
		ansi = scheme.ansi or {},
		brights = scheme.brights or {},
	})
end

-- Sort themes alphabetically
table.sort(themes, function(a, b)
	return a.name < b.name
end)

-- Create output JSON
local output = {
	generated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	theme_count = #themes,
	themes = themes,
}

-- Write to file
local json = wezterm.json_encode(output)
local f = io.open(output_file, "w")
if not f then
	print("Error: Failed to open output file: " .. output_file)
	os.exit(1)
end

f:write(json)
f:close()

print("✓ Generated theme data: " .. output_file)
print("  Total themes: " .. #themes)

os.exit(0)
