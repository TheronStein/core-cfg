local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.setup(config)
	-- Initialize key_tables if not present
	config.key_tables = config.key_tables or {}

	-- Add custom i/k/j/l navigation bindings
	config.key_tables.copy_mode = {
		-- Navigation with i/k/j/l (replacing h/j/k/l vim defaults)
		{ key = "i", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "k", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "j", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },

		-- Page navigation with Ctrl+i/k
		{ key = "i", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
		{ key = "k", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
		{ key = "I", mods = "CTRL|SHIFT", action = act.CopyMode("PageUp") },
		{ key = "K", mods = "CTRL|SHIFT", action = act.CopyMode("PageDown") },

		-- Selection modes
		{ key = "a", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
		{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Block" }) },
		{ key = "W", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Word" }) },

		-- Scrollback navigation
		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },

		-- Viewport navigation
		{ key = "t", mods = "CTRL", action = act.CopyMode("MoveToViewportTop") },
		{ key = "m", mods = "CTRL", action = act.CopyMode("MoveToViewportMiddle") },
		{ key = "b", mods = "CTRL", action = act.CopyMode("MoveToViewportBottom") },

		-- Word movement with Ctrl+j/l (replacing Ctrl+b/w)
		{ key = "j", mods = "CTRL", action = act.CopyMode("MoveBackwardWord") },
		{ key = "l", mods = "CTRL", action = act.CopyMode("MoveForwardWord") },

		-- Line navigation
		{ key = "J", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLine") },
		{ key = "j", mods = "CTRL|SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
		{ key = "L", mods = "CTRL|SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },

		-- Selection other end
		{ key = "o", mods = "CTRL", action = act.CopyMode("MoveToSelectionOtherEnd") },
		{ key = "O", mods = "CTRL|SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },

		-- Search within copy mode
		{ key = "/", mods = "NONE", action = act.CopyMode("EditPattern") },
		{ key = "?", mods = "SHIFT", action = act.CopyMode("EditPattern") },

		-- Jump commands
		-- { key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
		-- { key = "n", mods = "ALT", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "n", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "N", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },

		-- Copy and exit
		{
			key = "y",
			mods = "NONE",
			action = act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				"ScrollToBottom",
				{ CopyMode = "Close" },
			}),
		},
		-- Copy and exit
		{
			key = "Enter",
			mods = "NONE",
			action = act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				"ScrollToBottom",
				{ CopyMode = "Close" },
			}),
		},

		-- Copy and exit
		{
			key = "Space",
			mods = "NONE",
			action = act.Multiple({
				{ CopyTo = "ClipboardAndPrimarySelection" },
				"ScrollToBottom",
				{ CopyMode = "Close" },
			}),
		},
		-- Exit bindings
		{
			key = "Escape",
			mods = "NONE",
			action = act.Multiple({
				"ScrollToBottom",
				{ CopyMode = "Close" },
			}),
		},
		{
			key = "q",
			mods = "NONE",
			action = act.Multiple({
				"ScrollToBottom",
				{ CopyMode = "Close" },
			}),
		},
		{
			key = "c",
			mods = "CTRL",
			action = act.Multiple({
				"ScrollToBottom",
				{ CopyMode = "Close" },
			}),
		},
	}
end
-- 	-- Append custom keys to the key table
-- 	for _, key in ipairs(custom_keys) do
-- 		table.insert(config.key_tables.copy_mode, key)
-- 	end
-- end

return M
