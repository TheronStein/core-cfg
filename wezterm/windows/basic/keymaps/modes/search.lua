local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.setup(config)
	-- Get the default search_mode key table
	local default_keys = wezterm.gui.default_key_tables()

	-- Initialize key_tables if not present
	config.key_tables = config.key_tables or {}

	-- Start with defaults (or empty if defaults not available)
	config.key_tables.search_mode = default_keys.search_mode or {}

	-- Add custom i/k navigation for search results
	local custom_keys = {
		-- Navigate search results with i/k instead of up/down arrows
		{ key = "i", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "k", mods = "NONE", action = act.CopyMode("NextMatch") },

		-- Page navigation
		{ key = "I", mods = "SHIFT", action = act.CopyMode("PriorMatchPage") },
		{ key = "K", mods = "SHIFT", action = act.CopyMode("NextMatchPage") },

		-- Standard search mode actions
		{ key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },

		-- Exit search mode
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
		{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },
	}

	-- Append custom keys to the key table
	for _, key in ipairs(custom_keys) do
		table.insert(config.key_tables.search_mode, key)
	end
end

return M
