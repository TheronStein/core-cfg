local wezterm = require("wezterm")

local M = {}

M.get_github_user = function(show_icons)
	local icon = show_icons and "  " or "" -- nf-fa-github

	-- Run gh auth status command
	local success, stdout, stderr = wezterm.run_child_process({
		"bash",
		"-c",
		"gh auth status 2>&1 | grep -B1 'Active account: true' | head -n 1 | awk '{for(i=1;i<=NF;i++) if($i==\"account\") print $(i+1)}'",
	})

	if not success or not stdout or stdout == "" then
		-- Not logged in
		return icon .. "Not logged in"
	end

	-- Clean up the username (remove whitespace/newlines)
	local username = stdout:gsub("%s+", "")

	if username == "" then
		return icon .. "Not logged in"
	end

	return icon .. username
end

return {
	default_opts = {
		show_icons = true,
	},
	update = function(window, opts)
		-- Enable bold attribute for github username
		opts.attribute = { Intensity = 'Bold' }

		-- Set icon to the right with GitHub icon
		if opts.icons_enabled then
			opts.icon = { "  ", align = "right" }
		end

		return M.get_github_user()
	end,
}
