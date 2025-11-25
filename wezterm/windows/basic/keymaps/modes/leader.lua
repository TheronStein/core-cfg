local wezterm = require("wezterm")
local keymode = require("keymaps.keymode")
local update_mode_display = require("keymaps.keymode").update_mode_display

local M = {}

function M.setup(config)
	keymode.create_mode("leader_mode", {
		{ key = "|", mods = "SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "z", action = wezterm.action.TogglePaneZoomState },
		{
			key = "Escape",
			action = wezterm.action_callback(function(window, pane)
				update_mode_display(window, "NORMAL")
				window:perform_action(wezterm.action.PopKeyTable, pane)
			end),
		},
	})
end

return M
