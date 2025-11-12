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
		inactive = { fg = "#19dfcf", bg = "#292D3E" },
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

	-- LEADER mode (red theme)
	leader_mode = {
		a = { fg = "#FFFFFF", bg = "#FF5370" },
		b = { fg = "#FF5370", bg = "#444267" },
		c = { fg = "#FF5370", bg = "#292D3E" },
		x = { fg = "#FF5370", bg = "#292D3E" },
		y = { fg = "#FF5370", bg = "#444267" },
		z = { fg = "#FFFFFF", bg = "#FF5370" },
	},

	-- WEZTERM mode (purple theme)
	wez_mode = {
		a = { fg = "#292D3E", bg = "#987afb" },
		b = { fg = "#987afb", bg = "#444267" },
		c = { fg = "#987afb", bg = "#292D3E" },
		x = { fg = "#987afb", bg = "#292D3E" },
		y = { fg = "#987afb", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#987afb" },
	},

	-- -- TMUX mode (orange theme)
	-- tmux_mode = {
	-- 	b = { fg = "#292D3E", bg = "#8BE9FD" },
	-- 	a = { fg = "#8BE9FD", bg = "#444267" },
	-- 	c = { fg = "#8BE9FD", bg = "#292D3E" },
	-- 	x = { fg = "#8BE9FD", bg = "#292D3E" },
	-- 	y = { fg = "#8BE9FD", bg = "#444267" },
	-- 	z = { fg = "#292D3E", bg = "#8BE9FD" },
	-- },

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

	-- RESIZE mode (pink theme)
	resize_mode = {
		a = { fg = "#292D3E", bg = "#FF79C6" },
		b = { fg = "#FF79C6", bg = "#444267" },
		c = { fg = "#FF79C6", bg = "#292D3E" },
		x = { fg = "#FF79C6", bg = "#292D3E" },
		y = { fg = "#FF79C6", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#FF79C6" },
	},

	-- Copy mode (amber theme)
	copy_mode = {
		a = { fg = "#292D3E", bg = "#FFB86C" },
		b = { fg = "#FFB86C", bg = "#444267" },
		c = { fg = "#FFB86C", bg = "#292D3E" },
		x = { fg = "#FFB86C", bg = "#292D3E" },
		y = { fg = "#FFB86C", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#FFB86C" },
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

	-- Pane mode (green theme)
	pane_mode = {
		a = { fg = "#292D3E", bg = "#69FF94" },
		b = { fg = "#69FF94", bg = "#444267" },
		c = { fg = "#69FF94", bg = "#292D3E" },
		x = { fg = "#69FF94", bg = "#292D3E" },
		y = { fg = "#69FF94", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#69FF94" },
	},

	-- Pane selection mode (lime theme)
	pane_selection_mode = {
		a = { fg = "#292D3E", bg = "#C3E88D" },
		b = { fg = "#C3E88D", bg = "#444267" },
		c = { fg = "#C3E88D", bg = "#292D3E" },
		x = { fg = "#C3E88D", bg = "#292D3E" },
		y = { fg = "#C3E88D", bg = "#444267" },
		z = { fg = "#292D3E", bg = "#C3E88D" },
	},
}

return M
