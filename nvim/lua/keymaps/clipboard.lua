-- CLIPBOARD

-- map({ "n", "v" }, "y", [["+y]])
-- map("n", "Y", [["+Y]])
-- map("x", "p", [["_dP]])
-- map("x", "P", [["_dp]])
--
-- map({ "n", "v" }, "<leader>y", "y")
-- map("n", "<leader>Y", "Y")
local wk = require("which-key")

wk.add({
  -- Yank to system clipboard by default
  { "y", [["+y]], desc = "Yank to system clipboard", mode = { "n", "v" , "x" } },
  { "Y", [["+Y]], desc = "Yank line to system clipboard", mode ={ "n", "v" , "x" },

  -- Visual mode paste without overwriting clipboard
  -- p pastes before (like P), P pastes after (like p)
  { "p", [["_dP]], desc = "Paste before without yanking", mode = { "n", "v", "x" },
  { "P", [["_dp]], desc = "Paste after without yanking", mode = { "n", "v", "x" },

  -- Leader variants yank to internal register
  {
    "<leader>y",
    group = "Yank (internal)",
    { "<leader>y", "y", desc = "Yank to internal register", mode = { "n", "v" } },
    { "<leader>Y", "Y", desc = "Yank line to internal register", mode = "n" },
  },
})


wk.add({
 "x", [["_x]], desc = "Delete without yanking", mode = { "n", "v", "x" },

})

-- map({"n", "v", "x" } "x", [["_x]])
-- map({"n", "v", "x" } "X", [["_X]])
--
-- map({ "n", "v" }, "d", [["_d]])
-- map("n", "D", [["_D]])
-- map({ "n", "v" }, "c", [["_c]])
-- map("n", "C", [["_C]])
-- map({ "n", "v" }, "<leader>d", "d", { desc = "Delete to internal register" })
-- map("n", "<leader>D", "D", { desc = "Delete rest of line to internal register" })
-- explain what this is doing one more time i lost it

-- # Copilot (87ec78b7-62a7-4748-9be6-92dd5cd7c8c7) ───
--
-- This code remaps Neovim's delete and change operations to avoid polluting your clipboard/registers:
--
-- ## Default Behavior (Remapped):
-- - **`d`, `D`, `c`, `C`, `x`, `X`** → Delete to the **black hole register** `"_`
--   - Black hole register = deleted text is discarded, doesn't overwrite your clipboard
--   - You can still yank (`y`) text and paste it without delete operations interfering
--
-- ## Escape Hatch:
-- - **`<leader>d`, `<leader>D`** → Perform **normal delete** to internal register
--   - Use these when you actually want the deleted text saved (cut operation)
--   - Works in normal and visual modes
--
-- **TL;DR:** Delete/change normally discards text. Use `<leader>d` when you want to "cut" instead.

-- map("v", "<leader>p", "_dP", { desc = "Paste before/Replace Clipboard" })
-- map("v", "<leader>P", "_dp", { desc = "Paste after/Replace Clipboard" })
