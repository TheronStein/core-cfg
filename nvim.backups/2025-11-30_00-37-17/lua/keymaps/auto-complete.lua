vim.keymap.set("n", "<leader>d", function()
  vim.cmd("Lspsaga close_floats")
  vim.cmd("Lspsaga outline " .. (vim.g.saga_outline_open and "close" or "open"))
  vim.g.saga_outline_open = not vim.g.saga_outline_open
end, { desc = "Toggle max context" })
