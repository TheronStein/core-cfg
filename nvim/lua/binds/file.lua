local wk = require("which-key")

wk.add({
  { "<C-s>", ":w<CR>", desc = "Save current file" },
}, { mode = "n" })
