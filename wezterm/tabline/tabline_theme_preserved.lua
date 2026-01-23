-- Preserved tabline theme configuration
-- Dynamically generates theme colors from the single source of truth: mode_colors.lua
-- All mode colors are now defined in ONE place: modules/utils/mode_colors.lua

local wezterm = require("wezterm")
local mode_colors = require("modules.utils.mode_colors")

local M = {}

-- Background colors (Catppuccin Mocha palette)
local SURFACE1 = "#444267"
local BASE = "#292D3E"
local DARK_TEXT = "#292D3E"
local LIGHT_TEXT = "#cdd6f4"

-- Helper function to determine if background is bright (needs dark text)
local function needs_dark_text(bg_color)
	if not bg_color or type(bg_color) ~= "string" or #bg_color < 7 then
		return false
	end
	local r = tonumber(bg_color:sub(2, 3), 16) or 0
	local g = tonumber(bg_color:sub(4, 5), 16) or 0
	local b = tonumber(bg_color:sub(6, 7), 16) or 0
	local brightness = (r * 0.299 + g * 0.587 + b * 0.114)
	return brightness > 128
end

-- Generate a full theme for a mode from its single color
local function generate_mode_theme(mode_color)
	local fg_on_color = needs_dark_text(mode_color) and "#000000" or DARK_TEXT
	return {
		a = { fg = fg_on_color, bg = mode_color },
		b = { fg = mode_color, bg = SURFACE1 },
		c = { fg = mode_color, bg = BASE },
		x = { fg = mode_color, bg = BASE },
		y = { fg = mode_color, bg = SURFACE1 },
		z = { fg = fg_on_color, bg = mode_color },
	}
end

-- Build preserved_theme dynamically from mode_colors
M.preserved_theme = {
	-- Tab colors (static)
	tab = {
		active = { fg = "#01F9C6", bg = SURFACE1 },
		inactive = { fg = LIGHT_TEXT, bg = SURFACE1 },
		inactive_hover = { fg = "#f1fc79", bg = SURFACE1 },
	},
}

-- Generate theme for each mode from the single source of truth
local all_colors = mode_colors.get_all_colors()
for mode_name, hex_color in pairs(all_colors) do
	M.preserved_theme[mode_name] = generate_mode_theme(hex_color)
end

-- Add aliases for compatibility
M.preserved_theme.normal_mode = M.preserved_theme.wezterm_mode
M.preserved_theme.core_mode = M.preserved_theme.tmux_mode

return M
