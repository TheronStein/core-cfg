local wezterm = require("wezterm")
local util = require("tabline.util")
local tmux_tab_util = require("tabline.util.tmux_workspace")

-- Try to load tmux workspaces module for metadata
local tmux_workspaces = nil
pcall(function()
	tmux_workspaces = require("modules.tmux.workspaces")
end)

local M = {}

local default_opts = {
	options = {
		theme = "Catppuccin Mocha",
		tabs_enabled = true,
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },  -- NEW: Workspace moved here (between mode and tmux_server)
		tabline_c = { "tmux_server" },  -- MOVED: tmux_server moved to tabline_c
		tab_active = {
			{ "smart_title", padding = { left = 1, right = 1 } },
		},
		tab_inactive = {
			{ "smart_title", padding = { left = 1, right = 1 } },
		},
		tabline_x = { "ram", "cpu" },
		tabline_y = { "datetime", "battery" },
		tabline_z = { "domain" },
	},
	extensions = {},
}

local default_component_opts = {
	icons_enabled = true,
	icons_only = false,
	padding = 1,
}

local function in_tmux()
	local env = wezterm.get_env()
	return env.TMUX ~= nil
end

local function get_colors(theme)
	local colors = type(theme) == "string" and wezterm.color.get_builtin_schemes()[theme] or theme
	local surface = colors.cursor and colors.cursor.bg or colors.ansi[1]
	local background = colors.tab_bar and colors.tab_bar.inactive_tab and colors.tab_bar.inactive_tab.bg_color
		or colors.background

	if type(theme) == "string" then
		if string.find(theme, "Catppuccin") then
			surface = colors.tab_bar.inactive_tab_edge
		end
	end

	-- Import the unified mode color map to ensure consistency
	-- MODE_COLOR_MAP now contains direct hex color values
	local mode_color_map = require("modules.utils.mode_colors").MODE_COLOR_MAP

	-- Build mode themes using the SAME colors as border colors
	-- This ensures tabline and borders always use matching colors
	local mode_themes = {}
	for mode_name, hex_color in pairs(mode_color_map) do
		mode_themes[mode_name] = {
			a = { fg = background, bg = hex_color },
			b = { fg = hex_color, bg = surface },
			c = { fg = colors.foreground, bg = background },
		}
	end

	-- Add special "normal_mode" alias for compatibility
	mode_themes.normal_mode = mode_themes.wezterm_mode

	-- Add tab colors
	mode_themes.tab = {
		active = { fg = colors.ansi[5], bg = surface },
		inactive = { fg = colors.foreground, bg = background },
		inactive_hover = { fg = colors.ansi[6], bg = surface },
	}

	-- Add raw color scheme reference
	mode_themes.colors = colors

	return mode_themes
end

local function set_component_opts(user_opts)
	local component_opts = {}

	for key, default_value in pairs(default_component_opts) do
		component_opts[key] = default_value
		if user_opts.options[key] ~= nil then
			component_opts[key] = user_opts.options[key]
			user_opts.options[key] = nil
		end
	end

	return component_opts
end

function M.set(user_opts)
	user_opts = user_opts or { options = {} }
	user_opts.options = user_opts.options or {}
	local theme_overrides = user_opts.options.theme_overrides or {}
	user_opts.options.theme_overrides = nil

	M.component_opts = set_component_opts(user_opts)
	M.opts = util.deep_extend(default_opts, user_opts)
	M.sections = util.deep_copy(M.opts.sections)
	M.theme = util.deep_extend(get_colors(M.opts.options.theme), theme_overrides)
end

function M.set_theme(theme, overrides)
	if theme == nil and overrides == nil then
		local current_theme = M.opts and M.opts.options.theme or default_opts.options.theme
		M.theme = util.deep_extend(get_colors(current_theme), {})
	elseif type(theme) == "table" then
		M.theme = util.deep_extend(M.theme or {}, theme)
	else
		M.theme = util.deep_extend(get_colors(theme), overrides or {})
	end
end

return M
