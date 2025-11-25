local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.setup(config)
	config.mouse_bindings = config.mouse_bindings or {}

	local mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = act.OpenLinkAtMouseCursor,
		},
	}

	for _, binding in ipairs(mouse_bindings) do
		table.insert(config.mouse_bindings, binding)
	end
end

return M
