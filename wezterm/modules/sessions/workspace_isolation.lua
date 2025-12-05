-- Workspace Isolation Module
-- Implements true multi-client workspace isolation where each workspace
-- runs in a separate WezTerm client/window for complete independence.
--
-- Architecture:
--   - Each workspace = separate wezterm client process
--   - Clients can share tmux sessions (tmux layer handles persistence)
--   - No state loss on workspace switching (each client remains active)
--   - Clean separation of concerns between UI (WezTerm) and persistence (tmux)

local wezterm = require("wezterm")
local paths = require("utils.paths")

local M = {}

-- ============================================================================
-- WORKSPACE CLIENT TRACKING
-- ============================================================================

-- Get list of all running WezTerm clients with workspace information
-- Returns: table of { window_id, workspace, pane_count, tab_count }
function M.get_running_clients()
	local handle = io.popen("wezterm cli list --format json 2>/dev/null")
	if not handle then
		wezterm.log_error("[WORKSPACE_ISOLATION] Failed to execute wezterm cli list")
		return {}
	end

	local output = handle:read("*all")
	handle:close()

	if not output or output == "" then
		return {}
	end

	local success, panes = pcall(wezterm.json_parse, output)
	if not success or not panes then
		wezterm.log_error("[WORKSPACE_ISOLATION] Failed to parse wezterm cli output")
		return {}
	end

	-- Aggregate by window_id and workspace
	local clients = {}
	local seen_windows = {}

	for _, pane in ipairs(panes) do
		local window_id = pane.window_id
		local workspace = pane.workspace or "default"

		if not seen_windows[window_id] then
			seen_windows[window_id] = true
			table.insert(clients, {
				window_id = window_id,
				workspace = workspace,
			})
		end
	end

	return clients
end

-- Check if a workspace already has a running client
-- Returns: window_id if found, nil otherwise
function M.find_client_for_workspace(workspace_name)
	local clients = M.get_running_clients()

	for _, client in ipairs(clients) do
		if client.workspace == workspace_name then
			return client.window_id
		end
	end

	return nil
end

-- Get statistics about a workspace (tab count, pane count, etc.)
function M.get_workspace_stats(workspace_name)
	local handle = io.popen("wezterm cli list --format json 2>/dev/null")
	if not handle then
		return { tab_count = 0, pane_count = 0 }
	end

	local output = handle:read("*all")
	handle:close()

	local success, panes = pcall(wezterm.json_parse, output)
	if not success or not panes then
		return { tab_count = 0, pane_count = 0 }
	end

	local tabs = {}
	local pane_count = 0

	for _, pane in ipairs(panes) do
		if pane.workspace == workspace_name then
			pane_count = pane_count + 1
			tabs[pane.tab_id] = true
		end
	end

	local tab_count = 0
	for _ in pairs(tabs) do
		tab_count = tab_count + 1
	end

	return {
		tab_count = tab_count,
		pane_count = pane_count,
	}
end

-- ============================================================================
-- CLIENT SPAWNING AND FOCUSING
-- ============================================================================

-- Spawn a new WezTerm client for a workspace
-- workspace_name: name of the workspace to create/attach
-- cwd: optional working directory for the first pane
function M.spawn_workspace_client(workspace_name, cwd)
	wezterm.log_info("[WORKSPACE_ISOLATION] Spawning new client for workspace: " .. workspace_name)

	local spawn_cmd = string.format('wezterm start --workspace "%s"', workspace_name)

	if cwd then
		spawn_cmd = spawn_cmd .. string.format(' --cwd "%s"', cwd)
	end

	-- Spawn in background
	spawn_cmd = spawn_cmd .. " &"

	wezterm.log_info("[WORKSPACE_ISOLATION] Spawn command: " .. spawn_cmd)

	local result = os.execute(spawn_cmd)

	if result then
		wezterm.log_info("[WORKSPACE_ISOLATION] Successfully spawned client for: " .. workspace_name)
		return true
	else
		wezterm.log_error("[WORKSPACE_ISOLATION] Failed to spawn client for: " .. workspace_name)
		return false
	end
end

-- Focus/raise an existing workspace client
-- Uses wezterm cli to activate the workspace (switches GUI focus)
function M.focus_workspace_client(workspace_name)
	wezterm.log_info("[WORKSPACE_ISOLATION] Focusing existing client for workspace: " .. workspace_name)

	-- Use wezterm cli to switch to the workspace
	-- This will raise the window that contains this workspace
	local focus_cmd = string.format('wezterm cli activate-workspace "%s" 2>/dev/null', workspace_name)

	local result = os.execute(focus_cmd)

	if result then
		wezterm.log_info("[WORKSPACE_ISOLATION] Successfully focused workspace: " .. workspace_name)
		return true
	else
		wezterm.log_warn("[WORKSPACE_ISOLATION] Failed to focus workspace: " .. workspace_name)
		-- Fallback: spawn new client
		return M.spawn_workspace_client(workspace_name)
	end
end

-- ============================================================================
-- HIGH-LEVEL WORKSPACE OPERATIONS
-- ============================================================================

-- Switch to a workspace, spawning new client if needed or focusing existing one
-- This is the main entry point for workspace switching in the isolated model
function M.switch_to_workspace(workspace_name, cwd)
	wezterm.log_info("[WORKSPACE_ISOLATION] Switch request for workspace: " .. workspace_name)

	-- Check if workspace already has a client
	local existing_window_id = M.find_client_for_workspace(workspace_name)

	if existing_window_id then
		wezterm.log_info(
			"[WORKSPACE_ISOLATION] Workspace '"
				.. workspace_name
				.. "' already running in window "
				.. existing_window_id
		)
		-- Focus existing client
		return M.focus_workspace_client(workspace_name)
	else
		wezterm.log_info("[WORKSPACE_ISOLATION] Workspace '" .. workspace_name .. "' not running, spawning new client")
		-- Spawn new client
		return M.spawn_workspace_client(workspace_name, cwd)
	end
end

-- Load a workspace session into an isolated client
-- session_data: parsed session JSON with tabs, panes, metadata
-- This spawns a new client and restores the full session layout
function M.load_workspace_session_isolated(session_data, target_workspace)
	wezterm.log_info("[WORKSPACE_ISOLATION] Loading session into isolated workspace: " .. target_workspace)

	-- First, check if workspace already exists
	local existing_window_id = M.find_client_for_workspace(target_workspace)

	if existing_window_id then
		wezterm.log_warn(
			"[WORKSPACE_ISOLATION] Workspace '"
				.. target_workspace
				.. "' already running. Use switch_to_workspace to focus it."
		)
		return false
	end

	-- Determine first CWD
	local first_cwd = wezterm.home_dir
	if session_data.tabs and #session_data.tabs > 0 then
		local first_tab = session_data.tabs[1]
		if first_tab.panes and #first_tab.panes > 0 then
			first_cwd = first_tab.panes[1].cwd or first_cwd
		end
	end

	-- Spawn new client for this workspace
	-- The session restoration will happen through the normal workspace_manager
	-- after the client is spawned
	return M.spawn_workspace_client(target_workspace, first_cwd)
end

-- Create a new workspace in an isolated client
-- Prompts for name and spawns immediately
function M.create_workspace_isolated(workspace_name, icon)
	wezterm.log_info("[WORKSPACE_ISOLATION] Creating new isolated workspace: " .. workspace_name)

	-- Check if workspace already exists
	local existing_window_id = M.find_client_for_workspace(workspace_name)

	if existing_window_id then
		wezterm.log_warn("[WORKSPACE_ISOLATION] Workspace '" .. workspace_name .. "' already exists, focusing instead")
		return M.focus_workspace_client(workspace_name)
	end

	-- Spawn new client
	return M.spawn_workspace_client(workspace_name)
end

-- ============================================================================
-- WORKSPACE LIFECYCLE MANAGEMENT
-- ============================================================================

-- Close a workspace client (kills all tabs/panes in that workspace)
-- This is different from switching away - it actually terminates the client
function M.close_workspace_client(workspace_name)
	wezterm.log_info("[WORKSPACE_ISOLATION] Closing workspace client: " .. workspace_name)

	-- Get all windows in this workspace and close them
	-- This is handled by the existing close_workspace function in workspace_manager
	-- We just need to ensure the client window is closed

	local clients = M.get_running_clients()
	local target_window_id = nil

	for _, client in ipairs(clients) do
		if client.workspace == workspace_name then
			target_window_id = client.window_id
			break
		end
	end

	if not target_window_id then
		wezterm.log_warn("[WORKSPACE_ISOLATION] Workspace '" .. workspace_name .. "' not found")
		return false
	end

	-- Use wezterm cli to close all panes in this workspace
	local close_cmd =
		string.format('wezterm cli list | grep "workspace: %s" | awk \'{print $2}\' | xargs -I {} wezterm cli kill-pane --pane-id {} 2>/dev/null', workspace_name)

	local result = os.execute(close_cmd)

	if result then
		wezterm.log_info("[WORKSPACE_ISOLATION] Successfully closed workspace: " .. workspace_name)
		return true
	else
		wezterm.log_error("[WORKSPACE_ISOLATION] Failed to close workspace: " .. workspace_name)
		return false
	end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Get a list of all workspace names with running clients
function M.get_active_workspace_names()
	local clients = M.get_running_clients()
	local workspaces = {}
	local seen = {}

	for _, client in ipairs(clients) do
		if not seen[client.workspace] then
			seen[client.workspace] = true
			table.insert(workspaces, client.workspace)
		end
	end

	table.sort(workspaces)
	return workspaces
end

-- Check if workspace isolation is available (wezterm cli is working)
function M.is_isolation_available()
	local handle = io.popen("wezterm cli list 2>/dev/null")
	if not handle then
		return false
	end

	local output = handle:read("*all")
	handle:close()

	return output ~= nil and output ~= ""
end

return M
