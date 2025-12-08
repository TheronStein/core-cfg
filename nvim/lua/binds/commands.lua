local M = {}
local wk = require("which-key")

function M.setup()
	-- fzf-lua command search
	vim.keymap.set("n", "<localleader>sc", function()
		require("fzf-lua").commands()
	end, { desc = "Search Commands" })

	wk.add({
		{ "<localleader>s", group = "Search" },
		{ "<localleader>sh", desc = "Command History" },
		{ "<localleader>sc", desc = "System Config Browser" },
		mode = "n",
		noremap = true,
		silent = true,
	})
	-- { "<leader>f", group = "find" },
	-- { "<localleader>f", group = "file browser" },
	-- You can also add specific mappings here
	-- { "<leader>ff", desc = "Find Files" },
	-- { "<leader>fg", desc = "Live Grep" },
	-- { "<leader>fb", desc = "Buffers" },
	-- { "<leader>fh", desc = "Help Tags" },
	-- { "<leader>fr", desc = "Recent Files" },
	-- { "<leader>fc", desc = "Grep String" },
	-- { "<leader>fd", desc = "Diagnostics" },
	--
	-- { "<localleader>fb", desc = "Browse Files" },
	-- { "<localleader>fe", desc = "File Explorer" },
	--
	-- -- LSP mappings (these will show when in a buffer with LSP attached)
	-- { "<leader>la", desc = "Code Action", mode = { "n", "v" } },
	-- { "<leader>ld", desc = "Type Definition" },
	-- { "<leader>lf", desc = "Format" },
	-- { "<leader>lr", desc = "Rename" },
	-- { "<leader>lR", desc = "References" },
	--
	-- -- Git mappings (if you add git plugins later)

	-- fzf-lua command search
	-- vim.keymap.set("n", "<leader>:", function()
	--   require("fzf-lua").commands()
	-- end, { desc = "Search Commands" })
end

return M
