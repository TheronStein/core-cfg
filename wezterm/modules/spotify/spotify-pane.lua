local M = {}

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- Default configuration for toggleable panes
local default_opts = {
	direction = "Right", -- Direction to split the pane
	size = { Percent = 50 }, -- Size of the split pane
	launch_command = nil, -- Command to run on first launch (nil = default shell)
	global_across_windows = false, -- If true, share the same terminal across ALL windows
	zoom = {
		auto_zoom_toggle_terminal = false, -- Automatically zoom toggle terminal pane
		auto_zoom_invoker_pane = false, -- Automatically zoom invoker pane
		remember_zoomed = true, -- Re-zoom the toggle pane if it was zoomed before switching away
	},
}

local session_states = {} -- { [session_id] = { [window_id] = { pane_id = -1, invoker_id = -1, invoker_tab_id = -1, zoomed = false }, ... }, ... }

-- Get state key based on configuration
local function get_state_key(window, opts)
	if opts.global_across_windows then
		return "global"
	else
		return window:window_id()
	end
end

-- Get or initialize state for a session and window
local function get_session_state(session_id, window, opts)
	-- Initialize session storage if needed
	if not session_states[session_id] then
		session_states[session_id] = {}
	end

	local key = get_state_key(window, opts)
	if not session_states[session_id][key] then
		wezterm.log_info("Initializing toggle_terminal state for session: " .. session_id .. ", key: " .. tostring(key))
		session_states[session_id][key] = {
			pane_id = -1,
			invoker_id = -1,
			invoker_tab_id = -1,
			zoomed = false,
		}
	end
	return session_states[session_id][key]
end

--- Resets the state
local function reset_window_state(state)
	state.pane_id = -1
	state.invoker_id = -1
	state.invoker_tab_id = -1
	state.zoomed = false
end

-- Find the terminal pane in any tab of the current window
local function find_spotify_pane_in_window(window, terminal_pane_id)
	local mux_window = window:mux_window()
	for _, tab in ipairs(mux_window:tabs()) do
		for _, pane in ipairs(tab:panes()) do
			if pane:pane_id() == terminal_pane_id then
				return pane, tab
			end
		end
	end
	return nil, nil
end

local function toggle_terminal_session(session_id, opts, window, pane)
	-- Merge with defaults
	opts = opts or default_opts
	local config = {}
	for k, v in pairs(default_opts) do
		if type(v) == "table" then
			config[k] = {}
			for k2, v2 in pairs(v) do
				config[k][k2] = (opts[k] and opts[k][k2]) or v2
			end
		else
			config[k] = opts[k] or v
		end
	end

	local current_pane_id = pane:pane_id()
	local current_tab_obj = pane:tab()
	local current_tab_id = current_tab_obj:tab_id()

	wezterm.log_info("Toggle terminal [" .. session_id .. "] action triggered in tab_id: " .. current_tab_id)

	-- Get state for this session and window (or global)
	local state = get_session_state(session_id, window, config)

	local spotify_pane_obj = nil
	local spotify_pane_exists = false
	local spotify_tab = nil

	-- Safely check if the tracked pane ID exists
	if state.pane_id ~= -1 then
		local success, result = pcall(mux.get_pane, state.pane_id)
		if success and result then
			terminal_pane_obj = result
			terminal_pane_exists = true
			-- Find which tab it's in
			_, terminal_tab = find_terminal_pane_in_window(window, state.pane_id)
			wezterm.log_info("Found existing terminal pane ID: " .. state.pane_id)
		else
			-- Pane closed or pcall failed
			wezterm.log_info("Terminal pane ID " .. tostring(state.pane_id) .. " no longer exists. Resetting state.")
			reset_window_state(state)
		end
	end

	-- Determine behavior based on pane existence and focus
	if terminal_pane_exists then
		-- Check if we're currently in the terminal pane
		if current_pane_id == state.pane_id then
			-- Currently in terminal: switch back to invoker
			wezterm.log_info("In terminal pane. Switching to invoker: " .. tostring(state.invoker_id))

			local success_activate, invoker_pane = pcall(mux.get_pane, state.invoker_id)
			if success_activate and invoker_pane then
				-- Remember zoom state
				if config.zoom.remember_zoomed and terminal_pane_obj then
					for _, pane_with_info in ipairs(current_tab_obj:panes_with_info()) do
						if pane_with_info.pane:pane_id() == terminal_pane_obj:pane_id() then
							state.zoomed = pane_with_info.is_zoomed
							break
						end
					end
				end

				-- Unzoom before switching
				current_tab_obj:set_zoomed(false)

				-- Activate invoker (might be in a different tab)
				invoker_pane:activate()

				-- Optionally zoom invoker
				if config.zoom.auto_zoom_invoker_pane then
					local invoker_tab = invoker_pane:tab()
					invoker_tab:set_zoomed(true)
				end
			else
				wezterm.log_warn("Could not find invoker pane. Staying in terminal.")
			end
		else
			-- Not in terminal: activate it (move to current tab if needed)
			wezterm.log_info("Activating terminal pane")

			-- Track this pane as the new invoker
			state.invoker_id = current_pane_id
			state.invoker_tab_id = current_tab_id

			-- Check if terminal is in current tab or needs to be moved
			if terminal_tab and terminal_tab:tab_id() ~= current_tab_id then
				wezterm.log_info("Terminal is in a different tab. Moving it to current tab.")

				-- Move the terminal pane to current tab
				-- WezTerm doesn't have a direct "move pane to tab" API, so we need to:
				-- 1. Activate the terminal in its current tab
				-- 2. Use ActivatePaneDirection or similar to bring it to focus
				-- Actually, let's just activate it where it is for simplicity
				terminal_pane_obj:activate()
			else
				-- Terminal is in current tab, just activate it
				current_tab_obj:set_zoomed(false)
				terminal_pane_obj:activate()
			end

			-- Apply zoom settings
			if (state.zoomed and config.zoom.remember_zoomed) or config.zoom.auto_zoom_toggle_terminal then
				local term_tab = terminal_pane_obj:tab()
				term_tab:set_zoomed(true)
			end
		end
	else
		-- Terminal doesn't exist: create it
		wezterm.log_info("Terminal pane not found. Creating a new one.")

		-- Track the invoker
		state.invoker_id = current_pane_id
		state.invoker_tab_id = current_tab_id

		-- Split to create terminal pane
		local split_args = {
			direction = config.direction,
			size = config.size,
		}

		-- Add command if specified
		if config.launch_command then
			split_args.command = { args = { config.launch_command } }
		end

		window:perform_action(act.SplitPane(split_args), pane)

		-- Get the newly created pane
		local new_pane = window:active_pane()
		if new_pane then
			state.pane_id = new_pane:pane_id()
			wezterm.log_info(
				"Created new terminal pane ["
					.. session_id
					.. "]. ID: "
					.. state.pane_id
					.. ", Invoker ID: "
					.. state.invoker_id
			)

			-- Optionally zoom the new terminal
			if config.zoom.auto_zoom_toggle_terminal then
				current_tab_obj:set_zoomed(true)
			end
		else
			wezterm.log_error("Failed to create terminal pane [" .. session_id .. "]")
			reset_window_state(state)
		end
	end
end

function M.create(session_id, opts)
	return function(window, pane)
		toggle_spotfiy(session_id, opts, window, pane)
	end
end

-- Backward compatibility: default toggle_terminal function
function M.toggle_spotfiy(window, pane)
	toggle_spotify("default", default_opts, window, pane)
end

return M
