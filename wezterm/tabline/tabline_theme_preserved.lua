-- Preserved tabline theme configuration
-- This file hardcodes the tabline theme to prevent it from being affected by workspace theme changes
-- Generated: 2025-10-12

local M = {}

-- overlay2 = "#9399B2",
-- overlay1 = "#7F849C",
-- overlay0 = "#6C7086",
-- surface2 = "#585B70",
-- surface1 = "#444267",
-- surface0 = "#313244",
-- base     = "#292D3E",
-- mantle   = "#24283B",
-- crust    = "#1E2030",

-- Preserved theme colors for the tabline (independent of workspace themes)
M.preserved_theme = {
	tab = {
		active = { fg = "#01F9C6", bg = "#444267" },
		inactive = { fg = "#cdd6f4", bg = "#444267" },
		inactive_hover = { fg = "#f1fc79", bg = "#444267" },
	},

	-- CORE mode (cyan theme)
	core_mode = {
		a = { fg = "#292D3E", bg = "#01F9C6" },
		b = { fg = "#01F9C6", bg = "#444267" },
		c = { fg = "#01F9C6", bg = "#313244" },
		-- c = { fg = "#01F9C6", bg = "#292D3E" },
		x = { fg = "#01F9C6", bg = "#292D3E" },
		y = { fg = "#01F9C6", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#01F9C6" },
	},

	-- Also override normal_mode to use CORE colors
	normal_mode = {
		a = { fg = "#292D3E", bg = "#01F9C6" },
		b = { fg = "#01F9C6", bg = "#444267" },
		c = { fg = "#01F9C6", bg = "#292D3E" },
		x = { fg = "#01F9C6", bg = "#292D3E" },
		y = { fg = "#01F9C6", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#01F9C6" },
	},

	-- LEADER mode (coral red theme) - Updated to match mode_colors.lua (#FF6B6B)
	leader_mode = {
		a = { fg = "#FFFFFF", bg = "#FF6B6B" },
		b = { fg = "#FF6B6B", bg = "#444267" },
		c = { fg = "#FF6B6B", bg = "#292D3E" },
		x = { fg = "#FF6B6B", bg = "#292D3E" },
		y = { fg = "#FF6B6B", bg = "#444267" },
		z = { fg = "#FFFFFF", bg = "#FF6B6B" },
	},

	-- WEZTERM mode (purple theme)
	wezterm_mode = {
		a = { fg = "#292D3E", bg = "#8470FF" },
		b = { fg = "#8470FF", bg = "#444267" },
		c = { fg = "#8470FF", bg = "#292D3E" },
		x = { fg = "#8470FF", bg = "#292D3E" },
		y = { fg = "#8470FF", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#8470FF" },
	},

	-- TMUX mode (cyan theme) - Updated to match mode_colors.lua (#01F9C6)
	tmux_mode = {
		a = { fg = "#292D3E", bg = "#01F9C6" },
		b = { fg = "#01F9C6", bg = "#444267" },
		c = { fg = "#01F9C6", bg = "#292D3E" },
		x = { fg = "#01F9C6", bg = "#292D3E" },
		y = { fg = "#01F9C6", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#01F9C6" },
	},

	-- SUPER mode (yellow theme)
	super_mode = {
		a = { fg = "#292D3E", bg = "#FFCB6B" },
		b = { fg = "#FFCB6B", bg = "#444267" },
		c = { fg = "#FFCB6B", bg = "#292D3E" },
		x = { fg = "#FFCB6B", bg = "#292D3E" },
		y = { fg = "#FFCB6B", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#FFCB6B" },
	},

	-- -- SUPER mode (yellow theme)
	-- hyper_mode = {
	-- 	b = { fg = "#292D3E", bg = "#FFCBFF" },
	-- 	a = { fg = "#FFCBFF", bg = "#444267" },
	-- 	c = { fg = "#FFCBFF", bg = "#292D3E" },
	-- 	x = { fg = "#FFCB6B", bg = "#292D3E" },
	-- 	y = { fg = "#FFCBFF", bg = "#444267" },
	-- 	z = { fg = "#292D3E", bg = "#FFCBFF" },
	-- },

	-- CTRL mode (yellow theme)
	ctrl_mode = {
		a = { fg = "#292D3E", bg = "#F78C6C" },
		b = { fg = "#F78C6C", bg = "#444267" },
		c = { fg = "#F78C6C", bg = "#292D3E" },
		x = { fg = "#F78C6C", bg = "#292D3E" },
		y = { fg = "#F78C6C", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#F78C6C" },
	},

	-- alt mode (yellow theme)
	alt_mode = {
		a = { fg = "#292D3E", bg = "#f1fc79" },
		b = { fg = "#f1fc79", bg = "#444267" },
		c = { fg = "#f1fc79", bg = "#292D3E" },
		x = { fg = "#f1fc79", bg = "#292D3E" },
		y = { fg = "#f1fc79", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#f1fc79" },
	},

	-- -- ZSH mode (green theme)
	-- zsh_mode = {
	-- 	-- b = { fg = "#292D3E", bg = "#69FF94" },
	-- 	-- a = { fg = "#69FF94", bg = "#444267" },
	-- 	-- c = { fg = "#69FF94", bg = "#292D3E" },
	-- 	-- x = { fg = "#69FF94", bg = "#292D3E" },
	-- 	-- y = { fg = "#69FF94", bg = "#444267" },
	-- 	-- z = { fg = "#292D3E", bg = "#69FF94" },
	-- },

	-- -- GIT mode (lime theme)
	-- git_mode = {
	--
	-- b = { fg = "#292D3E", bg = "#69FF94" },
	-- a = { fg = "#69FF94", bg = "#444267" },
	-- c = { fg = "#69FF94", bg = "#292D3E" },
	-- x = { fg = "#69FF94", bg = "#292D3E" },
	-- y = { fg = "#69FF94", bg = "#444267" },
	-- z = { fg = "#292D3E", bg = "#69FF94" },
	-- },

	-- -- NEOVIM mode (mint theme)
	-- neovim_mode = {
	-- 	b = { fg = "#292D3E", bg = "#69FF00" },
	-- 	a = { fg = "#69FF00", bg = "#444267" },
	-- 	c = { fg = "#69FF00", bg = "#292D3E" },
	-- 	x = { fg = "#69FF00", bg = "#292D3E" },
	-- 	y = { fg = "#69FF00", bg = "#444267" },
	-- 	z = { fg = "#292D3E", bg = "#69FF00" },
	-- },

	-- RESIZE mode (orange/peach theme) - Updated to match mode_colors.lua (#F78C6C)
	resize_mode = {
		a = { fg = "#292D3E", bg = "#F78C6C" },
		b = { fg = "#F78C6C", bg = "#444267" },
		c = { fg = "#F78C6C", bg = "#292D3E" },
		x = { fg = "#F78C6C", bg = "#292D3E" },
		y = { fg = "#F78C6C", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#F78C6C" },
	},

	-- Copy mode (orange/peach theme) - Updated to match mode_colors.lua (#F78C6C, same as resize)
	copy_mode = {
		a = { fg = "#292D3E", bg = "#F78C6C" },
		b = { fg = "#F78C6C", bg = "#444267" },
		c = { fg = "#F78C6C", bg = "#292D3E" },
		x = { fg = "#F78C6C", bg = "#292D3E" },
		y = { fg = "#F78C6C", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#F78C6C" },
	},

	-- Search mode (teal theme)
	launcher_mode = {
		a = { fg = "#292D3E", bg = "#FFCBFF" },
		b = { fg = "#FFCBFF", bg = "#444267" },
		c = { fg = "#FFCBFF", bg = "#292D3E" },
		x = { fg = "#FFCBFF", bg = "#292D3E" },
		y = { fg = "#FFCBFF", bg = "#444267" },
		z = { fg = "#FFCBFF", bg = "#FFCBFF" },
	},
	-- Search mode (teal theme)
	search_mode = {
		a = { fg = "#292D3E", bg = "#8BE9FD" },
		b = { fg = "#8BE9FD", bg = "#444267" },
		c = { fg = "#8BE9FD", bg = "#292D3E" },
		x = { fg = "#8BE9FD", bg = "#292D3E" },
		y = { fg = "#8BE9FD", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#8BE9FD" },
	},

	-- Pane mode (yellow/lime theme) - Updated to match mode_colors.lua (#f1fc79)
	pane_mode = {
		a = { fg = "#292D3E", bg = "#f1fc79" },
		b = { fg = "#f1fc79", bg = "#444267" },
		c = { fg = "#f1fc79", bg = "#292D3E" },
		x = { fg = "#f1fc79", bg = "#292D3E" },
		y = { fg = "#f1fc79", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#f1fc79" },
	},

	-- Pane selection mode (purple theme) - Updated to match mode_colors.lua (#8470FF, same as wezterm)
	pane_selection_mode = {
		a = { fg = "#292D3E", bg = "#8470FF" },
		b = { fg = "#8470FF", bg = "#444267" },
		c = { fg = "#8470FF", bg = "#292D3E" },
		x = { fg = "#8470FF", bg = "#292D3E" },
		y = { fg = "#8470FF", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#8470FF" },
	},
}

return M
