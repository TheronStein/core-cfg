local map = vim.keymap.set
local wk = require("lua.docs.workspace.modules.input.which-key")

wk.add({
	"<localleader>Fb",
	"ma=aBgv=gv'a",
	{ desc = "Format block/paragraph" },
})

-- [[[ Undo Remap  ============================

-- ]]] ============================

-- [[[ Format Mappings =============================================================================

-- [[[ Indentation Hanndling
map("i", "<S-Tab>", "<C-d>", { desc = "Unindent in insert mode" })
map("v", "<Tab>", ">gv", { desc = "Indent in visual mode" })
map("v", "<S-Tab>", "<gv", { desc = "Unindent in visual mode" })

-- -- vim.keymap.set("n", "<S-Tab>", function()
-- -- 	local col = vim.fn.col(".")
-- -- 	local line = vim.fn.getline(".")
-- --
-- -- 	-- Check if there's whitespace before cursor
-- -- 	if col > 1 and line:sub(1, col - 1):match("%s+$") then
-- -- 		-- Delete up to a tab's worth of spaces before cursor
-- -- 		local tabstop = vim.bo.tabstop
-- -- 		local spaces_to_delete = math.min(
-- -- 			tabstop,
-- -- 			col - 1 - (line:sub(1, col - 1):match("(.-)%s+$") and #line:sub(1, col - 1):match("(.-)%s+$") or 0)
-- -- 		)
-- -- 		vim.cmd("normal! " .. spaces_to_delete .. "X")
-- -- 	end
-- -- end, { noremap = true, silent = true })

-- ]]]
