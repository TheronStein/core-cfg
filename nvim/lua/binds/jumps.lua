wk.add({
  { "<leader>j", group = "jumps", icon = { icon = "󰞘", color = "cyan" } },
  { "<leader>jb", "<C-o>", desc = "Jump backward" },
  { "<leader>je", "<C-i>", desc = "Jump forward" },
  { "<leader>jB", "{", desc = "Previous paragraph" },
  { "<leader>jE", "}", desc = "Next paragraph" },
  { "<leader>jS", "[[", desc = "Previous section" },
  { "<leader>js", "]]", desc = "Next section" },
  { "<leader>jd", "gd", desc = "Go to definition" },
  { "<leader>jD", "gD", desc = "Go to declaration" },
  { "<leader>jm", "`", desc = "Jump to mark" },
  { "<leader>jM", "'", desc = "Jump to mark (line)" },
})
-- -- -- J-based jump motions (j is now freed up)

vim.keymap.set("v", "s", ":sort<CR>", { desc = "Sort selected lines" })
