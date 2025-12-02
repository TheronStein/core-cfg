return {

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night", -- Use tokyonight-night variant
			transparent = false,
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "dark",
				floats = "dark",
			},
			sidebars = { "qf", "help", "terminal" },
			day_brightness = 0.3,
			hide_inactive_statusline = false,
			dim_inactive = false,
			lualine_bold = false,

			-- Override colors - change the puke green string color
			on_colors = function(colors)
				-- Change string color from puke green (#ccfce5) to something better
				-- You can customize this to any color you prefer
				colors.green = "#4fd6be" -- Using the teal/green1 from your palette
				-- Or try these alternatives:
				-- colors.green = "#86e1fc" -- cyan
				-- colors.green = "#82aaff" -- blue
				-- colors.green = "#c099ff" -- magenta
				-- colors.green = "#ffc777" -- yellow
			end,

			-- Override specific highlight groups if needed
			on_highlights = function(hl, c)
				-- Explicitly set string color
				hl.String = { fg = c.green }
				-- You can also customize other highlights here
				-- hl.Function = { fg = c.blue }
				-- hl.Keyword = { fg = c.purple, italic = true }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},

	-- {
	-- 	"shaunsingh/moonlight.nvim",
	-- 	lazy = false,
	-- 	priority = 1000
	-- 	config = function()
	-- 		vim.cmd([[colorscheme moonlight]])
	-- 	end,
	-- },
}
