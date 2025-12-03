local map = vim.keymap.set
local wk = require("which-key")

-- [[[ Page Up/Down Remapping ]]]

map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
