-- =============================================================================
-- TAB & BUFFER MANAGEMENT - CoreLine Integration
-- All buffer operations are scope-aware (per-tab buffer isolation)
-- =============================================================================

local M = {}
local wk = require("which-key")

function M.setup()
	-- CoreLine modules (lazy-loaded)
	local function nav()
		return require("local.coreline.scope.navigation")
	end
	local function scope()
		return require("local.coreline.scope")
	end
	local function state()
		return require("local.coreline.core.state")
	end
	local function fzf_coreline()
		return require("local.coreline.fzf")
	end

	-- ╔═══════════════════════════════════════════════════════════════════════╗
	-- ║ TAB MANAGEMENT: <leader><tab>*                                        ║
	-- ╚═══════════════════════════════════════════════════════════════════════╝
	wk.add({
		{ "<leader><tab>", group = "Tabs" },
		{ "<leader><tab>n", "<cmd>CorelineTabNew<cr>", desc = "New tab" },
		{ "<leader><tab>c", "<cmd>CorelineTabClose<cr>", desc = "Close tab" },
		{ "<leader><tab>C", "<cmd>tabonly<cr>", desc = "Close other tabs" },
		{ "<leader><tab>r", function()
			vim.ui.input({ prompt = "Tab name: " }, function(name)
				if name and name ~= "" then
					state().set_tab_name(vim.fn.tabpagenr(), name)
					vim.cmd("redrawtabline")
				end
			end)
		end, desc = "Rename tab" },
		{ "<leader><tab>m", function() fzf_coreline().tab_manager() end, desc = "Tab manager (fzf)" },
		{ "<leader><tab>Q", "<cmd>-tabmove<cr>", desc = "Move tab left" },
		{ "<leader><tab>E", "<cmd>+tabmove<cr>", desc = "Move tab right" },
		{ "<leader><tab>s", function()
			-- Copy current buffer to new tab
			local bufnr = vim.api.nvim_get_current_buf()
			vim.cmd("tabnew")
			scope().add_buffer(bufnr)
			vim.cmd("buffer " .. bufnr)
		end, desc = "Buffer to new tab (copy)" },
		mode = { "n" },
		noremap = true,
		silent = true,
	})

	-- ╔═══════════════════════════════════════════════════════════════════════╗
	-- ║ TAB NAVIGATION: <S-Tab>1-9 for direct tab access                      ║
	-- ╚═══════════════════════════════════════════════════════════════════════╝
	for i = 1, 9 do
		vim.keymap.set("n", "<S-Tab>" .. i, i .. "gt", { desc = "Go to tab " .. i, silent = true })
	end

	-- Tab next/prev with localleader
	vim.keymap.set("n", "<localleader><Tab>", "<cmd>tabnext<cr>", { desc = "Next tab", silent = true })
	vim.keymap.set("n", "<localleader><S-Tab>", "<cmd>tabprev<cr>", { desc = "Previous tab", silent = true })

	-- ╔═══════════════════════════════════════════════════════════════════════╗
	-- ║ BUFFER MANAGEMENT: <leader>b* (all scope-aware)                       ║
	-- ╚═══════════════════════════════════════════════════════════════════════╝
	wk.add({
		{ "<leader>b", group = "Buffers (scoped)" },
		-- Navigation
		{ "<leader>bn", function() nav().next() end, desc = "Next buffer (in scope)" },
		{ "<leader>bp", function() nav().prev() end, desc = "Previous buffer (in scope)" },
		{ "<leader>bf", function() nav().first() end, desc = "First buffer (in scope)" },
		{ "<leader>bl", function() nav().last() end, desc = "Last buffer (in scope)" },
		-- Close operations
		{ "<leader>bd", function() nav().close() end, desc = "Close buffer" },
		{ "<leader>bD", "<cmd>bdelete!<cr>", desc = "Force close buffer" },
		{ "<leader>bw", "<cmd>bwipeout<cr>", desc = "Wipeout buffer" },
		{ "<leader>bo", function() nav().close_others() end, desc = "Close other buffers (in scope)" },
		{ "<leader>bh", function() nav().close_left() end, desc = "Close buffers to left" },
		{ "<leader>bL", function() nav().close_right() end, desc = "Close buffers to right" },
		-- Scope operations
		{ "<leader>bm", function() fzf_coreline().buffer_manager() end, desc = "Buffer manager (fzf)" },
		{ "<leader>bs", function() fzf_coreline().scoped_buffers() end, desc = "Pick buffer (in scope)" },
		{ "<leader>bS", function() scope().toggle_view() end, desc = "Toggle scope view (all/scoped)" },
		{ "<leader>ba", function()
			-- Add current buffer to scope if not already
			scope().add_buffer()
			vim.notify("Buffer added to scope", vim.log.levels.INFO)
		end, desc = "Add buffer to scope" },
		{ "<leader>br", function()
			-- Remove current buffer from scope (but don't delete)
			scope().remove_buffer()
			vim.notify("Buffer removed from scope", vim.log.levels.INFO)
		end, desc = "Remove buffer from scope" },
		-- Move/Copy between tabs
		{ "<leader>bt", function() fzf_coreline().move_buffer_to_tab() end, desc = "Move buffer to tab" },
		{ "<leader>by", function() fzf_coreline().copy_buffer_to_tab() end, desc = "Copy buffer to tab" },
		-- Go to buffer by index (1-9)
		{ "<leader>b1", function() nav().go(1) end, desc = "Buffer 1" },
		{ "<leader>b2", function() nav().go(2) end, desc = "Buffer 2" },
		{ "<leader>b3", function() nav().go(3) end, desc = "Buffer 3" },
		{ "<leader>b4", function() nav().go(4) end, desc = "Buffer 4" },
		{ "<leader>b5", function() nav().go(5) end, desc = "Buffer 5" },
		{ "<leader>b6", function() nav().go(6) end, desc = "Buffer 6" },
		{ "<leader>b7", function() nav().go(7) end, desc = "Buffer 7" },
		{ "<leader>b8", function() nav().go(8) end, desc = "Buffer 8" },
		{ "<leader>b9", function() nav().go(9) end, desc = "Buffer 9" },
	})

	-- ╔═══════════════════════════════════════════════════════════════════════╗
	-- ║ QUICK BUFFER NAVIGATION: Tab/S-Tab (scope-aware)                      ║
	-- ╚═══════════════════════════════════════════════════════════════════════╝
	vim.keymap.set("n", "<Tab>", function() nav().next() end, { desc = "Next buffer (in scope)", silent = true })
	vim.keymap.set("n", "<S-Tab>", function() nav().prev() end, { desc = "Previous buffer (in scope)", silent = true })

	-- Keep Ctrl+e/q as quick buffer nav too
	vim.keymap.set("n", "<C-e>", function() nav().next() end, { desc = "Next buffer (in scope)", silent = true })
	vim.keymap.set("n", "<C-q>", function() nav().prev() end, { desc = "Previous buffer (in scope)", silent = true })
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
