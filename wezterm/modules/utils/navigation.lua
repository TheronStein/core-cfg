local wezterm = require("wezterm")

-- Helper function to check if foreground process is vim/nvim
local function is_vim(pane)
	local process_info = pane:get_foreground_process_info()
	if process_info == nil then
		return false
	end
	local process_name = process_info.name
	return process_name:find("n?vim") ~= nil
end

-- Helper function to check if we're running INSIDE a tmux session
-- Uses multiple detection methods for reliability
local function is_inside_tmux(pane)
	-- Method 1: Check user vars set by shell integration
	-- Requires: tmux set -g allow-passthrough on
	-- And shell integration that sets user vars
	local user_vars = pane:get_user_vars()
	if user_vars then
		-- Check for TMUX var (set by shell integration scripts)
		if user_vars.TMUX and user_vars.TMUX ~= "" then
			return true
		end
		-- Check for TMUX_SESSION (set by our custom tmux integration)
		if user_vars.TMUX_SESSION and user_vars.TMUX_SESSION ~= "" then
			return true
		end
		-- Check for WEZTERM_IN_TMUX (set by WezTerm shell integration)
		if user_vars.WEZTERM_IN_TMUX and user_vars.WEZTERM_IN_TMUX == "1" then
			return true
		end
	end

	-- Method 2: Check the pane's foreground process and its parent
	-- When inside tmux, the pane structure differs - the title often contains tmux info
	local title = pane:get_title()
	if title and title:find("tmux") then
		return true
	end

	-- Method 3: Check foreground process name
	-- This catches when tmux itself is the foreground (running tmux commands)
	local process_info = pane:get_foreground_process_info()
	if process_info then
		local process_name = process_info.name or ""
		if process_name:find("tmux") then
			return true
		end
		-- Check executable path
		local exe = process_info.executable or ""
		if exe:find("tmux") then
			return true
		end
	end

	return false
end

-- Legacy alias for compatibility
local function is_tmux(pane)
	return is_inside_tmux(pane)
end

local function navigate_pane(window, pane, direction_wez, direction_nvim)
	if is_vim(pane) then
		-- Send the navigation key to nvim, let nvim handle edge detection
		window:perform_action({
			SendKey = { key = direction_nvim, mods = "CTRL|SHIFT" },
		}, pane)
	else
		-- Not vim, just navigate normally in WezTerm
		window:perform_action({
			ActivatePaneDirection = direction_wez,
		}, pane)
	end
end

-- Map wsad to directions
local direction_map = {
	w = { wez = "Up", nvim = "I", tmux = "Up" },
	s = { wez = "Down", nvim = "K", tmux = "Down" },
	a = { wez = "Left", nvim = "J", tmux = "Left" },
	d = { wez = "Right", nvim = "L", tmux = "Right" },
}

-- CSI u escape sequences for Ctrl+Shift+key (same format Ghostty uses)
-- Format: ESC [ <codepoint> ; 6 u  (6 = Ctrl+Shift modifier)
local csi_u_sequences = {
	w = "\x1b[119;6u",  -- Ctrl+Shift+W
	a = "\x1b[97;6u",   -- Ctrl+Shift+A
	s = "\x1b[115;6u",  -- Ctrl+Shift+S
	d = "\x1b[100;6u",  -- Ctrl+Shift+D
}

-- Enhanced navigation that handles tmux/nvim/wezterm contextually
-- Hierarchy: nvim splits -> tmux panes -> wezterm panes
-- Uses Ctrl+Shift+W/A/S/D throughout all layers
--
-- Detection strategy:
-- 1. First check if we're inside tmux (using is_inside_tmux helper)
-- 2. Then check if vim is the foreground process
-- When inside tmux, forward CSI u sequences and let tmux handle navigation
local function navigate_contextual(window, pane, key)
	local dir = direction_map[key]
	if not dir then
		return
	end

	-- Detect if we're inside tmux (uses multiple detection methods)
	local in_tmux = is_inside_tmux(pane)

	-- Check foreground process for vim detection
	local in_vim = is_vim(pane)

	if in_tmux or in_vim then
		-- Forward CSI u sequence to tmux/vim
		-- tmux will handle further routing (to nvim or terminal-nav)
		local seq = csi_u_sequences[key]
		if seq then
			window:perform_action(wezterm.action.SendString(seq), pane)
		end
	else
		-- Not in tmux/vim - navigate WezTerm panes directly
		window:perform_action(wezterm.action.ActivatePaneDirection(dir.wez), pane)
	end
end

return {
	navigate_pane = navigate_pane,
	navigate_contextual = navigate_contextual,
}
