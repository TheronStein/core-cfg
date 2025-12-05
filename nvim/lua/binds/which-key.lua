--
-- -- ==========================================================================
-- -- which-key Groups(define these first)
-- -- -- =========================================================================
--
-- -- - `icon` (`string`): the icon to use **(optional)**
-- -- - `hl` (`string`): the highlight group to use for the icon **(optional)**
-- -- - `color` (`string`): the color to use for the icon **(optional)**
-- --     valid colors are: `azure`, `blue`, `cyan`, `green`, `grey`, `orange`, `purple`, `red`, `yellow`
-- -- - `cat` (`string`): the category of the icon **(optional)**
-- --     valid categories are: `file`, `filetype`, `extension`
-- -- - `name` (`string`): the name of the icon in the specified category **(optional)**

-- local M = {}
--
-- M.setup = function()
--   local fzf = require("fzf-lua")

-- TODO: finish which-key group setup and fzf-lua integration

local M = {}

function M.setup()
	local wk = require("which-key")

	wk.add({
		{ "z", group = "folds", icon = { icon = "󰊢", "orange" } }, --󰊢
		mode = { "n" },
	})

	wk.add({
		{ "<tab>", group = "Tabs/Buffers" },
		{ "<localleader>e", group = "editor" },
		{ pattern = "tab", icon = "󰓩 ", color = "purple" },
		{ pattern = "%f[%a]ai", icon = " ", color = "green" },
		-- { plugin = "grapple.nvim", pattern = "grapple", icon = "󰛢", color = "azure" },
		{ pattern = "exit", icon = "󰈆 ", color = "red" },
		{ pattern = "quit", icon = "󰈆 ", color = "red" },
		{ plugin = "CopilotChat.nvim", icon = " ", color = "azure" },
		{ pattern = "find", icon = " ", color = "blue" },
		-- { plugin = "yanky.nvim", icon = "󰅇", color = "yellow" },
		{ "<leader>g", group = "git", icon = { icon = "󰊢", "orange" } }, --󰊢
		{ "<leader>f", group = "file/find", icon = { icon = "", "blue" } },
		{ "<leader>a", group = "ai", icon = { icon = " ", color = "azure" } },
		{ "<leader>c", group = "code", icon = { icon = "", color = "purple" } },
		{ "<leader>d", group = "diagnostics/debug", icon = { icon = "", color = "red" } },
		{ "<leader>y", group = "yank/clipboard", icon = { icon = "󰅇", color = "yellow" } },
		{ "<leader>n", group = "notifications", icon = { icon = "󰵅 ", color = "yellow" } },
		{ "<leader>u", group = "ui/toggle", icon = { icon = "󰙵 ", color = "cyan" } },
		{ "<leader>w", group = "windows", icon = { icon = " ", color = "green" } },
		{ "<leader>l", group = "lsp", icon = { icon = "", "orange" } },
		{ "<leader>r", group = "reload", icon = { icon = "󰑓", color = "green" } },
		{ "<leader>s", group = "search", icon = { icon = "", "cyan" } },
		{ "<localleader>b", group = "bookmarks", icon = { icon = "󰃅", "cyan" } },
		{ "<localleader>t", group = "tabs", icon = { icon = "󰓩", color = "purple" } },
		{ "<localleader>F", group = "format", icon = { icon = "󰉼", color = "blue" } },
		{ "<localleader>m", group = "markdown", icon = { icon = "", color = "cyan" } },
		{ "<localleader>l", group = "LSP", icon = { icon = "󰵅⚡", color = "yellow" } },
		{ "<localleader>u", group = "undo", icon = { icon = "", color = "orange" } },
		{ "<localleader>d", group = "diff/compare", icon = { icon = "󰦓", color = "blue" } },
		{ "<localleader>s", group = "sessions", icon = { icon = "󰆓 ", color = "purple" } },
		{ "<C-g>", group = "diagnostics/reset", icon = { icon = "󰌑", color = "yellow" } },
	})

	-- local wk = require("which-key")
	-- --
	-- wk.add({
	--   { "<localleader>e", group = "editor" },
	--   { pattern = "tab", icon = "󰓩 ", color = "purple" },
	--   { pattern = "%f[%a]ai", icon = " ", color = "green" },
	--   -- { plugin = "grapple.nvim", pattern = "grapple", icon = "󰛢", color = "azure" },
	--   { pattern = "exit", icon = "󰈆 ", color = "red" },
	--   { pattern = "quit", icon = "󰈆 ", color = "red" },
	--   { plugin = "CopilotChat.nvim", icon = " ", color = "azure" },
	--   { pattern = "find", icon = " ", color = "blue" },
	--   -- { plugin = "yanky.nvim", icon = "󰅇", color = "yellow" },
	--   { "<localleader>b", group = "bookmarks", icon = { icon = "󰃅", "cyan" } },
	--   { "<leader>g", group = "git", icon = { icon = "󰊢", "orange" } }, --󰊢
	--   { "<leader>f", group = "file/find", icon = { icon = "", "blue" } },
	--   { "<leader>a", group = "ai", icon = { icon = " ", color = "azure" } },
	--   { "<leader>c", group = "code", icon = { icon = "", color = "purple" } },
	--   { "<leader>y", group = "yank/clipboard", icon = { icon = "󰅇", color = "yellow" } },
	--   { "<localleader>t", group = "tabs", icon = { icon = "󰓩", color = "purple" } },
	--   { "<localleader>F", group = "format", icon = { icon = "󰉼", color = "blue" } },
	--   { "<localleader>m", group = "markdown", icon = { icon = "", color = "cyan" } },
	--   { "<localleader>l", group = "LSP", icon = { icon = "󰵅⚡", color = "yellow" } },
	--   { "<localleader>u", group = "undo", icon = { icon = "", color = "orange" } },
	--   { "<leader>n", group = "notifications", icon = { icon = "󰵅 ", color = "yellow" } },
	--   { "<leader>u", group = "ui/toggle", icon = { icon = "󰙵 ", color = "cyan" } },
	--   { "<leader>w", group = "windows", icon = { icon = " ", color = "green" } },
	--   { "<leader>l", group = "lsp", icon = { icon = "", "orange" } },
	--   { "<leader>s", group = "search", icon = { icon = "", "cyan" } },
	--   { "<localleader>s", group = "sessions", icon = { icon = "󰆓 ", color = "purple" } },
	--   { "<C-g>", group = "diagnostics/reset", icon = { icon = "󰌑", color = "yellow" } },
	-- })
	--
	-- which-key state management commands (registered in ui/which-key.lua)

	-- wk.add({
	--   map({
	--
	--   })
	-- })

	-- -- ==========================================================================
	-- -- which-key Groups(define these first)
	-- -- -- =========================================================================
	--
	-- -- - `icon` (`string`): the icon to use **(optional)**
	-- -- - `hl` (`string`): the highlight group to use for the icon **(optional)**
	-- -- - `color` (`string`): the color to use for the icon **(optional)**
	-- --     valid colors are: `azure`, `blue`, `cyan`, `green`, `grey`, `orange`, `purple`, `red`, `yellow`
	-- -- - `cat` (`string`): the category of the icon **(optional)**
	-- --     valid categories are: `file`, `filetype`, `extension`
	-- -- - `name` (`string`): the name of the icon in the specified category **(optional)**

	local wk = require("which-key")
	--
	wk.add({
		{ "<localleader>e", group = "editor" },
		{ pattern = "tab", icon = "󰓩 ", color = "purple" },
		{ pattern = "%f[%a]ai", icon = " ", color = "green" },
		-- { plugin = "grapple.nvim", pattern = "grapple", icon = "󰛢", color = "azure" },
		{ pattern = "exit", icon = "󰈆 ", color = "red" },
		{ pattern = "quit", icon = "󰈆 ", color = "red" },
		{ plugin = "CopilotChat.nvim", icon = " ", color = "azure" },
		{ pattern = "find", icon = " ", color = "blue" },
		-- { plugin = "yanky.nvim", icon = "󰅇", color = "yellow" },
		{ "<localleader>b", group = "bookmarks", icon = { icon = "󰃅", "cyan" } },
		{ "<leader>g", group = "git", icon = { icon = "󰊢", "orange" } }, --󰊢
		{ "<leader>f", group = "file/find", icon = { icon = "", "blue" } },
		{ "<leader>a", group = "ai", icon = { icon = " ", color = "azure" } },
		{ "<leader>c", group = "code", icon = { icon = "", color = "purple" } },
		{ "<leader>y", group = "yank/clipboard", icon = { icon = "󰅇", color = "yellow" } },
		{ "<localleader>t", group = "tabs", icon = { icon = "󰓩", color = "purple" } },
		{ "<localleader>F", group = "format", icon = { icon = "󰉼", color = "blue" } },
		{ "<localleader>m", group = "markdown", icon = { icon = "", color = "cyan" } },
		{ "<localleader>l", group = "LSP", icon = { icon = "󰵅⚡", color = "yellow" } },
		{ "<localleader>u", group = "undo", icon = { icon = "", color = "orange" } },
		{ "<leader>n", group = "notifications", icon = { icon = "󰵅 ", color = "yellow" } },
		{ "<leader>u", group = "ui/toggle", icon = { icon = "󰙵 ", color = "cyan" } },
		{ "<leader>w", group = "windows", icon = { icon = " ", color = "green" } },
		{ "<leader>l", group = "lsp", icon = { icon = "", "orange" } },
		{ "<leader>s", group = "search", icon = { icon = "", "cyan" } },
		{ "<localleader>s", group = "sessions", icon = { icon = "󰆓 ", color = "purple" } },
		{ "<C-g>", group = "diagnostics/reset", icon = { icon = "󰌑", color = "yellow" } },
	})
end

return M
