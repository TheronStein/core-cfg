local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- NOTE: The launcher menu and other InputSelector-based overlays don't have
-- official key_tables support like copy_mode and search_mode. However, WezTerm
-- allows you to define a launcher_mode key table that will be active when the
-- launcher is shown. We use SendKey to remap i/k to Up/Down arrows.

function M.setup(config)
	-- Initialize key_tables if not present
	config.key_tables = config.key_tables or {}

	-- The launcher_mode key table is used when ShowLauncher or ShowLauncherArgs is active
	config.key_tables.launcher_mode = {
		-- Navigate with i/k instead of default j/k
		{ key = "i", mods = "NONE", action = act.SendKey({ key = "UpArrow" }) },
		{ key = "k", mods = "NONE", action = act.SendKey({ key = "DownArrow" }) },

		-- Keep j for compatibility (maps to Up like i)
		{ key = "j", mods = "NONE", action = act.SendKey({ key = "UpArrow" }) },

		-- Allow l to accept/enter (standard launcher uses Enter)
		{ key = "l", mods = "NONE", action = act.SendKey({ key = "Enter" }) },

		-- Exit the launcher
		{ key = "Escape", mods = "NONE", action = act.SendKey({ key = "Escape" }) },
		{ key = "q", mods = "NONE", action = act.SendKey({ key = "Escape" }) },
		{ key = "c", mods = "CTRL", action = act.SendKey({ key = "Escape" }) },
	}
end

return M
