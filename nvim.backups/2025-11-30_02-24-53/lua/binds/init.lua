-- ╓────────────────────────────────────────────────────────────╖
-- ║ Keybindings Initialization                                ║
-- ║ Load all keybinding modules                               ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}

M.setup = function()
	-- Load session keybindings
	local session_ok, session = pcall(require, "binds.session")
	if session_ok then
		session.setup()
	else
		vim.notify("Failed to load session keybindings", vim.log.levels.WARN)
	end

	-- Future keybinding modules will be loaded here:
	-- require("binds.leader").setup()
	-- require("binds.motion").setup()
	-- require("binds.lsp").setup()
	-- require("binds.git").setup()
	-- require("binds.which-key").setup()
end

return M