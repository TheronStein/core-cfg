local wezterm = require('wezterm')

return {
	default_opts = {},
	update = function(window, opts)
		-- Return empty string - the tabline system will handle spacing
		-- This component just acts as a flexible spacer
		return ""
	end,
}
