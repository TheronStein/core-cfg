local wk = require("lua.docs.workspace.modules.input.which-key")

wk.add({
	{ "<leader>gs", desc = "Git Status" },
	{ "<leader>gb", desc = "Git Blame" },
	{ "<leader>gd", desc = "Git Diff" },
}, { mode = "n" })
