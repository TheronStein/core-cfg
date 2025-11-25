local wezterm = require("wezterm")
local keymode = require("keymaps.keymode")
local act = wezterm.action
local M = {}

function M.setup(config)
	keymode.create_mode("resize_mode", {
			{ key = "j", action = act.ActivatePaneDirection("Left") },
			{ key = "l", action = act.ActivatePaneDirection("Right") },
			{ key = "i", action = act.ActivatePaneDirection("Up") },
			{ key = "k", action = act.ActivatePaneDirection("Down") },
			{ key = "a", action = act.AdjustPaneSize({ "Left", 5 }) },
			{ key = "d", action = act.AdjustPaneSize({ "Right", 5 }) },
			{ key = "w", action = act.AdjustPaneSize({ "Up", 5 }) },
			{ key = "s", action = act.AdjustPaneSize({ "Down", 5 }) },
			{ key = "a", mods = "CTRL", action = act.AdjustPaneSize({ "Left", 2 }) },
			{ key = "d", mods = "CTRL", action = act.AdjustPaneSize({ "Right", 2 }) },
			{ key = "w", mods = "CTRL", action = act.AdjustPaneSize({ "Up", 2 }) },
			{ key = "s", mods = "CTRL", action = act.AdjustPaneSize({ "Down", 2 }) },
			{ key = "a", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 10 }) },
			{ key = "d", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 10 }) },
			{ key = "w", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 10 }) },
			{ key = "s", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 10 }) },
			{ key = "b", mods = "NONE", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
			{ key = "v", mods = "NONE", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
			{ key = "x", mods = "NONE", action = act.CloseCurrentPane({ confirm = false }) },
			{ key = "Escape", action = "PopKeyTable" },
			{ key = "C", mods = "CTRL", action = "PopKeyTable" },
			{ key = "q", action = "PopKeyTable" },
	})
end

return M
