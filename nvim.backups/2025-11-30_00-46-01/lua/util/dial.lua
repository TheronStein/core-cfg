return {
	{
		"monaqa/dial.nvim",
		config = function()
			-- require("dial").setup()

			vim.keymap.set("n", "<localleader>ia", function()
				require("dial.map").manipulate("increment", "normal")
			end)
			vim.keymap.set("n", "<localleader>ix", function()
				require("dial.map").manipulate("decrement", "normal")
			end)
			vim.keymap.set("n", "<localleader>is", function()
				require("dial.map").manipulate("increment", "gnormal")
			end)
			vim.keymap.set("n", "<localleader>ic", function()
				require("dial.map").manipulate("decrement", "gnormal")
			end)

			vim.keymap.set("v", "<localleader>ia", function()
				require("dial.map").manipulate("increment", "visual")
			end)
			vim.keymap.set("v", "<localleader>ix", function()
				require("dial.map").manipulate("decrement", "visual")
			end)
			vim.keymap.set("v", "<localleader>is", function()
				require("dial.map").manipulate("increment", "gvisual")
			end)
			vim.keymap.set("v", "<localleader>ic", function()
				require("dial.map").manipulate("decrement", "gvisual")
			end)

			-- Use + and - for increment/decrement
			vim.keymap.set({ "n", "v", "x" }, "<localleader>+", function()
				require("dial.map").manipulate("increment", "normal")
			end)
			vim.keymap.set({ "n", "v", "x" }, "<localleader>-", function()
				require("dial.map").manipulate("decrement", "normal")
			end)
		end,
	},
}
