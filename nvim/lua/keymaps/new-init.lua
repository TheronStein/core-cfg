local unmap = vim.keymap.del
local map = vim.keymap.set -- ({"n", "v", "x"})
local function safe_unmap(mode, key)
  pcall(vim.api.nvim_del_keymap, mode, key)
end
local function save_unvim(mode, key)
  pcall(unmap, mode, key)
end
local nav = require("mods.tmux-vim-navigation")
nav.setup()

--
local clipb = require("mods.clipboard")
clipb.setup()

-- Diff/comparison utilities
-- local diff = require("keymaps.diff")
-- diff.setup()

-- LSP diagnostic utilities
-- local lsp_diag = require("keymaps.lsp-diagnostic")
-- lsp_diag.setup()

-- Keymap scoping system
-- local keymap_scopes = require("keymaps.scopes")
-- keymap_scopes.setup()

-- Optional: Use organized keymaps (comment out to use old keymaps.lua)
-- local keymaps_org = require("keymaps.organized")
-- keymaps_org.setup()
