-- ~/.core/.sys/cfg/wezterm/modules/sessions/neovim_integration.lua
-- Neovim AutoSession integration for workspace session management
-- Automatically saves/restores Neovim sessions within workspace context

local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

-- Check if a pane is running Neovim
local function is_neovim_pane(pane)
	local process_name = pane:get_foreground_process_name()
	if not process_name then
		return false
	end

	-- Match nvim, vim, or vi processes
	return process_name:match("n?vim?$") ~= nil or process_name:match("/n?vim?$") ~= nil
end

-- Get Neovim session directory for workspace
function M.get_session_dir(workspace_name)
	return paths.SESSIONS_DIR .. "/" .. workspace_name .. "/nvim_sessions"
end

-- Ensure Neovim session directory exists for workspace
function M.ensure_session_dir(workspace_name)
	local session_dir = M.get_session_dir(workspace_name)
	os.execute('mkdir -p "' .. session_dir .. '"')
	return session_dir
end

-- Send command to Neovim pane (via terminal escape sequences)
local function send_nvim_command(pane, command)
	-- Send ESC to exit any mode, then the command
	pane:send_text("\x1b")
	wezterm.sleep_ms(50)
	pane:send_text(":" .. command .. "\n")
	wezterm.sleep_ms(100)
end

-- Save Neovim session in pane
function M.save_nvim_session(pane, workspace_name)
	if not is_neovim_pane(pane) then
		return false
	end

	local session_dir = M.ensure_session_dir(workspace_name)
	wezterm.log_info("Saving Neovim session for workspace: " .. workspace_name)

	-- Set AutoSession root directory and save session
	-- This command sets the session directory and saves immediately
	local nvim_command = string.format(
		'lua vim.g.auto_session_root_dir = "%s"; require("auto-session").SaveSession()',
		session_dir
	)

	send_nvim_command(pane, nvim_command)

	wezterm.log_info("Sent save command to Neovim pane (workspace: " .. workspace_name .. ")")
	return true
end

-- Restore Neovim session in pane
function M.restore_nvim_session(pane, workspace_name)
	if not is_neovim_pane(pane) then
		return false
	end

	local session_dir = M.get_session_dir(workspace_name)
	wezterm.log_info("Restoring Neovim session for workspace: " .. workspace_name)

	-- Check if session directory exists and has sessions
	local check_cmd = 'ls "' .. session_dir .. '"/*.vim 2>/dev/null | wc -l'
	local handle = io.popen(check_cmd)
	if not handle then
		wezterm.log_warn("Could not check for Neovim sessions in: " .. session_dir)
		return false
	end

	local count_str = handle:read("*a")
	handle:close()
	local count = tonumber(count_str)

	if not count or count == 0 then
		wezterm.log_info("No Neovim sessions found for workspace: " .. workspace_name)
		return false
	end

	-- Set AutoSession root directory and restore session
	local nvim_command = string.format(
		'lua vim.g.auto_session_root_dir = "%s"; require("auto-session").RestoreSession()',
		session_dir
	)

	send_nvim_command(pane, nvim_command)

	wezterm.log_info("Sent restore command to Neovim pane (workspace: " .. workspace_name .. ")")
	return true
end

-- Save all Neovim sessions in a tab
function M.save_tab_nvim_sessions(tab, workspace_name)
	local panes = tab:panes()
	local saved_count = 0

	for _, pane in ipairs(panes) do
		if M.save_nvim_session(pane, workspace_name) then
			saved_count = saved_count + 1
		end
	end

	if saved_count > 0 then
		wezterm.log_info("Saved " .. saved_count .. " Neovim session(s) in tab")
	end

	return saved_count
end

-- Save all Neovim sessions in workspace
function M.save_workspace_nvim_sessions(window, workspace_name)
	local mux_window = window:mux_window()
	if not mux_window then
		return 0
	end

	local tabs = mux_window:tabs()
	local total_saved = 0

	for _, tab in ipairs(tabs) do
		total_saved = total_saved + M.save_tab_nvim_sessions(tab, workspace_name)
	end

	if total_saved > 0 then
		wezterm.log_info("Saved " .. total_saved .. " total Neovim session(s) for workspace: " .. workspace_name)
	end

	return total_saved
end

-- Configure Neovim to use workspace-specific session directory on startup
-- This should be called BEFORE launching Neovim in a workspace context
function M.get_nvim_env_vars(workspace_name)
	local session_dir = M.ensure_session_dir(workspace_name)

	return {
		-- Set AutoSession root directory via environment variable
		-- Note: This requires AutoSession to be configured to read from env var
		NVIM_AUTO_SESSION_ROOT = session_dir,
		-- Alternative: Use init.vim override
		-- NVIM_INIT_OVERRIDE = "let g:auto_session_root_dir = '" .. session_dir .. "'",
	}
end

-- Launch Neovim with workspace-specific session directory
function M.spawn_nvim_in_workspace(window, pane, workspace_name, cwd)
	local session_dir = M.ensure_session_dir(workspace_name)
	cwd = cwd or wezterm.home_dir

	wezterm.log_info("Spawning Neovim with session dir: " .. session_dir)

	-- Spawn Neovim with AutoSession configured
	local nvim_args = {
		"nvim",
		-- Set AutoSession root via command line
		"-c",
		'lua vim.g.auto_session_root_dir = "' .. session_dir .. '"',
		"-c",
		'lua require("auto-session").RestoreSession()',
	}

	window:perform_action(
		wezterm.action.SpawnCommandInNewTab({
			args = nvim_args,
			cwd = cwd,
		}),
		pane
	)

	return true
end

-- Detect TMUX environment and use tmux-resurrect instead
function M.is_in_tmux()
	return os.getenv("TMUX") ~= nil
end

-- Get detection info for a pane
function M.get_pane_info(pane)
	local process_name = pane:get_foreground_process_name()
	local is_nvim = is_neovim_pane(pane)
	local in_tmux = M.is_in_tmux()

	return {
		is_neovim = is_nvim,
		in_tmux = in_tmux,
		process_name = process_name or "(unknown)",
		should_save_session = is_nvim and not in_tmux, -- Only save if Neovim and not in TMUX
	}
end

-- Show info about Neovim sessions
function M.show_session_info(window, pane)
	local workspace_name = window:active_workspace()
	local session_dir = M.get_session_dir(workspace_name)

	-- Count session files
	local check_cmd = 'ls "' .. session_dir .. '"/*.vim 2>/dev/null | wc -l'
	local handle = io.popen(check_cmd)
	local count_str = handle and handle:read("*a") or "0"
	if handle then
		handle:close()
	end
	local count = tonumber(count_str) or 0

	-- Get info about current pane
	local pane_info = M.get_pane_info(pane)

	local message = string.format(
		"Workspace: %s\nSession Dir: %s\nSaved Sessions: %d\n\nCurrent Pane:\nNeovim: %s\nIn TMUX: %s\nProcess: %s",
		workspace_name,
		session_dir,
		count,
		pane_info.is_neovim and "Yes" or "No",
		pane_info.in_tmux and "Yes" or "No",
		pane_info.process_name
	)

	window:toast_notification("Neovim Session Info", message, nil, 5000)
end

-- Initialize: ensure base session directory exists
function M.init()
	os.execute('mkdir -p "' .. paths.SESSIONS_DIR .. '"')
	wezterm.log_info("Neovim integration initialized")
end

return M
