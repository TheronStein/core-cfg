local wezterm = require("wezterm")

local M = {}

function M.setup(config)
	config.keys = config.keys or {}

	local keys = {
		--          ╭─────────────────────────────────────────────────────────╮
		--          │                       LITERALS                          │
		--          ╰─────────────────────────────────────────────────────────╯

		-- Nerd Fonts Picker
		-- {
		--    key = 'F9',
		--    mods = 'NONE',
		--    action = wezterm.action_callback(function(window, pane)
		--      require('nerdfonts_picker').show_picker(window, pane)
		--    end),
		--  },

		-- Make Ctrl+i distinct from Tab using CSI u format (more modern and widely supported)
		-- This sends the escape sequence in the format that applications can recognize
		-- CSI u format: \x1b[<keycode>;5u where 5 indicates Ctrl modifier
		-- Shift+Enter binding removed per user request
		-- { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },

		-- Debug Overlay
		-- { key = "CapsLock", mods = "NONE", action = wezterm.action.ShowDebugOverlay },
		-- { key = "Hyper", mods = "NONE", action = wezterm.action.ShowDebugOverlay },
		{ key = "F12", mods = "NONE", action = wezterm.action.ShowDebugOverlay },
		-- { key = "F1", mods = "HYPER", action = wezterm.action.ShowDebugOverlay },
		-- Send literal Ctrl+Tab when leader is pressed twice
		-- {
		--   key = 'LeftAlt',
		--   action = wezterm.action.DisableDefaultAssignment,
		-- },
		-- {
		--   key = 'RightAlt',
		--   action = wezterm.action.DisableDefaultAssignment,
		-- },
	}

	for _, key in ipairs(keys) do
		table.insert(config.keys, key)
	end
end

return M
