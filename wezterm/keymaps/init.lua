-- ~/.core/.sys/configs/wezterm/util/keymaps.lua
-- Modal keymap configuration with specialized contexts

local wezterm = require("wezterm")
local M = {}

M.key_groups = {
	"keymaps.keys",
	"keymaps.modes",
	"keymaps.mouse",
	"keymaps.mods.shift",
	"keymaps.mods.super",
	"keymaps.mods.ctrl",
	"keymaps.mods.alt",
	"keymaps.mods.leader",
	"keymaps.mods.context", -- Context-aware keybindings for WezTerm/tmux toggle
	"keymaps.modes.ctrl",  -- CRITICAL: Load ctrl mode key table definitions
	"keymaps.modes.alt",   -- CRITICAL: Load alt mode key table definitions
	"keymaps.modes.resize",
	"keymaps.modes.panes",
	"keymaps.modes.pane-selection",
	"keymaps.modes.copy",
	"keymaps.modes.search",
	"keymaps.modes.launcher",
	-- "keymaps.modes.leader",
	-- "keymaps.modes.super",
	-- "keymaps.modes.hyper",
	-- "keymaps.modes.tmux",
	-- "keymaps.modes.wezterm",
}

-- Set leader key configuration
function M.set_leader(config)
	config.leader = { key = "Space", mods = "SUPER", timeout_milliseconds = 1000 }
	-- config.leader = { key = "Tab", mods = "CTRL", timeout_milliseconds = 1000 }
end

-- Build keymaps (called from main config)
function M.assign_keys(config)
	config.keys = config.keys or {}
end

function M.setup(config)
	config = config or {}

	local debug_config = require('config.debug')

	for _, group in ipairs(M.key_groups) do
		local ok, mod = pcall(require, group)
		if ok then
			if mod and type(mod.setup) == "function" then
				if debug_config.is_enabled('debug_keymaps_groups') then
					wezterm.log_info("Setting up keymaps group: " .. group)
				end
				local setup_ok, setup_err = pcall(mod.setup, config)
				if not setup_ok then
					wezterm.log_error("Failed to setup keymaps group " .. group .. ": " .. tostring(setup_err))
				end
			else
				wezterm.log_error("Keymaps group " .. group .. " doesn't have setup function, type: " .. type(mod))
			end
		else
			wezterm.log_error("Failed to load keymaps group " .. group .. ": " .. tostring(mod))
		end
	end
	M.set_leader(config)
	M.assign_keys(config)

	-- Load and setup keymode last to apply all key tables
	local ok, keymode = pcall(require, "keymaps.keymode")
	if ok and keymode and type(keymode.setup) == "function" then
		if debug_config.is_enabled('debug_keymaps_init') then
			wezterm.log_info("Setting up keymode")
		end
		local setup_ok, setup_err = pcall(keymode.setup, config)
		if not setup_ok then
			wezterm.log_error("Failed to setup keymode: " .. tostring(setup_err))
		end
	else
		wezterm.log_error("Failed to load keymaps.keymode: " .. tostring(keymode))
	end

	return config
end

-- -- Merge with existing keys
--
-- for _, key in ipairs(leader_keys) do
--   table.insert(config.keys, key)
-- end

return M
