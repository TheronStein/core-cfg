-- Tab Metadata Browser
-- Shows FZF browser with all saved tab metadata

local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

local browser_script = paths.TAB_METADATA_BROWSER_SCRIPT

-- Show the tab metadata browser
function M.show_browser(window, pane)
	-- First capture current tabs
	local metadata_persistence = require("modules.tabs.tab_metadata_persistence")
	metadata_persistence.capture_all_tabs(window)

	-- Launch browser script
	window:perform_action(
		wezterm.action.SpawnCommandInNewTab({
			args = { "bash", browser_script },
		}),
		pane
	)
end

-- Capture all tabs manually (useful for initial setup)
function M.capture_all_tabs(window, pane)
	local metadata_persistence = require("modules.tabs.tab_metadata_persistence")
	metadata_persistence.capture_all_tabs(window)

	window:toast_notification(
		"Tab Metadata",
		"Captured metadata for all tabs",
		nil,
		2000
	)
end

return M
