local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	{
		key = "C",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CopyTo("Clipboard"),
	},
	{
		key = "V",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		key = "Q",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "E",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(1),
	},

	{
		key = "C",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "X",
		mods = "LEADER",
		action = wezterm.action.CopyTo("Clipboard"),
	},
	{
		key = "V",
		mods = "LEADER",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		key = "V",
		mods = "LEADER",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

require("tabline_custom").setup(config)

-- Load event handlers
-- NOTE: Multiple update-status handlers will override each other!
-- Use unified handler instead of individual ones
require("events.update-status-unified").setup() -- Must be LAST to not be overridden
require("events.gui-startup").setup()
require("events.user-var").setup()

return config
