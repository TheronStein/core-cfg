local map = vim.keymap.set
local wk = require("which-key")

local M = {}

function M.setup()
	-- -- N-based next/previous navigation
	-- map("n", "n", "n", { noremap = true, silent = true })
	-- map("n", "N", "N", { noremap = true, silent = true })

	wk.add({
		{ "<M-D>", "<C-u>", desc = "Delete left" },
		{ "<Tab>", "<C-t>", desc = "Indent in insert mode" },
		{ "<S-Tab>", "<C-d>", desc = "Unindent in insert mode" },
		mode = { "i" },
		noremap = true,
		silent = true,
	})
	-- noremap = true, silent = true
	wk.add({
		{ "A", "a", desc = "Append at cursor" },
		{ "<", "a", desc = "Insert at block start" },
		-- { "A", "a", desc = "Insert at block start" },
		-- { "A", "a", desc = "Append at block end" },
		-- Basic save: :w (write current buffer)
		{ "<C-s>", ":w<CR>", desc = "Save current file" },
		mode = { "n" },
		noremap = true,
		silent = true,
	})

	-- map({ "n", "v" }, { noremap = true, silent = true })
	map({ "n", "v" }, "<M-S-L>", "$", { noremap = true, silent = true })
	wk.add({
		{ "U", "<C-r>", desc = "Redo Action" },
		{ "<C-u>", "u", desc = "Undo Action" },
		{ "<M-S-K>", "O", desc = "Open line above" },
		{ "<M-k>", "o", desc = "Open line below" },
		{ "<M-S-J>", "0", desc = "Beginning of line" },
		{ "<M-S-L>", "$", desc = "End of line" },
		mode = { "n", "v" },
		noremap = true,
		silent = true,
	})

	-- Navigation
	wk.add({
		{ "<C-i>", "5kzz", desc = "Jump up 5 lines" },
		{ "<C-k>", "5jzz", desc = "Jump down 5 lines" },
		{ "<C-i>", "5kzz", desc = "Jump up 5 lines" },
		{ "<C-k>", "5jzz", desc = "Jump down 5 lines" },
		{ "i", "k", desc = "cursor up" },
		{ "k", "j", desc = "cursor down" },
		{ "j", "h", desc = "cursor left" },
		{ "l", "l", desc = "cursor right" },
		{ "I", "<C-u>zz", desc = "Page up " },
		{ "K", "<C-d>zz", desc = "Page down" },
		{ "<S-CR>", "o", desc = "Open new line below" },
		{ "<CR>", "O", desc = "Open new line above" },
		{ "J", "B", desc = "← previous word" },
		{ "L", "W", desc = "→ next word" },
		mode = { "n", "v" },
		noremap = true,
		silent = true,
	})

	wk.add({
		{ "<C-i>", "<PageUp>", desc = "↑ up" },
		{ "<C-k>", "<PageDown>", desc = "↓ down" },
		{ "<C-j>", "<C-Left>", desc = "← left" },
		{ "<C-l>", "<C-Right>", desc = "→ right" },
		-- { "<M-D>", "<C-u>", desc = "Delete left", mode = { "i" } },
		mode = "i",
		noremap = true,
		silent = true,
	})

	-- map({ "n", "v" }, "i", "k", { noremap = true, silent = true })
	-- map({ "n", "v" }, "k", "j", { noremap = true, silent = true })

	map({ "n", "v" }, "<C-j>", "b", { noremap = true, silent = true })
	map({ "n", "v" }, "<C-l>", "w", { noremap = true, silent = true })

	-- Word movement with Alt
	map({ "n", "v" }, "<A-j>", "<C-Left>", { noremap = true, silent = true })
	map({ "n", "v" }, "<A-l>", "<C-Right>", { noremap = true, silent = true })

	wk.add({
		{
			{ "q", "<Nop>" },
			{ "u", "<Nop>" },
			{ mode = { "n", "v" }, noremap = true, silent = true },
		},
	})
end

return M

-- Visual block mode remaps
-- vim.keymap.set("x", "", "c", { desc = "Change block" })

-- Quick visual block mode entry
-- vim.keymap.set("n", "<C-q>", "<C-v>", { desc = "Visual block mode" })
-- vim.keymap.set("n", "<leader>v", "<C-v>", { desc = "Visual block mode" })

-- Multi-line comment/uncomment (after visual selection)
-- vim.keymap.set("x", "<leader>cc", ":norm I# <CR>", { desc = "Comment lines" })
-- vim.keymap.set("x", "<leader>cu", ":norm ^x<CR>", { desc = "Uncomment lines" })

-- Alternative: more specific for your hyprlang files
-- vim.keymap.set("x", "<leader>/", ":s/^/# /<CR>:noh<CR>", { desc = "Comment block" })
-- vim.keymap.set("x", "<leader>?", ":s/^# //<CR>:noh<CR>", { desc = "Uncomment block" })
--
----
-- map({ "n", "v" }, "<localleader>ut", ":UndotreeToggle<CR>", { desc = "Toggle undo tree " })
-- map({ "n", "v" }, "<localleader>uu", "undo", { desc = "undo" })
-- map({ "n", "v" }, "<localleader>ur", "redo", { desc = "redo" })
--
-- map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
-- map("i", "<C-c>", "<Esc>")
--
-- map({ "n", "v" }, "<leader>d", '"_d')
--
-- map("v", "W", ":m '>+1<CR>gv=gv")
-- map("v", "S", ":m '<-2<CR>gv=gv")
--
-- vim.keymap.set("v", "<leader>pb", function()
--   -- Get visual block selection marks
--   local start_pos = vim.api.nvim_buf_get_mark(0, "<")
--   local end_pos = vim.api.nvim_buf_get_mark(0, ">")
--   local start_line, start_col = unpack(start_pos)
--   local end_line, end_col = unpack(end_pos)
--
--   -- Ensure start_line <= end_line and start_col <= end_col
--   if start_line > end_line then
--     start_line, end_line = end_line, start_line
--   end
--   if start_col > end_col then
--     start_col, end_col = end_col, start_col
--   end
--
--   -- Get clipboard content (single line or first line if multi-line)
--   local clipboard_content = vim.fn.getreg("+"):match("[^\n]*") -- Get first line of clipboard
--
--   -- Iterate over each line in the block
--   for line = start_line, end_line do
--     -- Get the current line content
--     local current_line = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
--
--     -- Calculate padding if the line is too short
--     local padding = string.rep(" ", math.max(0, start_col - #current_line))
--
--     -- Construct new line: content before start_col + clipboard + content after end_col
--     local new_line = string.sub(current_line, 1, start_col)
--       .. padding
--       .. clipboard_content
--       .. string.sub(current_line, end_col + 1)
--
--     -- Set the modified line
--     vim.api.nvim_buf_set_lines(0, line - 1, line, false, { new_line })
--   end
--
--   -- Restore cursor to start of block
--   vim.api.nvim_win_set_cursor(0, { start_line, start_col })
-- end, {
--   desc = "Paste clipboard on each line in visual block mode",
-- })
--
-- vim.keymap.set("n", "<localleader>Fa", "ma=ap'a", { desc = "Format around cursor" })
--
-- vim.keymap.set("n", "<localleader>Ft", function()
--   local line = vim.api.nvim_get_current_line()
--   local col = vim.api.nvim_win_get_cursor(0)[2]
--   local char = line:sub(col + 1, col + 1)
--
--   -- Set mark to return to
--   vim.cmd("normal! ma")
--
--   -- Detect surrounding context
--   local pairs = {
--     ["{"] = "a{",
--     ["}"] = "a{",
--     ["("] = "a(",
--     [")"] = "a(",
--     ["["] = "a[",
--     ["]"] = "a[",
--     ["<"] = "a<",
--     [">"] = "a<",
--     ['"'] = 'a"',
--     ["'"] = "a'",
--     ["`"] = "a`",
--   }
--
--   -- Check if cursor is on/near a bracket or quote
--   if pairs[char] then
--     vim.cmd("normal! =" .. pairs[char])
--   else
--     -- Try to detect if we're in a function/block
--     local ok = pcall(vim.cmd, "normal! =aB")
--     if not ok then
--       -- Fall back to paragraph
--       vim.cmd("normal! =ap")
--     end
--   end
--
--   -- Return to original position
--   vim.cmd("normal! 'a")
-- end, { desc = "Smart format text object" })
--
-- vim.keymap.set("n", "<localleader>Fs", function()
--   vim.cmd("normal! ma")
--
--   -- Try treesitter-aware formatting first (requires nvim-treesitter-textobjects)
--   local ok = pcall(vim.cmd, "normal! =aB") -- Try block first
--   if not ok then
--     vim.cmd("normal! =ap") -- Fall back to paragraph
--   end
--
--   vim.cmd("normal! 'a")
-- end, { desc = "Smart format" })
--
-- vim.keymap.set("n", "<localleader>Fb", "ma=aBgv=gv'a", { desc = "Format block/paragraph" })
--
