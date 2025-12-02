-- Telescope command search
vim.keymap.set("n", "<leader>:", function()
	require("telescope.builtin").commands()
end, { desc = "Search Commands" })

vim.keymap.set("n", "<leader>sc", function()
	require("telescope.builtin").commands()
end, { desc = "Search Commands" })

-- Map Ctrl-P in command-line mode to open telescope command search
vim.keymap.set("c", "<C-p>", function()
	vim.cmd("stopinsert")
	require("telescope.builtin").commands()
end, { desc = "Search Commands (cmdline)" })
