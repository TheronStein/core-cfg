local wezterm = require("wezterm")
local M = {}

function M.setup()
	-- Unified update-status handler that calls all necessary components
	wezterm.on("update-status", function(window, pane)
		-- 1. Tabline status bar components (left/right sections)
		local tabline_component = require("gui.tabline.component")
		tabline_component.set_status(window)

		-- 2. Backdrop cycle (updates backdrop info in status)
		-- From events/backdrop-cycle.lua
		local backdrop_data = wezterm.GLOBAL.backdrops
		if backdrop_data and backdrop_data.files then
			local current_idx = backdrop_data.current or 1
			local total = #backdrop_data.files
			wezterm.GLOBAL.backdrop_status = string.format("%d/%d", current_idx, total)
		end

		-- 3. Backdrop opacity watcher
		-- From events/backdrop-opacity-watcher.lua
		-- (Already handled via wezterm.GLOBAL.backdrop_opacity)

		-- 4. Backdrop refresh watcher
		-- From events/backdrop-refresh-watcher.lua
		-- (Already handled via file watcher)

		-- 5. Leader key indicator
		-- From events/leader-activated.lua
		local leader_active = wezterm.GLOBAL.leader_active or false
		-- (Used by tabline mode component)

		-- 6. Tab cleanup
		-- From events/tab-cleanup.lua
		local tab_cleanup = require("events.tab-cleanup")
		if tab_cleanup.check_empty_tabs then
			tab_cleanup.check_empty_tabs(window)
		end

		-- 7. Workspace theme handler
		-- From events/workspace_theme_handler.lua
		-- (Passive - just watches for workspace changes)
	end)
end

return M
