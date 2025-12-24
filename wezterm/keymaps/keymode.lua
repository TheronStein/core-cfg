local wezterm = require("wezterm")
-- local debugger = require("modules.debugger")  -- Not used, commented out
local M = {}
M.leader_modes = {}

-- Get the current context mode (wezterm_mode or tmux_mode)
local function get_context_mode()
	local context = wezterm.GLOBAL.leader_context or "wezterm"
	return context == "tmux" and "tmux_mode" or "wezterm_mode"
end

-- Function to exit mode and return to context mode (wezterm_mode or tmux_mode)
function M.create_exit_action()
	return wezterm.action_callback(function(window, pane)
		window:perform_action(wezterm.action.PopKeyTable, pane)
		-- Sync border color and trigger status update
		local ok, mode_colors = pcall(require, "keymaps.mode-colors")
		if ok then
			mode_colors.sync_border_with_mode(window)
		end
		-- Update mode display to context mode
		M.update_mode_display(window, get_context_mode())
	end)
end

function M.build_exit_keys()
	return {
		{ key = "Escape", mods = "NONE", action = M.create_exit_action() },
		{ key = "q", mods = "NONE", action = M.create_exit_action() },
		{ key = "c", mods = "CTRL", action = M.create_exit_action() },
	}
end

function M.create_mode(name, bindings)
	M.leader_modes[name] = {}
	-- Add all the bindings first
	for _, bind in ipairs(bindings) do
		table.insert(M.leader_modes[name], bind)
	end
	-- Then add exit keys at the end
	for _, exit_key in ipairs(M.build_exit_keys()) do
		table.insert(M.leader_modes[name], exit_key)
	end
end

-- Apply key tables to config
function M.apply_key_tables(config)
	-- Preserve existing key tables (like copy_mode, search_mode, launcher_mode)
	-- which are managed in their respective module files
	config.key_tables = config.key_tables or {}
	for name, table in pairs(M.key_tables) do
		config.key_tables[name] = table
	end
end

function M.setup(config)
	-- Define key tables for different modes
	-- NOTE: copy_mode, search_mode, and launcher_mode are now managed directly
	-- in their respective module files since they extend WezTerm's built-in modes
	M.key_tables = {
		-- wez_mode = M.leader_modes["wez_mode"] or {},
		-- tmux_mode = M.leader_modes["tmux_mode"] or {},
		ctrl_mode = M.leader_modes["ctrl_mode"] or {},
		alt_mode = M.leader_modes["alt_mode"] or {},
		-- hyper_mode = M.leader_modes["hyper_mode"] or {},
		super_mode = M.leader_modes["super_mode"] or {},
		-- zsh_mode = M.leader_modes["zsh_mode"] or {},
		-- leader_mode = M.leader_modes["leader_mode"] or {},
		pane_mode = M.leader_modes["pane_mode"] or {},
		-- neovim_mode = M.leader_modes["neovim_mode"] or {},
		resize_mode = M.leader_modes["resize_mode"] or {},
		nav_panes = M.leader_modes["nav_panes"] or {},
		pane_selection_mode = M.leader_modes["pane_selection_mode"] or {},
	}

	-- Apply key tables to config
	M.apply_key_tables(config)
end

-- Initialize GLOBAL state (default to wezterm_mode, context detection will update if needed)
wezterm.GLOBAL.current_mode = wezterm.GLOBAL.current_mode or "wezterm_mode"
wezterm.GLOBAL.leader_active = wezterm.GLOBAL.leader_active or false

-- Public function to get current mode
function M.get_current_mode()
	return wezterm.GLOBAL.current_mode
end

-- Function to update mode and refresh tabline
function M.update_mode_display(window, mode_name)
	wezterm.GLOBAL.current_mode = mode_name
	-- Force an immediate status update by emitting the update-status event
	wezterm.emit("update-status", window, window:active_pane())
end

return M
