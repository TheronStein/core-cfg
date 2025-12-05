-- Organized Keymap Structure
-- This is a template showing how to organize your keymaps with proper scoping

local M = {}
local scopes = require("binds.keymap-scopes")

-- =============================================================================
-- GLOBAL KEYMAPS (Apply everywhere)
-- =============================================================================
M.setup_global = function()
	local map = vim.keymap.set

	-- Core functionality that should ALWAYS work
	map("n", "<C-s>", ":w<CR>", { desc = "Save file", silent = true })
	map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file (insert mode)", silent = true })

	-- Window management (should work everywhere)
	map("n", "<C-w>v", ":vsplit<CR>", { desc = "Split vertical", silent = true })
	map("n", "<C-w>s", ":split<CR>", { desc = "Split horizontal", silent = true })
	map("n", "<C-w>q", ":q<CR>", { desc = "Close window", silent = true })

	-- Tab management
	map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab", silent = true })
	map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab", silent = true })
	map("n", "<leader>t]", ":tabnext<CR>", { desc = "Next tab", silent = true })
	map("n", "<leader>t[", ":tabprev<CR>", { desc = "Previous tab", silent = true })
end

-- =============================================================================
-- NAVIGATION KEYMAPS (Only apply to normal edit buffers)
-- =============================================================================
M.setup_navigation = function()
	-- Only apply to buffers where custom navigation makes sense
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		callback = function(ev)
			local bufnr = ev.buf

			-- Skip if this buffer type shouldn't have custom navigation
			if not scopes.should_apply_custom_maps(bufnr) then
				return
			end

			-- Skip if manually disabled
			if vim.b[bufnr].custom_navigation_disabled then
				return
			end

			local map = vim.keymap.set
			local opts = { buffer = bufnr, noremap = true, silent = true }

			-- Custom navigation: i/j/k/l → k/h/j/l (up/left/down/right)
			map({ "n", "v" }, "i", "k", vim.tbl_extend("force", opts, { desc = "Cursor up" }))
			map({ "n", "v" }, "k", "j", vim.tbl_extend("force", opts, { desc = "Cursor down" }))
			map({ "n", "v" }, "j", "h", vim.tbl_extend("force", opts, { desc = "Cursor left" }))
			map({ "n", "v" }, "l", "l", vim.tbl_extend("force", opts, { desc = "Cursor right" }))

			-- Big jumps
			map({ "n", "v" }, "I", "<C-u>zz", vim.tbl_extend("force", opts, { desc = "Page up" }))
			map({ "n", "v" }, "K", "<C-d>zz", vim.tbl_extend("force", opts, { desc = "Page down" }))

			-- Word movement
			map({ "n", "v" }, "<C-j>", "b", vim.tbl_extend("force", opts, { desc = "Word backward" }))
			map({ "n", "v" }, "<C-l>", "w", vim.tbl_extend("force", opts, { desc = "Word forward" }))

			-- Line start/end
			map(
				{ "n", "v" },
				"<C-S-J>",
				"0",
				vim.tbl_extend("force", opts, { desc = "Line start" })
			)
			map({ "n", "v" }, "<C-S-L>", "$", vim.tbl_extend("force", opts, { desc = "Line end" }))

			-- Remap displaced keys
			map({ "n", "v" }, "A", "i", vim.tbl_extend("force", opts, { desc = "Insert mode" }))
			map({ "n", "v" }, "u", "<C-u>", vim.tbl_extend("force", opts, { desc = "Page up" }))
			map("n", "<C-u>", "u", vim.tbl_extend("force", opts, { desc = "Undo" }))
		end,
	})
end

-- =============================================================================
-- EDITOR KEYMAPS (Text editing, not navigation)
-- =============================================================================
M.setup_editing = function()
	local map = vim.keymap.set

	-- Search improvements (center results)
	map("n", "n", "nzzzv", { desc = "Next search (centered)" })
	map("n", "N", "Nzzzv", { desc = "Previous search (centered)" })

	-- Indentation in insert mode
	map("i", "<Tab>", "<C-t>", { desc = "Indent", silent = true })
	map("i", "<S-Tab>", "<C-d>", { desc = "Unindent", silent = true })

	-- Visual mode improvements
	map("v", "<", "<gv", { desc = "Indent left (keep selection)" })
	map("v", ">", ">gv", { desc = "Indent right (keep selection)" })

	-- Move lines up/down in visual mode
	map("v", "I", ":m '<-2<CR>gv=gv", { desc = "Move line up", silent = true })
	map("v", "K", ":m '>+1<CR>gv=gv", { desc = "Move line down", silent = true })

	-- Better paste (don't yank replaced text)
	map("v", "p", '"_dP', { desc = "Paste (don't yank)" })

	-- Yank to system clipboard
	map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
	map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
end

-- =============================================================================
-- LSP KEYMAPS (Buffer-local, only when LSP attaches)
-- =============================================================================
M.setup_lsp = function()
	-- This is handled in lsp.lua via LspAttach autocmd
	-- Example:
	-- vim.api.nvim_create_autocmd("LspAttach", {
	--   callback = function(ev)
	--     local bufnr = ev.buf
	--     vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
	--   end
	-- })
end

-- =============================================================================
-- PLUGIN-SPECIFIC KEYMAPS
-- =============================================================================
M.setup_plugin_specific = function()
	local map = vim.keymap.set

	-- fzf-lua (only if loaded)
	local has_fzf, fzf = pcall(require, "fzf-lua")
	if has_fzf then
		map("n", "<leader>ff", function() fzf.files() end, { desc = "Find files" })
		map("n", "<leader>fg", function() fzf.live_grep() end, { desc = "Live grep" })
		map("n", "<leader>fb", function() fzf.buffers() end, { desc = "Find buffers" })
	end

	-- Neo-tree / NvimTree
	map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file tree", silent = true })

	-- Trouble
	map("n", "<leader>xx", ":TroubleToggle<CR>", { desc = "Toggle Trouble", silent = true })
end

-- =============================================================================
-- COMMAND-LINE KEYMAPS
-- =============================================================================
M.setup_cmdline = function()
	-- Command-line navigation using custom keys
	vim.keymap.set("c", "<C-j>", "<Left>", { desc = "Move left in cmdline" })
	vim.keymap.set("c", "<C-l>", "<Right>", { desc = "Move right in cmdline" })
end

-- =============================================================================
-- MAIN SETUP
-- =============================================================================
M.setup = function()
	-- Setup scoping system first
	scopes.setup()

	-- Apply keymaps in order
	M.setup_global()
	M.setup_navigation() -- Buffer-scoped
	M.setup_editing()
	M.setup_plugin_specific()
	M.setup_cmdline()

	-- Debug helper
	vim.notify("Organized keymaps loaded. Use :DebugKeymap to check buffer scope", vim.log.levels.INFO)
end

return M
