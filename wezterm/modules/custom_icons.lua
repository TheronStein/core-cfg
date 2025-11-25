-- File: ~/.core/.sys/configs/wezterm/modules/custom_icons.lua
-- Custom icon mappings for icons not available in wezterm.nerdfonts
--
-- PURPOSE:
--   Provides fallback icons for applications and processes that don't have
--   dedicated nerd font icons, or for custom glyphs we want to use.
--
-- USAGE:
--   local custom_icons = require("modules.custom_icons")
--   local yazi_icon = custom_icons.yazi
--
-- NOTE:
--   These are direct Unicode characters, not wezterm.nerdfonts references.
--   Add new custom icons here as needed.

local wezterm = require("wezterm")

-- Custom icon definitions
-- Format: name = "unicode_character" -- description
local custom_icons = {
	-- File managers and utilities
	yazi = "󰇥", -- 󰇥 Duck emoji (Yazi's logo)

	-- Legacy icon name mappings (for backward compatibility)
	-- These icons don't exist in wezterm.nerdfonts, so we map to suitable alternatives
	md_flattr = wezterm.nerdfonts.md_cloud_download, -- Used for curl - download icon
	md_graphics_card = wezterm.nerdfonts.md_expansion_card, -- Used for GPU - expansion card icon

	-- Add more custom icons below as needed
	-- example = "\uXXXX", -- Description
}

-- Helper function to get an icon safely
local function get_icon(icon_name)
	local icon = custom_icons[icon_name]
	if icon then
		return icon
	else
		wezterm.log_warn("Custom icon not found: " .. icon_name)
		return wezterm.nerdfonts.md_application -- Fallback to generic app icon
	end
end

-- Note: wezterm.nerdfonts is read-only, so we can't inject custom icons into it
-- Instead, we expose them through this module's API

-- Export the module
return {
	-- Direct access to icons
	yazi = custom_icons.yazi,
	md_flattr = custom_icons.md_flattr,
	md_graphics_card = custom_icons.md_graphics_card,

	-- Helper function
	get = get_icon,

	-- All icons table
	icons = custom_icons,
}
