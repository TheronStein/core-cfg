-- -- =============================================================================
-- -- TAB & BUFFER MANAGEMENT (replacing Tabby keybinds)
-- -- =============================================================================

local M = {}
local wk = require("which-key")

function M.setup()
	wk.add({
		{ "<tab>", group = "Tabs/Buffers" },
		{ "<tab>b", group = "Tabs/Buff" },
		{ "<tab>wo", "<cmd>bwipeout<cr>", desc = "Wipeout buffer" },
		{ "<tab>e", "<cmd>bnext<cr>", desc = "Next buffer" },
		{ "<tab>q", "<cmd>bprevious<cr>", desc = "Previous buffer" },
		{ "<tab>!", "<cmd>bfirst<cr>", desc = "First buffer" },
		{ "<tab>@", "<cmd>blast<cr>", desc = "Last buffer" },
		{ "<tab>d", "<cmd>bdelete<cr>", desc = "Delete buffer" },
		{ "<tab>D", "<cmd>bdelete!<cr>", desc = "Delete buffer (force)" },
		{ "<tab>X", "<cmd>%bd|e#|bd#<cr>", desc = "Close other buffers" },
		{ "<tab>t", "<cmd>tab split<cr>", desc = "Buffer to new tab" },
		{ "<tab>o", "<cmd>tabnew %<cr>", desc = "Open buffer in new tab" },
		{ "<tab>b", "<cmd>buffers<cr>", desc = "List buffers" },
		{ "<tab>u", "<cmd>tabprevious<cr>", desc = "Previous tab" },
		{ "<tab>o", "<cmd>tabnext<cr>", desc = "Next tab" },
		{ "<tab>U", "<cmd>-tabmove<cr>", desc = "Move tab left" },
		{ "<tab>O", "<cmd>+tabmove<cr>", desc = "Move tab right" },
		{ "<tab>n", "<cmd>tabnew<cr>", desc = "New tab" },
		{ "<tab>c", "<cmd>tabclose<cr>", desc = "Close tab" },
		{ "<tab>C", "<cmd>tabonly<cr>", desc = "Close other tabs" },
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
