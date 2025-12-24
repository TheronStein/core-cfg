local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.setup(config)
	-- Initialize key_tables if not present
	config.key_tables = config.key_tables or {}

	-- Add custom i/k navigation for search results
	config.key_tables.search_mode = {
		-- Navigate search results with i/k instead of up/down arrows
		{ key = "N", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },

		-- Page navigation (i/k for page, q/e for half-page)
		{ key = "i", mods = "CTRL", action = act.CopyMode("PriorMatchPage") },
		{ key = "k", mods = "CTRL", action = act.CopyMode("NextMatchPage") },
		{ key = "I", mods = "CTRL|SHIFT", action = act.CopyMode("PageUp") },
		{ key = "K", mods = "CTRL|SHIFT", action = act.CopyMode("PageDown") },

		-- Standard search mode actions
		{ key = "t", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "e", mods = "CTRL", action = act.CopyMode("EditPattern") },

		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
		{ key = "Enter", mods = "NONE", action = act.CopyMode("AcceptPattern") },
		-- Exit search mode
		{
			key = "Escape",
			mods = "NONE",
			action = wezterm.action_callback(function(window, pane)
				window:perform_action(act.CopyMode("Close"), pane)
				-- Sync border AFTER closing search mode
				local mode_colors = require("keymaps.mode-colors")
				mode_colors.sync_border_with_mode(window)
			end),
		},
		{
			key = "c",
			mods = "CTRL",
			action = wezterm.action_callback(function(window, pane)
				window:perform_action(act.CopyMode("Close"), pane)
				-- Sync border AFTER closing search mode
				local mode_colors = require("keymaps.mode-colors")
				mode_colors.sync_border_with_mode(window)
			end),
		},
	}
end

-- Append custom keys to the key table
-- 	for _, key in ipairs(custom_keys) do
-- 		table.insert(config.key_tables.search_mode, key)
-- 	end
-- end

return M
