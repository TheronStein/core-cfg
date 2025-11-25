local wezterm = require("wezterm")
local act = wezterm.action
local keymode = require("keymaps.keymode")

local M = {}

function M.setup(config)
	keymode.create_mode("alt_mode", {

		{ key = "w", action = act.ActivatePaneDirection("Up") },
		{ key = "s", action = act.ActivatePaneDirection("Down") },
		{ key = "a", action = act.ActivatePaneDirection("Left") },
		{ key = "d", action = act.ActivatePaneDirection("Right") },

		{ key = "e", mods = "SHIFT", action = act.MoveTabRelative(1) },
		{ key = "q", mods = "SHIFT", action = act.MoveTabRelative(-1) },

		-- Rotate panes in current tab
		{ key = "r", action = wezterm.action.RotatePanes("Clockwise") },
		{ key = "R", action = wezterm.action.RotatePanes("CounterClockwise") },

		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "c", mods = "CTRL", action = "PopKeyTable" },
	})
end

return M
