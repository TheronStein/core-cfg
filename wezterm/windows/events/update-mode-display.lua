local wezterm = require("wezterm")
local M = {}

-- Update mode display (called when entering/exiting modes)
function M.update_mode_display(window, mode_name)
	local old_mode = wezterm.GLOBAL.current_mode or "CORE"

	-- Don't update if we're just showing leader temporarily
	if mode_name == "LEADER" and old_mode ~= "CORE" then
		return
	end

	wezterm.GLOBAL.current_mode = mode_name

	M.debug_log(
		"MODE_TRANSITIONS",
		string.format("Mode change: %s -> %s", old_mode, mode_name),
		{ old = old_mode, new = mode_name }
	)

	M.debug_notify(window, "NOTIFY_MODE_CHANGE", "MODE CHANGE", string.format("%s → %s", old_mode, mode_name), 1500)

	-- Force a status bar update
	if window then
		window:set_right_status("")
	end
end

return M
