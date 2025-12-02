-- fzf-lua command search
vim.keymap.set("n", "<leader>:", function()
	require("fzf-lua").commands()
end, { desc = "Search Commands" })

vim.keymap.set("n", "<leader>sc", function()
	require("fzf-lua").commands()
end, { desc = "Search Commands" })

-- Map Ctrl-P in command-line mode to open fzf-lua command search
vim.keymap.set("c", "<C-p>", function()
	vim.cmd("stopinsert")
	require("fzf-lua").commands()
end, { desc = "Search Commands (cmdline)" })
