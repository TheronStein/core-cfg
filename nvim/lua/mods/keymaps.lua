-- ╓────────────────────────────────────────────────────────────╖
-- ║ Keybindings Initialization                                 ║
-- ║ Load all keybinding modules                                ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}

local wk = require("which-key")
local map = vim.keymap.set

function M.setup()
	require("binds.which-key").setup()

	--- [[[ buffer close smartly

	map("n", "q", function()
		local bufnr = vim.api.nvim_get_current_buf()
		local buftype = vim.bo[bufnr].buftype
		local filetype = vim.bo[bufnr].filetype

		-- List of buffers that are safe to just :q or :bd
		local safe_fts = {
			"help",
			"qf",
			"fugitive",
			"git",
			"toggleterm",
			"lspinfo",
			"notify",
			"neo-tree",
			"aerial",
			"Trouble",
			"lspsagaoutline",
			"lazy",
			"mason",
			"null-ls-info",
			"undo-tree",
		}

		local is_safe = buftype ~= "" or vim.tbl_contains(safe_fts, filetype)
		if is_safe then
			pcall(function()
				vim.cmd("close")
			end) -- tries to close window first
			if vim.api.nvim_win_is_valid(0) then -- if still open, force buffer delete
				pcall(function()
					vim.cmd("bdelete")
				end)
			end
		else
			-- Normal buffer → try to delete it properly (keeps window if alternatives exist)
			local ok, _ = pcall(function()
				vim.cmd("Bdelete")
			end) -- if you use bufdelete.nvim
			if not ok then
				vim.cmd("bdelete")
			end
		end
	end, { desc = "Smart close" })

	--- ]]]

	--- [[[ Marks for visual mode
	wk.add({
		{ "v", "mVv", { silent = true }, desc = "Set mark V before visual mode" },
		{ "V", "mVV", { silent = true }, desc = "Set mark V before visual line mode" },
		-- { "<Tab>", "<C-t>", desc = "Indent in insert mode", mode = { "i" } },
		-- { "<S-Tab>", "<C-d>", desc = "Unindent in insert mode", mode = { "i" } },
	})
	--- ]]]

	-- [[[ Bind modules loading
	require("binds.clipboard").setup()
	require("binds.tmux-vim-navigation").setup()
	require("binds.window").setup()
	require("binds.editing").setup()
	require("binds.search").setup()
	require("binds.tabs-buffers").setup()
	require("binds.notifications").setup()
	require("binds.reload").setup()
	require("binds.ai")
	-- require("binds.tmux-wezterm").setup()
	-- ]]]

	-- [[[ Load custom modules
	require("core.cheatsheet").setup()
	-- require("core.config").setup()
	require("mods.figlet").setup()
	require("mods.commentbox-picker").setup()
	-- ]]]

	-- [[[ Outdated UI enhancements loading (notifications, global help, lualine extensions)

	-- -- Load UI enhancements (notifications, global help, lualine extensions)
	-- local ok, _ = pcall(function()
	-- 	-- Initialize notification system
	-- 	local notifications = require("mods.notifications")
	-- 	notifications.setup()
	--
	-- 	-- Set up notification keymaps
	-- 	require("binds.notifications")
	--
	-- 	-- Set up global help system
	-- 	local global_help = require("binds.global-help")
	-- 	global_help.setup()
	--
	-- 	vim.notify("UI Enhancements loaded successfully", vim.log.levels.INFO)
	-- end)
	--
	-- if not ok then
	-- 	vim.notify("Failed to load UI enhancements", vim.log.levels.WARN)
	-- end
	-- ]]
end

return M
