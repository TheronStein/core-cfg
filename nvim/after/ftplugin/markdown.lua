-- Markdown-specific folding via mkdnflow
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.require('mkdnflow').foldexpr()"
vim.opt_local.foldenable = false -- Don't fold by default when opening
vim.opt_local.foldlevel = 99 -- Open all folds by default
vim.opt_local.foldlevelstart = 99

-- Optional: markdown-specific settings
vim.opt_local.wrap = true -- Enable line wrapping in markdown
vim.opt_local.linebreak = true -- Break at word boundaries

-- Markdown-specific keybinds using which-key
local wk = require("which-key")

-- Navigation (no prefix)
wk.add({
  { "<CR>", "<cmd>MkdnEnter<cr>", desc = "Follow link/Continue list", buffer = 0, mode = "n" },
  { "<C-b>b", "<cmd>MkdnGoBack<cr>", desc = "Go back", buffer = 0, mode = "n" },
  { "<C-n> f", "<cmd>MkdnGoForward<cr>", desc = "Go forward", buffer = 0, mode = "n" },
  { "<C-b> h", "<cmd>MkdnPrevHeading<cr>", desc = "Previous heading", buffer = 0, mode = "n" },
  { "<C-n> h", "<cmd>MkdnNextHeading<cr>", desc = "Next heading", buffer = 0, mode = "n" },
  { "<C-b> l", "<cmd>MkdnPrevLink<cr>", desc = "Previous link", buffer = 0, mode = "n" },
  { "<C-n> l", "<cmd>MkdnNextLink<cr>", desc = "Next link", buffer = 0, mode = "n" },
  {
    "<C-8>",
    "<cmd>MkdnNewListItemBelowInsert<cr>",
    desc = "New list item below",
    buffer = 0,
    mode = "n",
  },
  {
    "<M-8>",
    "<cmd>MkdnNewListItemAboveInsert<cr>",
    desc = "New list item above",
    buffer = 0,
    mode = "n",
  },
})

-- Insert mode table navigation
wk.add({
  { "<Tab>", "<cmd>MkdnTableNextCell<cr>", desc = "Next table cell", buffer = 0, mode = "i" },
  { "<S-Tab>", "<cmd>MkdnTablePrevCell<cr>", desc = "Previous table cell", buffer = 0, mode = "i" },
})

-- Markdown group
wk.add({
  { "<leader>m", group = "markdown", buffer = 0 },
  {
    "<leader>m+",
    "<cmd>MkdnIncreaseHeading<cr>",
    desc = "Increase heading level",
    buffer = 0,
    mode = "n",
  },
  {
    "<leader>m-",
    "<cmd>MkdnDecreaseHeading<cr>",
    desc = "Decrease heading level",
    buffer = 0,
    mode = "n",
  },
  {
    "<leader>mx",
    "<cmd>MkdnToggleToDo<cr>",
    desc = "Toggle to-do",
    buffer = 0,
    mode = { "n", "v" },
  },
  {
    "<leader>mn",
    "<cmd>MkdnUpdateNumbering<cr>",
    desc = "Update list numbering",
    buffer = 0,
    mode = "n",
  },
  { "<leader>mf", "<cmd>MkdnFoldSection<cr>", desc = "Fold section", buffer = 0, mode = "n" },
  { "<leader>mF", "<cmd>MkdnUnfoldSection<cr>", desc = "Unfold section", buffer = 0, mode = "n" },
  {
    "<leader>mT",
    function()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local toc = { "## Table of Contents", "" }
      for _, line in ipairs(lines) do
        local level, heading = line:match("^(#+)%s+(.+)$")
        if level and #level <= 3 then -- Only h1-h3
          local indent = string.rep("  ", #level - 1)
          local anchor = heading:lower():gsub("%s+", "-"):gsub("[^%w-]", "")
          table.insert(toc, indent .. "- [" .. heading .. "](#" .. anchor .. ")")
        end
      end
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_buf_set_lines(0, pos[1], pos[1], false, toc)
    end,
    desc = "Insert TOC",
    buffer = 0,
    mode = "n",
  },
})

-- Links subgroup
wk.add({
  { "<leader>ml", group = "links", buffer = 0 },
  {
    "<leader>mll",
    "<cmd>MkdnCreateLink<cr>",
    desc = "Create link",
    buffer = 0,
    mode = { "n", "v" },
  },
  {
    "<leader>mlp",
    "<cmd>MkdnCreateLinkFromClipboard<cr>",
    desc = "Create link from clipboard",
    buffer = 0,
    mode = "n",
  },
  { "<leader>mld", "<cmd>MkdnDestroyLink<cr>", desc = "Destroy link", buffer = 0, mode = "n" },
  { "<leader>mlf", "<cmd>MkdnFollowLink<cr>", desc = "Follow link", buffer = 0, mode = "n" },
  {
    "<leader>mly",
    "<cmd>MkdnYankAnchorLink<cr>",
    desc = "Yank anchor link",
    buffer = 0,
    mode = "n",
  },
  {
    "<leader>mlY",
    "<cmd>MkdnYankFileAnchorLink<cr>",
    desc = "Yank file anchor link",
    buffer = 0,
    mode = "n",
  },
})

-- Tables subgroup
wk.add({
  { "<leader>mt", group = "tables", buffer = 0 },
  { "<leader>mtt", "<cmd>MkdnTable<cr>", desc = "Create table", buffer = 0, mode = "n" },
  { "<leader>mtf", "<cmd>MkdnTableFormat<cr>", desc = "Format table", buffer = 0, mode = "n" },
  {
    "<leader>mtr",
    "<cmd>MkdnTableNewRowBelow<cr>",
    desc = "New table row below",
    buffer = 0,
    mode = "n",
  },
  {
    "<leader>mtR",
    "<cmd>MkdnTableNewRowAbove<cr>",
    desc = "New table row above",
    buffer = 0,
    mode = "n",
  },
  {
    "<leader>mtc",
    "<cmd>MkdnTableNewColAfter<cr>",
    desc = "New table column after",
    buffer = 0,
    mode = "n",
  },
  {
    "<leader>mtC",
    "<cmd>MkdnTableNewColBefore<cr>",
    desc = "New table column before",
    buffer = 0,
    mode = "n",
  },
})
