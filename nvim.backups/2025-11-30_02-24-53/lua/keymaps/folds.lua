-- [[[ FOLD MAPPINGS =============================================================================

-- Configure fold settings for marker-based folding (supports [[[, ]]] markers)
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = "[[[,]]]"
vim.opt.foldlevel = 0 -- Start with all folds closed
vim.opt.foldlevelstart = 0 -- Start with all folds closed when opening a file

-- Fold mappings with which-key integration
wk.add({
	{ "<localleader>f", group = "fold", icon = { icon = "", color = "purple" } },
	{ "<localleader>ft", "za", desc = "Toggle fold" },
	{ "<localleader>fc", "zc", desc = "Close fold" },
	{ "<localleader>fo", "zo", desc = "Open fold" },
	{ "<localleader>fC", "zM", desc = "Close all folds" },
	{ "<localleader>fO", "zR", desc = "Open all folds" },
	{ "<localleader>fn", "zj", desc = "Next fold" },
	{ "<localleader>fp", "zk", desc = "Previous fold" },
	{ "<localleader>fa", "zA", desc = "Toggle all levels" },
	{ "<localleader>fr", "zr", desc = "Reduce folding (open more)" },
	{ "<localleader>fm", "zm", desc = "More folding (close more)" },
})

-- ]]] =========================================================================================
