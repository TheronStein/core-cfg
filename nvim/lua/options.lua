-- ~/.config/nvim/lua/options.lua
local opt = vim.opt

-- Line numbers and cursor
opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true -- Highlight current line
opt.tabstop = 2 -- 2 spaces for tabs
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- Convert tabs to spaces
opt.autoindent = true -- Copy indent from current line

opt.clipboard = "unnamedplus"
opt.exrc = true -- Allow local .nvim.lua/.nvimrc
opt.secure = true -- Sandbox: No shell cmds in untrusted dirs

-- Search
opt.ignorecase = true -- Case-insensitive search
opt.smartcase = true -- Case-sensitive if uppercase in query
opt.hlsearch = true -- Highlight search matches
opt.incsearch = true -- Incremental search

-- UI and behavior
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right
opt.wrap = true -- Disable line wrapping
opt.signcolumn = "yes" -- Always show sign column
opt.updatetime = 250 -- Faster updates (for diagnostics, etc.)
opt.laststatus = 3 -- Global statusline (3 = single statusline at top with globalstatus)
opt.showtabline = 2 -- Always show tabline

-- Memory and performance
opt.swapfile = false -- Disable swap files
opt.undofile = true -- Enable persistent undo
opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Undo file directory

-- Splits
opt.splitright = true -- New vertical splits go right
opt.splitbelow = true -- New horizontal splits go below
opt.modeline = true
opt.modelines = 10 -- Check first/last 5 lines
opt.foldmethod = "marker" -- Use markers for folding
opt.foldmarker = "[[[,]]]" -- Custom fold markers
opt.modelines = 5 -- Check first/last 5 lines
-- Quit behavior
opt.hidden = true -- Hide buffers instead of closing them
opt.confirm = true -- Confirm before quitting with unsaved changes
vim.cmd([[cabbrev q qa]]) -- Make :q quit all windows
vim.cmd([[cabbrev q! qa!]]) -- Make q! quit all windows

-- vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")
-- vim.keymap.set("n", "<space>x", ":.lua<CR>")
-- vim.keymap.set("v", "<space>x", ":lua<CR>")
--
-- vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
-- vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
