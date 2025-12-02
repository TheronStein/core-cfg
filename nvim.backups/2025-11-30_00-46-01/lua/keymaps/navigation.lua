-- [[[ Page Up/Down Remapping ]]]

local map = vim.keymap.set
local wk = require("which-key")

wk.add({
  { "<C-i>", "5k", desc = "Jump up 5 lines" },
  { "<C-k>", "5j", desc = "Jump down 5 lines" },
  { "i", "k", desc = "cursor up" },
  { "k", "j", desc = "cursor down" },
  { "j", "h", desc = "cursor left" },
  { "l", "l", desc = "cursor right" },
})

wk.add({
  {
    { "<C-i>", "<PageUp>", desc = "↑ up" },
    { "<C-j>", "<PageDown>", desc = "↓ down" },
    { "<C-k>", "<C-Left>", desc = "← left" },
    { "<C-l>", "<C-Right>", desc = "→ right" },
  },
  { mode = "i" },
})

--
wk.add({
  { "<C-i>", "5k", desc = "Jump up 5 lines" },
  { "<C-k>", "5j", desc = "Jump down 5 lines" },
  { "i", "k", desc = "cursor up" },
  { "k", "j", desc = "cursor down" },
  { "j", "h", desc = "cursor left" },
  { "l", "l", desc = "cursor right" },
}, { mode = { "v", "n" } })

map({ "n", "v" }, "i", "k", { noremap = true, silent = true })
map({ "n", "v" }, "k", "j", { noremap = true, silent = true })
map({ "n", "v" }, "j", "h", { noremap = true, silent = true })
map({ "n", "v" }, "l", "l", { noremap = true, silent = true })

map({ "n", "v" }, "I", "<C-u>", { desc = "Page up " }, { noremap = true, silent = true })
map({ "n", "v" }, "K", "<C-d>", { desc = "Page down" }, { noremap = true, silent = true })
map("n", "A", "i", { noremap = true, silent = true }) -- O = big up jump (shift+o)
-- map("n", "D", "A", { noremap = true, silent = true }) -- O = big up jump (shift+o)
-- map("v", "D", "A", { noremap = true, silent = true
