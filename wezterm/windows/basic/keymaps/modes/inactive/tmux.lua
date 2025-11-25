local wezterm = require("wezterm")
local keymode = require("keymaps.keymode")

local M = {}

function M.setup(config)
	keymode.create_mode("tmux_mode", {
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "c", mods = "CTRL", action = "PopKeyTable" },
	})
end

return M
