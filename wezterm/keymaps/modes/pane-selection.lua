local wezterm = require("wezterm")
local act = wezterm.action
local keymode = require("keymaps.keymode")
local M = {}

function M.setup(config)
	-- Selection mode: Navigate/focus panes with hjkl, confirm with Enter/Space to adjusting
	keymode.create_mode("pane_selection_mode", {
			{ key = "UpArrow", mods = "SUPER", action = act.ScrollByPage(-1) },
			{ key = "DownArrow", mods = "SUPER", action = act.ScrollByPage(1) },
			-- Navigation: Focus adjacent pane
			{ key = "h", mods = "NONE", action = act.ActivatePaneDirection("Left") },
			{ key = "j", mods = "NONE", action = wezterm.action.ActivatePaneDirection("Down") },
			{ key = "k", mods = "NONE", action = wezterm.action.ActivatePaneDirection("Up") },
			{ key = "l", mods = "NONE", action = wezterm.action.ActivatePaneDirection("Right") },

			-- Confirm and switch to adjusting (persistent)
			{
				key = "Enter",
				mods = "NONE",
				action = wezterm.action.ActivateKeyTable({
					name = "pane_mode",
					one_shot = false,
				}),
			},
			{
				key = "Space",
				mods = "NONE",
				action = wezterm.action.ActivateKeyTable({
					name = "pane_mode",
					one_shot = false,
				}),
			},
	})
end

return M
