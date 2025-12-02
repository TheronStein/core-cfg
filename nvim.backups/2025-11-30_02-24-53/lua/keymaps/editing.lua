local map = vim.keymap.set
local wk = require("which-key")

wk.add({
  { "<M-D>", "<C-u>", desc = "Delete left" },
}, { mode = { "i" }, noremap = true, silent = true })

wk.add({
  { "<C-u>", "u", desc = "Undo Action" },
}, { mode = { "n", "v" }, noremap = true, silent = true })
