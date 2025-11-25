local wezterm = require("wezterm")
local math = require("utils.math")
local M = {}

M.separator_char = " ~ "

M.setup = function()
	wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
		-- Custom tab title formatting (active/inactive tabs with separators)
		-- local title_elements = tabline_tabs.set_title(tab, hover)
		-- if title_elements then
		-- 	return wezterm.format(title_elements)
		-- end
		-- -- Fallback to default if needed
		-- return tab.active_pane.title
	end)
end

return M
