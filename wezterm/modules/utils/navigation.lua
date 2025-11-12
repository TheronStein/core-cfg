local wezterm = require("wezterm")

-- Helper function to check if a process is vim/nvim
local function is_vim(pane)
	local process_info = pane:get_foreground_process_info()
	if process_info == nil then
		return false
	end
	local process_name = process_info.name
	return process_name:find("n?vim") ~= nil
end

-- Helper function to check if a process is tmux
local function is_tmux(pane)
	local process_info = pane:get_foreground_process_info()
	if process_info == nil then
		return false
	end
	local process_name = process_info.name
	return process_name:find("tmux") ~= nil
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

-- Enhanced navigation that handles tmux/nvim/wezterm contextually
-- Hierarchy: nvim splits -> tmux panes -> wezterm panes
local function navigate_contextual(window, pane, key)
	local dir = direction_map[key]
	if not dir then
		return
	end

	-- If running tmux/vim, forward to them first (innermost layer)
	-- They will handle their own navigation and pass back if at edge
	if is_vim(pane) or is_tmux(pane) then
		window:perform_action({
			SendKey = { key = key, mods = "ALT" },
		}, pane)
	else
		-- Not in tmux/vim, navigate WezTerm panes directly
		window:perform_action({
			ActivatePaneDirection = dir.wez,
		}, pane)
	end
end

return {
	navigate_pane = navigate_pane,
	navigate_contextual = navigate_contextual,
}
