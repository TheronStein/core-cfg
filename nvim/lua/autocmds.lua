local api = vim.api

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
	group = api.nvim_create_augroup("YankHighlight", { clear = true }),
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
	desc = "Highlight yanked text",
})

-- Disable line numbers in terminal buffers
api.nvim_create_autocmd("TermOpen", {
	group = api.nvim_create_augroup("TerminalSettings", { clear = true }),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
	desc = "Clean terminal UI",
})

-- Easily hit escape in terminal mode.
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")
vim.keymap.set("t", "<D-c>", "<c-\\><c-n>")

-- Open a terminal at the bottom of the screen with a fixed height.
vim.keymap.set("n", ",st", function()
	vim.cmd.new()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 12)
	vim.wo.winfixheight = true
	vim.cmd.term()
	vim.cmd("startinsert")
end)

-- Restore cursor position in files
api.nvim_create_autocmd("BufReadPost", {
	group = api.nvim_create_augroup("RestoreCursor", { clear = true }),
	callback = function()
		local line = vim.fn.line("'\"")
		if line > 1 and line <= vim.fn.line("$") then
			vim.cmd('normal! g`"')
		end
	end,
	desc = "Restore cursor to last position",
})

-- Remove comment continuation for TOML files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "toml",
	callback = function()
		vim.opt_local.formatoptions:remove("o") -- Don't add comment leader on 'o' or 'O'
		vim.opt_local.formatoptions:remove("r") -- Don't add comment leader on return
	end,
})

-- Project-Local Config Loader
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		-- Use vim.fs.find instead of lspconfig.util
		local markers = { ".git", ".nvim.lua", ".nvimrc", "Cargo.toml", "package.json", "pyproject.toml" }
		local root_dir = vim.fs.root(0, markers)

		if root_dir then
			-- Source local .nvim.lua if exists
			local local_config = root_dir .. "/.nvim.lua"
			if vim.fn.filereadable(local_config) == 1 then
				vim.cmd("source " .. local_config)
			end
		end
	end,
	group = vim.api.nvim_create_augroup("ProjectLocal", { clear = true }),
})

-- Enable text wrapping for specific file types
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"markdown",
		"text",
		"log",
		"help",
	},
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
	group = vim.api.nvim_create_augroup("WrapFileTypes", { clear = true }),
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help", "qf", "man", "lspinfo", "checkhealth" },
	callback = function(ev)
		local bufnr = ev.buf
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, desc = "Close window" })
	end,
})

-- Enable text wrapping for buffers with no filetype
-- Use BufReadPost with a delay to ensure filetype detection has completed
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	callback = function()
		-- Use vim.schedule to defer the check until after filetype detection
		vim.schedule(function()
			-- Check if buffer still has no filetype
			if vim.bo.filetype == "" then
				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true
			end
		end)
	end,
	group = vim.api.nvim_create_augroup("WrapNoFiletype", { clear = true }),
})

-- Configure diagnostics
vim.diagnostic.config({
	virtual_text = true, -- Show inline diagnostic text
	signs = true, -- Show signs in the sign column
	underline = true, -- Underline errors
	update_in_insert = false, -- Don't update diagnostics in insert mode
	severity_sort = true, -- Sort by severity
	float = {
		border = "rounded",
		source = "always", -- Show source (e.g., "eslint", "lua_ls")
		header = "",
		prefix = "",
	},
})

-- Show diagnostics in a floating window on cursor hold
api.nvim_create_autocmd("CursorHold", {
	group = api.nvim_create_augroup("DiagnosticFloat", { clear = true }),
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false })
	end,
	desc = "Show diagnostics on hover",
})

-- Keymap to manually show diagnostics (in case you want it on demand)
-- vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- Hyprlang LSP
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = { "*.hl", "hypr*.conf" },
	callback = function(event)
		print(string.format("starting hyprls for %s", vim.inspect(event)))
		vim.lsp.start({
			name = "hyprlang",
			cmd = { "hyprls" },
			root_dir = vim.fn.getcwd(),
			settings = {
				hyprls = {
					preferIgnoreFile = true, -- set to false to prefer `hyprls.ignore`
					ignore = { "hyprlock.conf", "hypridle.conf" },
				},
			},
		})
	end,
})

-- vim.api.nvim_create_autocmd("TextYankPost", {
--   desc = "Highlight when yanking (copying) text",
--   group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
--   callback = function()
--     vim.hl.on_yank()
-- 22:54:49-   end,
-- })
