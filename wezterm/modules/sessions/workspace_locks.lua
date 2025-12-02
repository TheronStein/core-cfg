-- ~/.core/.sys/cfg/wezterm/modules/sessions/workspace_locks.lua
-- Workspace locking system for multi-client access control
-- Ensures only ONE client can attach to a workspace at a time

local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

-- Lock directory
local lock_dir = paths.WEZTERM_DATA .. "/workspace-locks"

-- Ensure lock directory exists
local function ensure_lock_dir()
	os.execute('mkdir -p "' .. lock_dir .. '"')
	return true
end

-- Get lock file path for workspace
local function get_lock_path(workspace_name)
	return lock_dir .. "/" .. workspace_name .. ".lock"
end

-- Get current client ID
local function get_client_id()
	return {
		hostname = wezterm.hostname(),
		pid = wezterm.procinfo.pid,
		timestamp = os.time(),
	}
end

-- Check if a PID is still running
local function is_pid_alive(pid, hostname)
	-- Only check local PIDs
	if hostname ~= wezterm.hostname() then
		-- Remote host - assume alive if we can't verify
		-- In future, could implement remote check via SSH
		return true
	end

	-- Check if PID exists and is running
	local handle = io.popen("ps -p " .. tostring(pid) .. " > /dev/null 2>&1 && echo alive || echo dead")
	if not handle then
		return false
	end

	local result = handle:read("*a")
	handle:close()

	return result:match("alive") ~= nil
end

-- Read lock file
local function read_lock(workspace_name)
	local lock_path = get_lock_path(workspace_name)
	local file = io.open(lock_path, "r")

	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()

	if content == "" then
		return nil
	end

	local success, lock_data = pcall(wezterm.json_parse, content)
	if not success or not lock_data then
		wezterm.log_warn("Failed to parse lock file: " .. lock_path)
		return nil
	end

	return lock_data
end

-- Write lock file
local function write_lock(workspace_name, client_id)
	ensure_lock_dir()
	local lock_path = get_lock_path(workspace_name)
	local file = io.open(lock_path, "w")

	if not file then
		wezterm.log_error("Failed to create lock file: " .. lock_path)
		return false
	end

	local json_str = wezterm.json_encode(client_id)
	file:write(json_str)
	file:close()

	wezterm.log_info("Created workspace lock: " .. workspace_name .. " (PID " .. client_id.pid .. ")")
	return true
end

-- Remove lock file
local function remove_lock(workspace_name)
	local lock_path = get_lock_path(workspace_name)
	local success = os.remove(lock_path)

	if success then
		wezterm.log_info("Removed workspace lock: " .. workspace_name)
	end

	return success
end

-- Check if workspace is locked by another client
-- Returns: is_locked (bool), lock_info (table or nil)
function M.is_workspace_locked(workspace_name)
	local lock_data = read_lock(workspace_name)

	if not lock_data then
		-- No lock file exists
		return false, nil
	end

	local current_client = get_client_id()

	-- Check if lock belongs to current client
	if lock_data.hostname == current_client.hostname and lock_data.pid == current_client.pid then
		-- We own this lock
		return false, lock_data
	end

	-- Check if the lock is stale (PID no longer exists)
	if not is_pid_alive(lock_data.pid, lock_data.hostname) then
		wezterm.log_info("Found stale lock for workspace: " .. workspace_name .. " (PID " .. lock_data.pid .. ")")
		-- Lock is stale, remove it
		remove_lock(workspace_name)
		return false, nil
	end

	-- Lock is valid and owned by another client
	return true, lock_data
end

-- Acquire lock for workspace
-- Returns: success (bool), error_message (string or nil)
function M.acquire_lock(workspace_name)
	local is_locked, lock_info = M.is_workspace_locked(workspace_name)

	if is_locked then
		local error_msg = string.format(
			"Workspace '%s' is locked by %s (PID %d) since %s",
			workspace_name,
			lock_info.hostname,
			lock_info.pid,
			os.date("%Y-%m-%d %H:%M:%S", lock_info.timestamp)
		)
		wezterm.log_warn(error_msg)
		return false, error_msg
	end

	-- Acquire lock
	local client_id = get_client_id()
	local success = write_lock(workspace_name, client_id)

	if success then
		return true, nil
	else
		return false, "Failed to create lock file"
	end
end

-- Release lock for workspace
function M.release_lock(workspace_name)
	local lock_data = read_lock(workspace_name)

	if not lock_data then
		-- No lock exists
		return true
	end

	local current_client = get_client_id()

	-- Only release if we own the lock
	if lock_data.hostname == current_client.hostname and lock_data.pid == current_client.pid then
		return remove_lock(workspace_name)
	else
		wezterm.log_warn(
			"Attempted to release lock for workspace '"
				.. workspace_name
				.. "' but we don't own it (owned by "
				.. lock_data.hostname
				.. ":"
				.. lock_data.pid
				.. ")"
		)
		return false
	end
end

-- Force release lock (admin override)
function M.force_release_lock(workspace_name)
	wezterm.log_warn("Force releasing lock for workspace: " .. workspace_name)
	return remove_lock(workspace_name)
end

-- Clean up stale locks
-- Returns: number of locks cleaned
function M.cleanup_stale_locks()
	ensure_lock_dir()
	local count = 0

	local handle = io.popen('ls -1 "' .. lock_dir .. '"/*.lock 2>/dev/null')
	if not handle then
		return count
	end

	for file in handle:lines() do
		local workspace_name = file:match("([^/]+)%.lock$")
		if workspace_name then
			local lock_data = read_lock(workspace_name)
			if lock_data and not is_pid_alive(lock_data.pid, lock_data.hostname) then
				wezterm.log_info("Cleaning stale lock: " .. workspace_name)
				remove_lock(workspace_name)
				count = count + 1
			end
		end
	end

	handle:close()
	wezterm.log_info("Cleaned up " .. count .. " stale workspace locks")
	return count
end

-- List all current locks
function M.list_locks()
	ensure_lock_dir()
	local locks = {}

	local handle = io.popen('ls -1 "' .. lock_dir .. '"/*.lock 2>/dev/null')
	if not handle then
		return locks
	end

	for file in handle:lines() do
		local workspace_name = file:match("([^/]+)%.lock$")
		if workspace_name then
			local lock_data = read_lock(workspace_name)
			if lock_data then
				table.insert(locks, {
					workspace = workspace_name,
					hostname = lock_data.hostname,
					pid = lock_data.pid,
					timestamp = lock_data.timestamp,
					is_alive = is_pid_alive(lock_data.pid, lock_data.hostname),
				})
			end
		end
	end

	handle:close()
	return locks
end

-- Show lock status menu
function M.show_lock_status(window, pane)
	local locks = M.list_locks()
	local current_client = get_client_id()

	if #locks == 0 then
		window:toast_notification("WezTerm", "No workspace locks active", nil, 2000)
		return
	end

	local choices = {
		{ id = "__header__", label = "=== Workspace Locks ===" },
		{ id = "__separator__", label = "─────────────────────────────" },
	}

	for _, lock in ipairs(locks) do
		local status_icon = lock.is_alive and "🔒" or "💀"
		local is_mine = (lock.hostname == current_client.hostname and lock.pid == current_client.pid)
		local ownership = is_mine and " [YOU]" or ""
		local timestamp_str = os.date("%Y-%m-%d %H:%M:%S", lock.timestamp)

		local label = string.format(
			"%s %s - %s:%d%s (since %s)",
			status_icon,
			lock.workspace,
			lock.hostname,
			lock.pid,
			ownership,
			timestamp_str
		)

		table.insert(choices, {
			id = lock.workspace,
			label = label,
		})
	end

	table.insert(choices, { id = "__separator2__", label = "─────────────────────────────" })
	table.insert(choices, { id = "__cleanup__", label = "🧹 Clean Up Stale Locks" })

	window:perform_action(
		wezterm.action.InputSelector({
			action = wezterm.action_callback(function(win, p, id)
				if id == "__cleanup__" then
					local cleaned = M.cleanup_stale_locks()
					win:toast_notification("WezTerm", "Cleaned " .. cleaned .. " stale locks", nil, 2000)
				elseif id and id:sub(1, 2) ~= "__" then
					-- Show options for selected lock
					local lock_choices = {
						{ id = "info", label = "ℹ️  Show Info" },
						{ id = "force_release", label = "⚠️  Force Release (Admin)" },
						{ id = "cancel", label = "❌ Cancel" },
					}

					win:perform_action(
						wezterm.action.InputSelector({
							action = wezterm.action_callback(function(inner_win, inner_pane, action_id)
								if action_id == "force_release" then
									M.force_release_lock(id)
									inner_win:toast_notification("WezTerm", "Force released lock: " .. id, nil, 2000)
								end
							end),
							title = "🔒 Workspace Lock: " .. id,
							choices = lock_choices,
							fuzzy = false,
						}),
						p
					)
				end
			end),
			title = "🔒 Workspace Locks (" .. #locks .. " active)",
			choices = choices,
			fuzzy = false,
		}),
		pane
	)
end

-- Initialize: cleanup stale locks on startup
function M.init()
	wezterm.log_info("Initializing workspace lock system...")
	M.cleanup_stale_locks()
end

return M
