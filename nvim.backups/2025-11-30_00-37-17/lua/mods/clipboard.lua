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



-- Seamless tmux/neovim navigation
local M = {}
-- Set up keymaps
function M.setup()
	-- Configure Neovim to use wl-clipboard on Wayland
	if vim.env.WAYLAND_DISPLAY then
		vim.g.clipboard = {
			name = "wl-clipboard",
			copy = {
				["+"] = "wl-copy",
				["*"] = "wl-copy -p",
			},
			paste = {
				["+"] = "wl-paste -n",
				["*"] = "wl-paste -n  -p",
			},
			cache_enabled = 0,
		}
	else
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
	if os.getenv("SSH_TTY") then
		local function paste()
			return vim.split(vim.fn.getreg("+"), "\n")
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
	end
end

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
return M
