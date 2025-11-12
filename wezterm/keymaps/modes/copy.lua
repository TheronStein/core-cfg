local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.setup(config)
	-- Get the default copy_mode key table
	local default_keys = wezterm.gui.default_key_tables()

	-- Initialize key_tables if not present
	config.key_tables = config.key_tables or {}

	-- Start with defaults (or empty if defaults not available)
	config.key_tables.copy_mode = default_keys.copy_mode or {}

	-- Add custom i/k/j/l navigation bindings
	local custom_keys = {
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
		{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },

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

		-- Jump commands
		{ key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "n", mods = "ALT", action = act.CopyMode("MoveToStartOfNextLine") },
		{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
		{ key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },

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

	-- Append custom keys to the key table
	for _, key in ipairs(custom_keys) do
		table.insert(config.key_tables.copy_mode, key)
	end
end

return M
