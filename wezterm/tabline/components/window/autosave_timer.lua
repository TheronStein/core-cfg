local wezterm = require("wezterm")

-- Format seconds as MM:SS
local function format_time(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%d:%02d", minutes, secs)
end

return {
	default_opts = {
		icon = "󰄀", -- Save icon
	},
	update = function(window, opts)
		local workspace_name = wezterm.mux.get_active_workspace()

		-- Get auto-save module
		local ok, auto_save = pcall(require, "events.workspace-auto-save")
		if not ok then
			return nil
		end

		-- Get time until next save
		local remaining = auto_save.get_time_until_save(workspace_name)
		if not remaining then
			-- Auto-save not active for this workspace
			return nil
		end

		-- Format and return
		return format_time(remaining)
	end,
}
