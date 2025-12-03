-- TODO: implement ui integrations with fzf-lua as a menu selector for different options and condense the keymaps
-- integrate hypr_rgba support throughout the plugin

return {
	"uga-rosa/ccc.nvim",
	lazy = false,
	event = "VeryLazy",

	config = function()
		local ccc = require("ccc")

		ccc.setup({
			-- Highlighter
			highlighter = {
				auto_enable = true,
				lsp = true,
			},

			-- Output formats
			outputs = {
				ccc.output.hex,
				ccc.output.hex_short,
				ccc.output.css_rgb,
				ccc.output.css_hsl,
				ccc.output.css_hwb,
				ccc.output.css_lab,
				ccc.output.css_lch,
				ccc.output.css_oklab,
				ccc.output.css_oklch,
			},

			-- Picker settings
			pickers = {
				ccc.picker.hex,
				ccc.picker.css_rgb,
				ccc.picker.css_hsl,
				ccc.picker.css_hwb,
				ccc.picker.css_lab,
				ccc.picker.css_lch,
				ccc.picker.css_oklab,
				ccc.picker.css_oklch,
			},

			-- Default colors
			alpha_show = "auto",
			recognize = {
				input = true,
				output = true,
			},

			-- Preserve input format when possible
			preserve = true,

			-- Keymappings inside picker
			mappings = {
				-- FIXED: Tab/Shift-Tab for switching between components (R/G/B, H/S/L)
				["<Tab>"] = ccc.mapping.next_component,
				["<S-Tab>"] = ccc.mapping.prev_component,
				-- ["<C-i>"] = ccc.mapping.next_component,

				-- Component navigation (WASD-based)
				["w"] = ccc.mapping.prev_component,  -- up = previous component
				["s"] = ccc.mapping.next_component,  -- down = next component

				-- Additional navigation (WASD-based)
				["a"] = ccc.mapping.decrease1,  -- left decreases
				["d"] = ccc.mapping.increase1,  -- right increases
				["A"] = ccc.mapping.decrease5,  -- shift+left = decrease by 5
				["D"] = ccc.mapping.increase5,  -- shift+right = increase by 5
				["<C-a>"] = ccc.mapping.decrease10, -- ctrl+left = decrease by 10
				["<C-d>"] = ccc.mapping.increase10, -- ctrl+right = increase by 10

				-- Quick values
				["0"] = ccc.mapping.set0,
				["1"] = ccc.mapping.set10,
				["2"] = ccc.mapping.set20,
				["3"] = ccc.mapping.set30,
				["4"] = ccc.mapping.set40,
				["5"] = ccc.mapping.set50,
				["6"] = ccc.mapping.set60,
				["7"] = ccc.mapping.set70,
				["8"] = ccc.mapping.set80,
				["9"] = ccc.mapping.set90,
				["W"] = ccc.mapping.set0, -- Min (top)
				["M"] = ccc.mapping.set50, -- Middle
				["S"] = ccc.mapping.set100, -- Max (bottom)

				-- Input mode cycling
				["]"] = ccc.mapping.cycle_input_mode,
				["["] = ccc.mapping.cycle_input_mode_reverse,

				-- Output mode cycling (hex → rgb → hsl → etc.)
				["{"] = ccc.mapping.cycle_output_mode,
				["}"] = ccc.mapping.cycle_output_mode_reverse,

				-- Alpha toggle
				["t"] = ccc.mapping.toggle_alpha,

				-- Palette navigation
				["p"] = ccc.mapping.goto_palette,
				["g"] = ccc.mapping.toggle_prev_colors,
				["n"] = ccc.mapping.next_color,
				["N"] = ccc.mapping.prev_color,
				["e"] = ccc.mapping.last_color,
				["u"] = ccc.mapping.prev_swatch,
				["o"] = ccc.mapping.next_swatch,

				-- Actions
				["<CR>"] = ccc.mapping.complete,
				["q"] = ccc.mapping.quit,
				["Q"] = ccc.mapping.quit,
				["<Esc>"] = ccc.mapping.quit,
			},
		})

		-- Load all CCC extension modules
		require("mods.ccc.autocmds").setup()
		require("mods.ccc.fzf-picker").setup()
		require("mods.ccc.keymaps").setup()
		require("mods.ccc.commands").setup()
		require("mods.ccc.which-key").setup()
	end,
}
