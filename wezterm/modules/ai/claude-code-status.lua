-- ~/.core/.sys/cfg/wezterm/modules/ai/claude-code-status.lua
-- Claude Code Status Indicator System for WezTerm
-- Provides dynamic tab title icons based on Claude Code session state
--
-- State-Based Icons (Material Design Robot icons via Nerd Fonts):
--   - md_robot          : Default/active state (Claude Code session detected)
--   - md_robot_dead_outline : Busy state (Claude Code performing actions)
--   - md_robot_confused : Waiting for user input
--   - md_robot_happy    : Task completed successfully
--
-- Icon Lifecycle:
--   - Appears when Claude Code session detected in a pane
--   - Changes based on state transitions (via user vars or process monitoring)
--   - Resets to md_robot when user navigates back to the tab
--   - Disappears when Claude Code session ends

local wezterm = require("wezterm")
local debug_config = require("config.debug")

local M = {}

-- ============================================================================
-- ICON DEFINITIONS (Material Design Robot Icons)
-- ============================================================================
-- Using wezterm.nerdfonts for consistent icon access
M.ICONS = {
	-- Default state: Claude Code session is active
	active = wezterm.nerdfonts.md_robot or "",

	-- Busy state: Claude Code is performing actions (tool use, thinking)
	busy = wezterm.nerdfonts.md_robot_dead_outline or "",

	-- Waiting state: Claude Code is waiting for user input
	waiting = wezterm.nerdfonts.md_robot_confused or "",

	-- Complete state: Claude Code finished a step/task successfully
	complete = wezterm.nerdfonts.md_robot_happy or "",

	-- Error state: Claude Code encountered an error (optional)
	error = wezterm.nerdfonts.md_robot_angry_outline or "",
}

-- State enum for type safety and clarity
M.STATE = {
	NONE = "none", -- No Claude Code session
	ACTIVE = "active", -- Session active, idle
	BUSY = "busy", -- Performing action
	WAITING = "waiting", -- Waiting for user input
	COMPLETE = "complete", -- Task completed
	ERROR = "error", -- Error occurred
}

-- ============================================================================
-- STATE STORAGE
-- ============================================================================
-- State is stored per pane_id in wezterm.GLOBAL to persist across events
-- Structure: wezterm.GLOBAL.claude_code_state[pane_id] = { state, last_update, ... }

local function ensure_global_state()
	if not wezterm.GLOBAL.claude_code_state then
		wezterm.GLOBAL.claude_code_state = {}
	end
	if not wezterm.GLOBAL.claude_code_tab_visited then
		wezterm.GLOBAL.claude_code_tab_visited = {}
	end
end

-- Get Claude Code state for a pane
function M.get_pane_state(pane_id)
	ensure_global_state()
	local state_data = wezterm.GLOBAL.claude_code_state[tostring(pane_id)]
	if state_data then
		return state_data.state
	end
	return M.STATE.NONE
end

-- Set Claude Code state for a pane
function M.set_pane_state(pane_id, state)
	ensure_global_state()
	local pane_id_str = tostring(pane_id)

	if state == M.STATE.NONE then
		-- Remove state entry when session ends
		wezterm.GLOBAL.claude_code_state[pane_id_str] = nil
		if debug_config.is_enabled("debug_mods_claude_code") then
			wezterm.log_info("[CLAUDE_CODE] Removed state for pane " .. pane_id_str)
		end
	else
		wezterm.GLOBAL.claude_code_state[pane_id_str] = {
			state = state,
			last_update = os.time(),
		}
		if debug_config.is_enabled("debug_mods_claude_code") then
			wezterm.log_info("[CLAUDE_CODE] Set state for pane " .. pane_id_str .. ": " .. state)
		end
	end
end

-- Get the icon for a given state
function M.get_icon_for_state(state)
	if state == M.STATE.ACTIVE then
		return M.ICONS.active
	elseif state == M.STATE.BUSY then
		return M.ICONS.busy
	elseif state == M.STATE.WAITING then
		return M.ICONS.waiting
	elseif state == M.STATE.COMPLETE then
		return M.ICONS.complete
	elseif state == M.STATE.ERROR then
		return M.ICONS.error
	end
	return nil
end

-- ============================================================================
-- PROCESS DETECTION
-- ============================================================================
-- Claude Code runs as a Node.js process with specific patterns

-- Check if a process name indicates Claude Code
function M.is_claude_code_process(process_name)
	if not process_name or process_name == "" then
		return false
	end

	-- Claude Code appears as "claude" in the process list
	local basename = process_name:match("([^/]+)$") or process_name

	-- Direct match for "claude" binary
	if basename == "claude" then
		return true
	end

	-- Also check for node processes that might be Claude
	-- (Claude Code runs via Node.js in some configurations)
	if basename == "node" or basename == "nodejs" then
		-- Additional heuristics could be added here by checking
		-- the pane's user_vars or environment
		return false -- Be conservative, rely on user vars
	end

	return false
end

-- Detect Claude Code in a pane (direct method)
function M.detect_claude_in_pane(pane)
	local process_name = pane:get_foreground_process_name()
	return M.is_claude_code_process(process_name)
end

-- Get Claude Code icon for a pane (returns nil if no Claude Code)
function M.get_pane_icon(pane)
	local pane_id = pane:pane_id()
	local state = M.get_pane_state(pane_id)

	-- If we have a stored state, use it
	if state ~= M.STATE.NONE then
		return M.get_icon_for_state(state)
	end

	-- Otherwise check if Claude Code is running
	if M.detect_claude_in_pane(pane) then
		-- Initialize with active state
		M.set_pane_state(pane_id, M.STATE.ACTIVE)
		return M.ICONS.active
	end

	return nil
end

-- Get Claude Code icon for a tab (checks active pane)
function M.get_tab_icon(tab)
	local active_pane = tab:active_pane()
	if active_pane then
		return M.get_pane_icon(active_pane)
	end
	return nil
end

-- ============================================================================
-- TAB VISIT TRACKING (for state reset on navigation)
-- ============================================================================

-- Mark a tab as visited (resets "complete" state to "active")
function M.mark_tab_visited(tab_id)
	ensure_global_state()
	wezterm.GLOBAL.claude_code_tab_visited[tostring(tab_id)] = os.time()
end

-- Check if we should reset state when tab becomes active
function M.should_reset_on_visit(pane_id)
	local state = M.get_pane_state(pane_id)
	-- Reset COMPLETE state to ACTIVE when user navigates back
	return state == M.STATE.COMPLETE
end

-- Handle tab activation (reset complete state)
function M.on_tab_activated(tab)
	local active_pane = tab:active_pane()
	if not active_pane then
		return
	end

	local pane_id = active_pane:pane_id()
	if M.should_reset_on_visit(pane_id) then
		M.set_pane_state(pane_id, M.STATE.ACTIVE)
		if debug_config.is_enabled("debug_mods_claude_code") then
			wezterm.log_info("[CLAUDE_CODE] Reset state to ACTIVE on tab visit")
		end
	end

	M.mark_tab_visited(tab:tab_id())
end

-- ============================================================================
-- USER VAR HANDLERS (for state transitions from Claude Code)
-- ============================================================================
-- Claude Code can signal state changes via OSC user variables

-- Handle CLAUDE_CODE_STATE user variable
-- Values: "busy", "waiting", "complete", "error", "active"
function M.handle_user_var(pane, name, value)
	if name ~= "CLAUDE_CODE_STATE" then
		return false
	end

	local pane_id = pane:pane_id()

	-- Decode base64 if needed (WezTerm user vars are base64 encoded)
	local decoded_value = value
	local ok, decoded = pcall(wezterm.base64_decode, value)
	if ok and decoded then
		decoded_value = decoded
	end

	-- Trim whitespace
	decoded_value = decoded_value:gsub("^%s+", ""):gsub("%s+$", "")

	if debug_config.is_enabled("debug_mods_claude_code") then
		wezterm.log_info("[CLAUDE_CODE] User var received: " .. decoded_value)
	end

	-- Map value to state
	local state_map = {
		busy = M.STATE.BUSY,
		working = M.STATE.BUSY,
		thinking = M.STATE.BUSY,
		waiting = M.STATE.WAITING,
		input = M.STATE.WAITING,
		complete = M.STATE.COMPLETE,
		done = M.STATE.COMPLETE,
		finished = M.STATE.COMPLETE,
		error = M.STATE.ERROR,
		failed = M.STATE.ERROR,
		active = M.STATE.ACTIVE,
		idle = M.STATE.ACTIVE,
		exit = M.STATE.NONE,
		quit = M.STATE.NONE,
	}

	local new_state = state_map[decoded_value:lower()]
	if new_state then
		M.set_pane_state(pane_id, new_state)
		return true
	end

	return false
end

-- ============================================================================
-- PERIODIC POLLING (fallback detection)
-- ============================================================================
-- For cases where user vars aren't available, poll process state

-- Track last poll time per pane
local last_poll = {}
local POLL_INTERVAL = 2 -- seconds

function M.poll_pane_state(pane)
	local pane_id = pane:pane_id()
	local pane_id_str = tostring(pane_id)
	local now = os.time()

	-- Rate limit polling
	if last_poll[pane_id_str] and (now - last_poll[pane_id_str]) < POLL_INTERVAL then
		return
	end
	last_poll[pane_id_str] = now

	local current_state = M.get_pane_state(pane_id)
	local is_claude = M.detect_claude_in_pane(pane)

	if is_claude then
		-- Claude Code is running
		if current_state == M.STATE.NONE then
			-- New session detected
			M.set_pane_state(pane_id, M.STATE.ACTIVE)
			if debug_config.is_enabled("debug_mods_claude_code") then
				wezterm.log_info("[CLAUDE_CODE] Session detected in pane " .. pane_id_str)
			end
		end
	else
		-- Claude Code not running
		if current_state ~= M.STATE.NONE then
			-- Session ended
			M.set_pane_state(pane_id, M.STATE.NONE)
			if debug_config.is_enabled("debug_mods_claude_code") then
				wezterm.log_info("[CLAUDE_CODE] Session ended in pane " .. pane_id_str)
			end
		end
	end
end

-- ============================================================================
-- CLEANUP
-- ============================================================================

-- Clean up state for closed panes
function M.cleanup_pane(pane_id)
	ensure_global_state()
	local pane_id_str = tostring(pane_id)
	wezterm.GLOBAL.claude_code_state[pane_id_str] = nil
	last_poll[pane_id_str] = nil
end

-- Clean up state for closed tabs
function M.cleanup_tab(tab_id)
	ensure_global_state()
	wezterm.GLOBAL.claude_code_tab_visited[tostring(tab_id)] = nil
end

-- ============================================================================
-- SHELL INTEGRATION HELPERS
-- ============================================================================
-- Functions to generate shell commands for Claude Code to signal state

-- Generate shell command to set Claude Code state
-- Usage in shell: eval "$(claude_state_cmd busy)"
function M.get_shell_state_cmd(state)
	-- OSC 1337 user var format for WezTerm
	local base64_state = wezterm.base64_encode(state)
	return string.format('printf "\\033]1337;SetUserVar=CLAUDE_CODE_STATE=%s\\007"', base64_state)
end

-- Generate all shell helper functions
function M.get_shell_helpers()
	return [[
# Claude Code WezTerm Integration
# Add these functions to your shell profile

claude_wezterm_state() {
    local state="${1:-active}"
    local encoded=$(echo -n "$state" | base64)
    printf '\033]1337;SetUserVar=CLAUDE_CODE_STATE=%s\007' "$encoded"
}

# Convenience aliases
claude_busy()     { claude_wezterm_state busy; }
claude_waiting()  { claude_wezterm_state waiting; }
claude_complete() { claude_wezterm_state complete; }
claude_error()    { claude_wezterm_state error; }
claude_active()   { claude_wezterm_state active; }
claude_exit()     { claude_wezterm_state exit; }
]]
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function M.init()
	ensure_global_state()
	wezterm.log_info("[CLAUDE_CODE] Status indicator module initialized")
end

return M
