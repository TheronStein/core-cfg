-- [[[ FOLD MAPPINGS =============================================================================

-- Configure fold settings for marker-based folding (supports [[[, ]]] markers)
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = "[[[,]]]"
vim.opt.foldlevel = 0 -- Start with all folds closed
vim.opt.foldlevelstart = 0 -- Start with all folds closed when opening a file

-- Fold mappings with which-key integration
wk.add({
  { "<localleader>z", group = "fold", icon = { icon = "", color = "purple" } },
  { "<localleader>zt", "za", desc = "Toggle fold" },
  { "<localleader>zc", "zc", desc = "Close fold" },
  { "<localleader>zo", "zo", desc = "Open fold" },
  { "<localleader>zC", "zM", desc = "Close all folds" },
  { "<localleader>zO", "zR", desc = "Open all folds" },
  { "<localleader>zn", "zj", desc = "Next fold" },
  { "<localleader>zp", "zk", desc = "Previous fold" },
  { "<localleader>za", "zA", desc = "Toggle all levels" },
  { "<localleader>zr", "zr", desc = "Reduce folding (open more)" },
  { "<localleader>zm", "zm", desc = "More folding (close more)" },
})

-- ]]] =========================================================================================
