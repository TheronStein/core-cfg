local map = vim.keymap.set
local wk = require("which-key")

wk.add({
  { "<M-D>", "<C-u>", desc = "Delete left" },
}, { mode = { "i" }, noremap = true, silent = true })

wk.add({

  { "<C-u>", "u", desc = "Undo Action" },
}, { mode = { "n", "v" }, noremap = true, silent = true })

-- Visual block mode remaps
vim.keymap.set("x", "a", "I", { desc = "Insert at block start" })
vim.keymap.set("x", "A", "A", { desc = "Append at block end" })
vim.keymap.set("x", "", "c", { desc = "Change block" })

-- Quick visual block mode entry
vim.keymap.set("n", "<C-q>", "<C-v>", { desc = "Visual block mode" })
vim.keymap.set("n", "<leader>v", "<C-v>", { desc = "Visual block mode" })

-- Multi-line comment/uncomment (after visual selection)
vim.keymap.set("x", "<leader>cc", ":norm I# <CR>", { desc = "Comment lines" })
vim.keymap.set("x", "<leader>cu", ":norm ^x<CR>", { desc = "Uncomment lines" })

-- Alternative: more specific for your hyprlang files
vim.keymap.set("x", "<leader>/", ":s/^/# /<CR>:noh<CR>", { desc = "Comment block" })
vim.keymap.set("x", "<leader>?", ":s/^# //<CR>:noh<CR>", { desc = "Uncomment block" })
