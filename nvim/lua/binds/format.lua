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

--          ╭─────────────────────────────────────────────────────────╮
--           |                          INDENTING                       │
--          ╰─────────────────────────────────────────────────────────╯

-- Visual mode indenting (keeps selection after indent)
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Normal mode line indenting
vim.keymap.set("n", "<localleader>F>", ">>", { desc = "Indent line right" })
vim.keymap.set("n", "<localleader>F<", "<<", { desc = "Indent line left" })

-- Indent entire file and return to position
vim.keymap.set("n", "<localleader>F=", "gg=G<C-o>", { desc = "Auto-indent entire file" })

-- Indent current paragraph
vim.keymap.set("n", "<localleader>Fp", "=ip", { desc = "Indent paragraph" })

-- Indent current function/block (with treesitter)
vim.keymap.set("n", "<localleader>Ff", "=af", { desc = "Indent function" })

-- Fix indentation in visual selection
vim.keymap.set("v", "=", "=", { desc = "Auto-indent selection" })

-- Tab/Shift-Tab for indenting in visual mode
--       vim.keymap.set({ "n", "v" }, "<Tab>", ">gv", { desc = "Indent right" })
-- vim.keymap.set({ "n", "v" }, "<S-Tab>", "<gv", { desc = "Indent left" })

-- Reindent and format (if you have formatter setup)
vim.keymap.set("n", "<localleader>FF", function()
  vim.cmd("normal! gg=G")
  vim.lsp.buf.format({ async = false })
end, { desc = "Reindent and format file" })

-- **Built-in commands you can also use directly:**
-- - `gg=G` - Auto-indent entire file
-- - `==` - Auto-indent current line
-- - `=` in visual mode - Auto-indent selection
-- - `>ip` / `<ip` - Indent/outdent paragraph
-- - `>i{` / `<i{` - Indent/outdent inside braces
