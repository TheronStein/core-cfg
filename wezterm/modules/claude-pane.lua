--[[
  Toggle a dedicated Claude AI pane with tmux session management.
  - Creates a right-side pane attached to tmux session "ai"
  - Manages directory-aware tmux windows for Claude
  - Reuses existing Claude instances when possible
--]]

local M = {}

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local paths = require("utils.paths")

-- Configuration
local config = {
	direction = "Right",
	size = { Percent = 30 }, -- Fixed 30% of window width
	tmux_session = "ai",
	script_path = paths.WEZTERM_SCRIPTS .. "/claude-tmux-manager.sh",
}

-- State tracking for the claude pane per window
local claude_pane_states = {} -- { [window_id] = { pane_id = -1, invoker_id = -1, zoomed = false } }

-- Get or initialize state for a window
local function get_state(window)
	local key = window:window_id()
	if not claude_pane_states[key] then
		wezterm.log_info("Initializing claude-pane state for window: " .. tostring(key))
		claude_pane_states[key] = {
			pane_id = -1,
			invoker_id = -1,
			zoomed = false,
		}
	end
	return claude_pane_states[key]
end

-- Reset state
local function reset_state(state)
	state.pane_id = -1
	state.invoker_id = -1
	state.zoomed = false
end

-- Find the claude pane in the current window
local function find_claude_pane(window, pane_id)
	local mux_window = window:mux_window()
	for _, tab in ipairs(mux_window:tabs()) do
		for _, pane in ipairs(tab:panes()) do
			if pane:pane_id() == pane_id then
				return pane, tab
			end
		end
	end
	return nil, nil
end

-- Find the top-left pane (position 0,0) to split from
-- This ensures the Claude sidebar spans the full window height
local function find_topleft_pane(tab)
	local panes_with_info = tab:panes_with_info()
	if #panes_with_info == 0 then
		return nil
	end

	-- Find the pane at the top-left corner (index 0)
	-- In WezTerm, panes are indexed, and index 0 is typically top-left
	for _, pane_info in ipairs(panes_with_info) do
		if pane_info.index == 0 then
			return pane_info.pane
		end
	end

	-- Fallback: return the first pane
	return panes_with_info[1].pane
end

--[[
  Toggle the Claude pane.
  - If pane exists and is active: switch back to invoker
  - If pane exists but not active: activate it
  - If pane doesn't exist: create it with tmux
]]
function M.toggle_claude_pane(window, pane)
	local current_pane_id = pane:pane_id()
	local current_tab = pane:tab()
	local current_cwd = pane:get_current_working_dir()

	-- Extract just the path from file://hostname/path format
	local cwd_path = current_cwd and current_cwd.file_path or wezterm.home_dir

	wezterm.log_info("Toggle claude-pane: cwd = " .. cwd_path)

	local state = get_state(window)
	local claude_pane_obj = nil
	local claude_pane_exists = false

	-- Check if tracked pane still exists
	if state.pane_id ~= -1 then
		local success, result = pcall(mux.get_pane, state.pane_id)
		if success and result then
			claude_pane_obj = result
			claude_pane_exists = true
			wezterm.log_info("Found existing claude pane ID: " .. state.pane_id)
		else
			wezterm.log_info("Claude pane no longer exists. Resetting state.")
			reset_state(state)
		end
	end

	if claude_pane_exists then
		-- Pane exists: toggle between claude pane and invoker
		if current_pane_id == state.pane_id then
			-- Currently in claude pane: switch back to invoker
			wezterm.log_info("In claude pane. Switching to invoker.")

			local success, invoker_pane = pcall(mux.get_pane, state.invoker_id)
			if success and invoker_pane then
				-- Remember zoom state
				for _, pane_info in ipairs(current_tab:panes_with_info()) do
					if pane_info.pane:pane_id() == claude_pane_obj:pane_id() then
						state.zoomed = pane_info.is_zoomed
						break
					end
				end

				current_tab:set_zoomed(false)
				invoker_pane:activate()
			else
				wezterm.log_warn("Could not find invoker pane.")
			end
		else
			-- Not in claude pane: activate it and send directory command
			wezterm.log_info("Activating claude pane")

			state.invoker_id = current_pane_id
			current_tab:set_zoomed(false)
			claude_pane_obj:activate()

			-- Send command to switch/create tmux window for this directory
			claude_pane_obj:send_text(config.script_path .. " '" .. cwd_path .. "'\n")

			-- Restore zoom if it was zoomed before
			if state.zoomed then
				local claude_tab = claude_pane_obj:tab()
				claude_tab:set_zoomed(true)
			end
		end
	else
		-- Claude pane doesn't exist: create it as a right sidebar
		wezterm.log_info("Creating new claude pane as right sidebar")

		state.invoker_id = current_pane_id

		wezterm.log_info("Creating full-height sidebar using split_pane")

		-- Find the top-left pane (index 0) which should be at the root of the split tree
		local topleft_pane = find_topleft_pane(current_tab)
		if not topleft_pane then
			topleft_pane = pane
		end

		-- Extract percentage value from config.size table
		local size_fraction = 0.3 -- Default to 30%
		if config.size and config.size.Percent then
			size_fraction = config.size.Percent / 100.0
		end

		-- Use split_pane on the top-left pane
		local new_pane_obj = topleft_pane:split({
			direction = config.direction,
			size = size_fraction,
			command = {
				args = { "zsh", "-c", config.script_path .. " '" .. cwd_path .. "'" },
			},
		})

		-- Track the new pane
		if new_pane_obj then
			state.pane_id = new_pane_obj:pane_id()
			wezterm.log_info("Created claude pane ID: " .. state.pane_id)
			-- Activate the original invoker pane to return focus
			pane:activate()
		else
			wezterm.log_error("Failed to create claude pane")
			reset_state(state)
		end
	end
end

--[[
  Create the action callback for keybinding
]]
function M.create_action()
	return wezterm.action_callback(M.toggle_claude_pane)
end

return M
