local wezterm = require("wezterm")
local keymode = require("keymaps.keymode")

local M = {}

function M.setup(config)
	keymode.create_mode("ctrl_mode", {

		-- Rotate panes in current tab
		{ key = "e", action = wezterm.action.RotatePanes("Clockwise") },
		{ key = "q", action = wezterm.action.RotatePanes("CounterClockwise") },

		-- Only add toggle terminal binding if module is loaded
		-- NOTE: Commented out - toggle_terminal bindings are now configured in config/binds.lua
		-- if toggle_terminal then
		-- 	table.insert(keys, {
		-- 		key = ";",

		-- 		action = wezterm.action_callback(toggle_terminal.create("leader", {
		-- 			direction = "Right",
		-- 			size = { Percent = 50 },
		-- 			launch_command = nil, -- default shell
		-- 			global_across_windows = true,
		-- 		})),
		-- 	})
		-- end

		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q", action = "PopKeyTable" },
		{ key = "c", mods = "CTRL", action = "PopKeyTable" },
	})
end

return M
