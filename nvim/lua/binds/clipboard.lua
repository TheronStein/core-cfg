local wk = require("which-key")
-- Seamless tmux/neovim navigation
local M = {}
-- Set up keymaps
function M.setup()
  -- Configure clipboard based on environment
  if os.getenv("SSH_TTY") then
    -- SSH: Use OSC 52 for copy, basic paste fallback
    local function paste()
      return vim.split(vim.fn.getreg('"'), "\n")
    end
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = paste,
        ["*"] = paste,
      },
    }
  elseif vim.env.WAYLAND_DISPLAY then
    -- Wayland: Use wl-clipboard
    vim.g.clipboard = {
      name = "wl-clipboard",
      copy = {
        ["+"] = "wl-copy",
        ["*"] = "wl-copy -p",
      },
      paste = {
        ["+"] = "wl-paste -n",
        ["*"] = "wl-paste -n -p",
      },
      cache_enabled = 0,
    }
  else
    -- X11: Use xclip
    vim.g.clipboard = {
      name = "xclip",
      copy = {
        ["+"] = "xclip -selection clipboard",
        ["*"] = "xclip -selection primary",
      },
      paste = {
        ["+"] = "xclip -selection clipboard -o",
        ["*"] = "xclip -selection primary -o",
      },
      cache_enabled = 0,
    }
  end

  if vim.fn.has("unnamedplus") == 1 then
    vim.opt.clipboard = "unnamed,unnamedplus"
  else
    vim.opt.clipboard = "unnamed"
  end

  wk.add({
    -- Yank to system clipboard by default
    { "y", [["+y]], desc = "Yank to system clipboard", mode = { "n", "v", "x" }, noremap = true, silent = true },
    { "Y", [["+Y]], desc = "Yank line to system clipboard", mode = { "n", "v", "x" }, noremap = true, silent = true },

    -- Visual mode paste without overwriting clipboard
    { "p", [["_dP]], desc = "Paste without yanking", mode = { "v", "x" }, noremap = true, silent = true },
    { "P", [["_dp]], desc = "Paste without yanking", mode = { "v", "x" }, noremap = true, silent = true },

    -- Leader variants yank to internal register
    {
      "<leader>y",
      group = "Yank (internal)",
      { "<leader>y", "y", desc = "Yank to internal register", mode = { "n", "v" }, noremap = true, silent = true },
      { "<leader>Y", "Y", desc = "Yank line to internal register", mode = "n", noremap = true, silent = true },
    },
  })
end

return M
-- function M.paste_markdown()
-- 	local handle = io.popen("wl-paste -t text/html 2>/dev/null | pandoc -f html -t markdown 2>/dev/null")
-- 	if handle then
-- 		local result = handle:read("*a")
-- 		handle:close()
-- 		if result and result ~= "" then
-- 			return vim.api.nvim_put({ result }, "c", true, true)
-- 		else
-- 			-- Fallback to regular paste if no HTML format available
-- 			return vim.cmd('normal! "+p')
-- 		end
-- 	end
-- end

--
-- local opt = vim.opt
--
-- opt.clipboard = "unnamedplus"
--
-- if vim.env.SSH_CONNECTION then
--   local function vim_paste()
--     local content = vim.fn.getreg '"'
--     return vim.split(content, "\n")
--   end
--
--   vim.g.clipboard = {
--     name = "OSC 52",
--     copy = {
--       ["+"] = require("vim.ui.clipboard.osc52").copy "+",
--       ["*"] = require("vim.ui.clipboard.osc52").copy "*",
--     },
--     paste = {
--       ["+"] = vim_paste,
--       ["*"] = vim_paste,
--     },
--   }
-- end
