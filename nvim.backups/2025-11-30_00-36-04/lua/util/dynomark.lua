return {
	"k-lar/dynomark.nvim",
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = { -- Default values
		remap_arrows = false,
		results_view_location = "vertical", -- Can be "float", "tab", "vertical" or "horizontal"

		-- This is only used when results_view_location is "float"
		-- By default the window is placed in the upper right of the window
		-- If you want to have the window centered, set both offsets to 0.0
		float_horizontal_offset = 0.2,
		float_vertical_offset = 0.2,

		-- Turn this to true if you want the plugin to automatically download
		-- the dynomark engine if it's not found in your PATH.
		-- This is false by default!
		auto_download = false,
	},
}
