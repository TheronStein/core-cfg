-- ~/.config/wezterm/session-manager.lua
local wezterm = require("wezterm")
local io = require("io")
local os = require("os")
local json = require("cjson")

local M = {}

local DATA_DIR = wezterm.home_dir .. "/.config/wezterm/.data/sessions"
wezterm.mkdir(DATA_DIR)

-- Helper: get current workspace name
local function current_workspace()
	return wezterm.mux.get_active_workspace()
end

-- Helper: get path for current workspace
local function workspace_dir(name)
	name = name or current_workspace()
	local dir = DATA_DIR .. "/" .. name
	wezterm.mkdir(dir)
	wezterm.mkdir(dir .. "/nvim_sessions_root")
	return dir
end

-- Save tab title, icon, and color (even if set by your custom plugin)
local function serialize_tab(tab)
	local title = tab.get_title()
	local icon = tab.tab_icon and tab.tab_icon.text or nil
	local color = tab.active_pane().user_vars.tab_color or tab.tab_color -- support both ways

	return {
		tab_id = tab.tab_id,
		title = title,
		icon = icon,
		color = color,
		is_active = tab.is_active,
	}
end

-- Save pane: cwd + we'll let tmux-resurrect save the process
local function serialize_pane(pane)
	local cwd = pane.get_current_working_dir()
	return {
		pane_id = pane.pane_id,
		cwd = cwd and cwd.file_path or nil,
		is_active = pane.is_active,
	}
end

-- Save window: tabs + panes + layout
local function serialize_window(window)
	local tabs = {}
	for _, tab in ipairs(window:tabs()) do
		local t = serialize_tab(tab)
		t.panes = {}
		for _, pane in ipairs(tab:panes()) do
			table.insert(t.panes, serialize_pane(pane))
		end
		table.insert(tabs, t)
	end
	return {
		window_id = window:window_id(),
		active_tab_index = window:active_tab_index(),
		tabs = tabs,
	}
end

-- Save entire workspace state
function M.save_workspace(workspace_name)
	workspace_name = workspace_name or current_workspace()
	local mux_window = wezterm.mux.get_active_window()
	if not mux_window then
		wezterm.log_error("No active window to save")
		return
	end

	local state = {
		saved_at = os.time(),
		wezterm_version = wezterm.version,
		windows = {},
	}

	for _, window in ipairs(wezterm.mux.get_windows()) do
		table.insert(state.windows, serialize_window(window))
	end

	local dir = workspace_dir(workspace_name)
	local f = io.open(dir .. "/wezterm_state.json", "w")
	f:write(json.encode(state))
	f:close()

	-- Save tmux server name if any pane is running tmux
	local any_tmux = false
	for _, window in ipairs(wezterm.mux.get_windows()) do
		for _, tab in ipairs(window:tabs()) do
			for _, pane in ipairs(tab:panes()) do
				if pane.get_title():find("^tmux") then
					local server = pane.get_user_vars().TMUX or "default"
					server = server:gsub("/tmp/tmux%-%d+/(%w+)", "%1")
					local sf = io.open(dir .. "/tmux_server_name", "w")
					sf:write(server)
					sf:close()
					any_tmux = true
				end
			end
		end
	end

	wezterm.log_info("Saved workspace: " .. workspace_name)
end

-- Apply saved tab appearance
local function restore_tab_appearance(tab, saved_tab)
	if saved_tab.title then
		tab:set_title(saved_tab.title)
	end
	if saved_tab.icon then
		wezterm.emit("user-var-changed", tab.active_pane(), "tab_icon", saved_tab.icon)
	end
	if saved_tab.color then
		tab.active_pane():set_user_var("tab_color", saved_tab.color)
		-- Or if your plugin uses a different var:
		wezterm.emit("user-var-changed", tab.active_pane(), "tab_color", saved_tab.color)
	end
end

-- Restore panes layout and cwd
local function restore_panes(tab, saved_panes)
	-- This is the hard part: we need to recreate the exact split layout
	-- WezTerm doesn't expose layout tree directly, so we approximate by:
	-- 1. Kill all panes except first
	-- 2. Split according to saved cwd order
	local panes = tab:panes()
	local first_pane = panes[1]

	-- Kill extra panes
	for i = #panes, 2, -1 do
		panes[i]:kill()
	end

	local new_panes = { first_pane }
	for i, saved in ipairs(saved_panes) do
		if i > 1 then
			local direction = (i % 2 == 0) and "Right" or "Bottom"
			local new_pane = first_pane:split({ direction = direction, size = 0.5 })
			table.insert(new_panes, new_pane)
		end
	end

	-- Set cwd on each pane
	for i, pane in ipairs(new_panes) do
		local saved = saved_panes[i]
		if saved and saved.cwd then
			pane:send_text("cd " .. wezterm.shell_quote(saved.cwd) .. "\n")
		end
	end
end

function M.restore_workspace(workspace_name)
	local dir = workspace_dir(workspace_name)
	local state_file = dir .. "/wezterm_state.json"
	local f = io.open(state_file, "r")
	if not f then
		wezterm.log_error("No saved state for workspace: " .. workspace_name)
		return false
	end

	local state = json.decode(f:read("*a"))
	f:close()

	-- Optional: restore theme
	local theme_file = dir .. "/theme"
	if wezterm.path_exists(theme_file) then
		local tf = io.open(theme_file)
		local theme_name = tf:read("*l"):match("^%s*(.-)%s*$")
		tf:close()
		wezterm.GLOBAL.current_theme = theme_name
		wezterm.reload_configuration()
	end

	-- Kill all existing windows/tabs except one
	local mux = wezterm.mux
	for _, win in ipairs(mux.get_windows()) do
		if win:window_id() ~= mux.get_active_window():window_id() then
			mux.kill_window(win)
		end
	end

	local window = mux.get_active_window()
	local tab = window:active_tab()

	-- We'll recreate everything from the first saved window
	local first_saved_window = state.windows[1]
	if not first_saved_window then
		return false
	end

	-- Restore tabs
	for i, saved_tab in ipairs(first_saved_window.tabs) do
		if i > 1 then
			tab = window:new_tab()
		end
		restore_tab_appearance(tab, saved_tab)
		restore_panes(tab, saved_tab.panes)
	end

	-- Restore tmux server if saved
	local server_file = dir .. "/tmux_server_name"
	if wezterm.path_exists(server_file) then
		local sf = io.open(server_file)
		local server = sf:read("*l")
		sf:close()

		-- Attach to the correct tmux server in the first pane
		local first_pane = window:active_tab():panes()[1]
		first_pane:send_text("tmux -2 attach -t " .. server .. " || tmux -2 new -s " .. server .. "\n")
	end

	-- Tell auto-session where to look for Neovim sessions
	local nvim_root = dir .. "/nvim_sessions_root"
	wezterm.GLOBAL.auto_session_root = nvim_root

	wezterm.log_info("Restored workspace: " .. workspace_name)
	return true
end

-- Auto-save on exit, auto-restore on workspace switch
wezterm.on("window-config-reloaded", function(window, pane)
	local workspace = current_workspace()
	M.save_workspace(workspace)
end)

wezterm.on("update-status", function(window, pane)
	local workspace = current_workspace()
	local dir = workspace_dir(workspace)
	if not wezterm.path_exists(dir .. "/wezterm_state.json") then
		M.save_workspace(workspace) -- first time
	end
end)

-- Keybindings will go in your main wezterm.lua
M.list_workspaces = function()
	local workspaces = {}
	for entry in wezterm.fs.iterate_directory(DATA_DIR) do
		if entry.is_directory then
			table.insert(workspaces, entry.name)
		end
	end
	return workspaces
end

return M
