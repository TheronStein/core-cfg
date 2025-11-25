local wezterm = require("wezterm")
local keymode = require("keymaps.keymode")
local act = wezterm.action

local M = {}

function M.setup(config)
	keymode.create_mode("nav_panes", {
		-- Pane navigation
		{ key = "r", action = act.RotatePanes("Clockwise") },
		{ key = "R", action = act.RotatePanes("CounterClockwise") },
		{ key = "a", action = act.ActivatePaneDirection("Left") },
		{ key = "d", action = act.ActivatePaneDirection("Right") },
		{ key = "w", action = act.ActivatePaneDirection("Up") },
		{ key = "s", action = act.ActivatePaneDirection("Down") },
		{ key = "j", action = act.ActivatePaneDirection("Left") },
		{ key = "l", action = act.ActivatePaneDirection("Right") },
		{ key = "i", action = act.ActivatePaneDirection("Up") },
		{ key = "k", action = act.ActivatePaneDirection("Down") },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "C", mods = "CTRL", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
	})
end

return M
