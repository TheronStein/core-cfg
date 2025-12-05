-- lua/keymaps/lsp.lua
local map = vim.keymap.set
local wk = require("which-key")
local Hydra = require("hydra")

-- 1. Normal keymaps (the ones you actually use daily)
map("n", "gh", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover documentation" })
map("n", "gH", "<cmd>Lspsaga hover_doc ++keep<CR>", { desc = "Pinned hover" })
map("n", "gd", "<cmd>Lspsaga finder def<CR>", { desc = "Find definition + refs" })
map("n", "gr", "<cmd>Lspsaga finder ref<CR>", { desc = "References" })
map("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "Type definition" })

map({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code action" })
map("n", "<leader>cr", "<cmd>Lspsaga rename<CR>", { desc = "Rename symbol" })
map("n", "<leader>co", "<cmd>Lspsaga outline<CR>", { desc = "Symbols outline" })

-- 2. which-key groups — declared right here, only for these maps
wk.add({
  -- { "<leader}c", group = "code" },
  { "<leader>ca", desc = "Code action" },
  { "<leader>cr", desc = "Rename" },
  { "<leader>co", desc = "Outline" },

  { "g", group = "goto/info" },
  { "gh", desc = "Hover doc" },
  { "gH", desc = "Pinned hover" },
  { "gd", desc = "Definition + refs" },
  { "gr", desc = "References" },
  { "gt", desc = "Type definition" },
  { "<leader>ld", desc = "Diagnose LSP & Completion" },
  { "<leader>dk", desc = "Debug Keymap Scope" },
}, { buffer = 0 }) -- only active when LSP is attached

-- 3. Hydra — also declared right here (hold g or <leader>l)
Hydra({
  name = "LSP Goto",
  mode = "n",
  body = "g",
  color = "pink",
  heads = {
    { "h", "<cmd>Lspsaga hover_doc<CR>", { desc = "hover" } },
    { "H", "<cmd>Lspsaga hover_doc ++keep<CR>", { desc = "pinned hover" } },
    { "d", "<cmd>Lspsaga finder def<CR>", { desc = "definition" } },
    { "r", "<cmd>Lspsaga finder ref<CR>", { desc = "references" } },
    { "t", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "type def" } },
    { "<Esc>", nil, { exit = true } },
  },
})

-- Hydra({
--   name = "LSP Actions",
--   mode = "n",
--   body = "<leader>c",
--   color = "teal",
--   heads = {
--     { "a", "<cmd>Lspsaga code_action<CR>", { desc = "code action" } },
--     { "r", "<cmd>Lspsaga rename<CR>", { desc = "rename" } },
--     { "o", "<cmd>Lspsaga outline<CR>", { desc = "outline" } },
--     { "<Esc>", nil, { exit = true } },
--   },
-- })

-- -- 	-- require("nvim-treesitter.textobjects.move").goto_next_end("@function.outer")
-- --  { silent = true })
-- --
-- -- -- C-S-O: Beginning of function (using Treesitter)
-- -- vim.keymap.set({ "n", "v" }, "<C-S-O>", function()
-- -- 	-- require("nvim-treesitter.textobjects.move").goto_previous_start("@function.outer")
-- -- end, { silent = true })
--
-- -- Resize panels with OL;K
-- map("n", "<D-j>", "<C-w><", { silent = true, noremap = true }) -- left
-- map("n", "<D-k>", "<C-w>-", { silent = true, noremap = true }) -- down
-- map("n", "<D-i>", "<C-w>+", { silent = true, noremap = true }) -- up
-- map("n", "<D-l>", "<C-w>>", { silent = true, noremap = true }) -- right
--
-- -- Open line functionality (o/O replaced by navigation)
-- -- map("n", "<C-i>", "o<Esc>", { noremap = true, silent = true, desc = "Open line below" })
-- -- map("n", "<C-S-i>", "O<Esc>", { noremap = true, silent = true, desc = "Open line above" })
--
-- OL;K Navigation (o=up, l=down, k=left, ;=right)
--
