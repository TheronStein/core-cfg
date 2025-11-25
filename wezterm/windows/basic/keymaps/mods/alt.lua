local wezterm = require("wezterm")
local act = wezterm.action
local navigation = require("modules.utils.navigation")
local M = {}
function M.setup(config)
	config.keys = config.keys or {}

	local keys = {
		--  ╭─────────────────────────────────────────────────────────╮
		--  │                         ALT                             │
		--  ╰─────────────────────────────────────────────────────────╯
		--    ┌ Keys:
		--    │
		--    │  w/s/a/d - Contextual pane navigation (tmux/nvim aware)
		--    │
		--    └

		-- Contextual navigation with Alt+w/s/a/d (tmux/nvim aware)
		{
			key = "w",
			mods = "ALT",
			desc = "Navigate up (context-aware)",
			action = wezterm.action_callback(function(window, pane)
				navigation.navigate_contextual(window, pane, "w")
			end),
		},
		{
			key = "s",
			mods = "ALT",
			desc = "Navigate down (context-aware)",
			action = wezterm.action_callback(function(window, pane)
				navigation.navigate_contextual(window, pane, "s")
			end),
		},
		{
			key = "a",
			mods = "ALT",
			desc = "Navigate left (context-aware)",
			action = wezterm.action_callback(function(window, pane)
				navigation.navigate_contextual(window, pane, "a")
			end),
		},
		{
			key = "d",
			mods = "ALT",
			desc = "Navigate right (context-aware)",
			action = wezterm.action_callback(function(window, pane)
				navigation.navigate_contextual(window, pane, "d")
			end),
		},
		{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
		--
		--
		--
		--  ╭─────────────────────────────────────────────────────────╮
		--  │                     ALT|SHIFT                           │
		--  ╰─────────────────────────────────────────────────────────╯
		--    ┌ Keys:
		--    │
		--    │
		--    │
		--    └

		-- { key = "e", mods = "ALT|SHIFT", action = act.MoveTabRelative(1) },
		-- { key = "q", mods = "ALT|SHIFT", action = act.MoveTabRelative(-1) },
	}

	for _, key in ipairs(keys) do
		table.insert(config.keys, key)
	end
end

return M
