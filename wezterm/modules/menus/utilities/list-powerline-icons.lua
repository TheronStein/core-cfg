#!/usr/bin/env -S wezterm start --always-new-process --

-- Script to list all available powerline icons in WezTerm
local wezterm = require("wezterm")

print("=== WezTerm Powerline Icons ===\n")

-- Collect all powerline icons
local pl_icons = {}
local ple_icons = {}

for k, v in pairs(wezterm.nerdfonts) do
	if k:match("^pl_") then
		table.insert(pl_icons, { name = k, glyph = v })
	elseif k:match("^ple_") then
		table.insert(ple_icons, { name = k, glyph = v })
	end
end

-- Sort alphabetically
table.sort(pl_icons, function(a, b)
	return a.name < b.name
end)
table.sort(ple_icons, function(a, b)
	return a.name < b.name
end)

-- Print standard powerline icons
print("Standard Powerline (pl_):")
print(string.rep("-", 60))
for _, icon in ipairs(pl_icons) do
	print(string.format("%-40s %s", icon.name, icon.glyph))
end

print("\n")

-- Print powerline extra icons
print("Powerline Extra (ple_):")
print(string.rep("-", 60))
for _, icon in ipairs(ple_icons) do
	print(string.format("%-40s %s", icon.name, icon.glyph))
end

print("\n" .. string.rep("=", 60))
print(string.format("Total: %d standard + %d extra = %d icons", #pl_icons, #ple_icons, #pl_icons + #ple_icons))
