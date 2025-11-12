#!/usr/bin/env wezterm
-- ~/.core/cfg/wezterm/scripts/init-themes.lua
-- Initialize theme data for WezTerm

-- Add path for our modules
local home = os.getenv("HOME") or "/home/user"
package.path = package.path .. ";" .. home .. "/.core/cfg/wezterm/?.lua"

local wezterm = require("wezterm")
local theme_manager = require("extra.theme_manager")

-- Initialize theme data
print("Initializing WezTerm theme data...")
local success = theme_manager.init_theme_data()

if success then
	print("✓ Theme data initialized successfully")

	-- Export for fzf
	if theme_manager.export_for_fzf() then
		print("✓ Exported theme data for fzf browser")
	else
		print("✗ Failed to export theme data")
		os.exit(1)
	end
else
	print("✗ Failed to initialize theme data")
	os.exit(1)
end

print("\nTheme files created:")
print("  " .. theme_manager.themes_file)
print("  " .. theme_manager.favorites_file)
print("  " .. theme_manager.deleted_file)
print("  /tmp/wezterm_themes_export.json")

os.exit(0)
