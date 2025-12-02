local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

function M.setup()
	--
	-- Track window counter for unique IDs
	wezterm.GLOBAL.window_counter = wezterm.GLOBAL.window_counter or 0

	-- Handle gui-startup event
	wezterm.on("gui-startup", function(cmd) end)
end

return M
