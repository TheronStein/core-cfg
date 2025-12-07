-- -- =============================================================================
-- -- TAB & BUFFER MANAGEMENT (replacing Tabby keybinds)
-- -- =============================================================================

local M = {}
local wk = require("which-key")

function M.setup()
	wk.add({
		{ "<leader><tab>", group = "Tabs" },
		{ "<leader><tab><tab>", "<cmd>tabnew %<cr>", desc = "Open buffer in new tab" },
		{ "<leader><tab>q", "<cmd>tabprevious<cr>", desc = "Previous tab" },
		{ "<leader><tab>e", "<cmd>tabnext<cr>", desc = "Next tab" },
		{ "<leader><tab>Q", "<cmd>-tabmove<cr>", desc = "Move tab left" },
		{ "<leader><tab>E", "<cmd>+tabmove<cr>", desc = "Move tab right" },
		{ "<leader><tab>n", "<cmd>tabnew<cr>", desc = "New tab" },
		{ "<leader><tab>c", "<cmd>tabclose<cr>", desc = "Close tab" },
		{ "<leader><tab>C", "<cmd>tabonly<cr>", desc = "Close other tabs" },
		{ "<leader><tab>s", "<cmd>tab split<cr>", desc = "Buffer to new tab" },
		-- 	{ "<M-1>", "1gt", desc = "Tab 1" },
		-- 	{ "<M-2>", "2gt", desc = "Tab 2" },
		-- 	{ "<M-3>", "3gt", desc = "Tab 3" },
		-- 	{ "<M-4>", "4gt", desc = "Tab 4" },
		-- 	{ "<M-5>", "5gt", desc = "Tab 5" },
		-- 	{ "<M-6>", "6gt", desc = "Tab 6" },
		-- 	{ "<M-7>", "7gt", desc = "Tab 7" },
		-- 	{ "<M-8>", "8gt", desc = "Tab 8" },
		-- 	{ "<M-9>", "9gt", desc = "Tab 9" },
		-- 	-- { "<C->", "<cmd>tablast<cr>", desc = "Last tab" },
		mode = { "n", "v", "x" },
		noremap = true,
		silent = true,
	})

	wk.add({
		{ "<leader>b", group = "buffers" },
		{ "<leader>bw", "<cmd>bwipeout<cr>", desc = "Wipeout buffer" },
		{ "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
		{ "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous buffer" },
		{ "<leader>bf", "<cmd>bfirst<cr>", desc = "First buffer" },
		{ "<leader>bl", "<cmd>blast<cr>", desc = "Last buffer" },
		{ "<leader>d", "<cmd>bdelete<cr>", desc = "Delete buffer" },
		{ "<leader>D", "<cmd>bdelete!<cr>", desc = "Delete buffer (force)" },
		{ "<leader>X", "<cmd>%bd|e#|bd#<cr>", desc = "Close other buffers" },
		{ "<leader>bl", "<cmd>buffers<cr>", desc = "List buffers" },
	})

	wk.add({
		{ "<C-e>", "<cmd>bnext<cr>", desc = "Next buffer" },
		{ "<C-q>", "<cmd>bprevious<cr>", desc = "Previous buffer" },
		mode = { "n", "v", "x" },
		noremap = true,
		silent = true,
	})
end
-- Buffer operations: <leader>b

-- -- Tab operations: <leader>t
-- wk.add({
-- 	{ "<leader>t", group = "tabs" },
-- 	{ "<leader>tn", "<cmd>tabnew<cr>", desc = "New tab" },
-- 	{ "<leader>tc", "<cmd>tabclose<cr>", desc = "Close tab" },
-- 	{ "<leader>to", "<cmd>tabonly<cr>", desc = "Close other tabs" },
-- 	{ "<leader>th", "<cmd>tabprevious<cr>", desc = "Previous tab" },
-- 	{ "<leader>tl", "<cmd>tabnext<cr>", desc = "Next tab" },
-- 	{ "<leader>t[", "<cmd>tabfirst<cr>", desc = "First tab" },
-- 	{ "<leader>t]", "<cmd>tablast<cr>", desc = "Last tab" },
-- 	{ "<leader>tH", "<cmd>-tabmove<cr>", desc = "Move tab left" },
--
-- 	{ "<leader>tL", "<cmd>+tabmove<cr>", desc = "Move tab right" },
-- 	{ "<leader>t1", "1gt", desc = "Tab 1" },
-- 	{ "<leader>t2", "2gt", desc = "Tab 2" },
-- 	{ "<leader>t3", "3gt", desc = "Tab 3" },
-- 	{ "<leader>t4", "4gt", desc = "Tab 4" },
-- 	{ "<leader>t5", "5gt", desc = "Tab 5" },
-- 	{ "<leader>t6", "6gt", desc = "Tab 6" },
-- 	{ "<leader>t7", "7gt", desc = "Tab 7" },
-- 	{ "<leader>t8", "8gt", desc = "Tab 8" },
-- 	{ "<leader>t9", "9gt", desc = "Tab 9" },
-- 	{ "<leader>t0", "<cmd>tablast<cr>", desc = "Last tab" },
-- })
--

return M
