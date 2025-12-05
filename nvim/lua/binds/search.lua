local map = vim.keymap.set
local wk = require("which-key")

local M = {}
-- [[[ Page Up/Down Remapping ]]]

function M.setup()
  map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
  map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
end

return M
