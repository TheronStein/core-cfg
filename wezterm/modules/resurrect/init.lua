local wezterm = require("wezterm") --[[@as Wezterm]] --- this type cast invokes the LSP module for Wezterm

local M = {}

--- checks if the user is on windows
-- local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
-- local separator = is_windows and "\\" or "/"

function M.setup()

local opts = { 
    auto = true,
}

-- Export submodules
	M.workspace_state = require("resurrect.workspace_state")
	M.window_state = require("resurrect.window_state")
  M.tab_state = require("resurrect.tab_state")
	M.fuzzy_loader = require("resurrect.fuzzy_loader")
	M.state_manager = require("resurrect.state_manager")
end

return M
