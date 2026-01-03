-- Unified tab lifecycle event handler
-- Handles all tab-related events:
--   - format-tab-title
--   - mux-tab-closed
--   - mux-window-close
--
-- Consolidates logic from:
--   - format-tab-title.lua (format-tab-title)
--   - tab-cleanup.lua (mux-tab-closed, mux-window-close)
--   - claude-code-status.lua (Claude Code AI status icons)

local wezterm = require("wezterm")
local debug_config = require("config.debug")

local M = {}

-- ============================================================================
-- PER-TAB MODE STATE INITIALIZATION
-- ============================================================================
-- Lazy initialization of tab mode state when tabs are first rendered

local function ensure_tab_mode_initialized(tab_id)
	local ok, tab_mode_state = pcall(require, "modules.utils.tab_mode_state")
	if not ok then
		return
	end

	-- Check if already initialized
	wezterm.GLOBAL.tab_modes = wezterm.GLOBAL.tab_modes or {}
	local id = tostring(tab_id)
	if wezterm.GLOBAL.tab_modes[id] then
		return -- Already initialized
	end

	-- Initialize with global context as default
	tab_mode_state.initialize_tab(tab_id)

	if debug_config.is_enabled("debug_mode_borders") then
		wezterm.log_info(string.format("[TAB-LIFECYCLE] Initialized mode state for tab %s", id))
	end
end

-- ============================================================================
-- CLAUDE CODE STATUS INTEGRATION
-- ============================================================================
-- Try to load the Claude Code status module (optional dependency)
local claude_status = nil
local function get_claude_status()
	if claude_status == nil then
		local ok, module = pcall(require, "modules.ai.claude-code-status")
		if ok then
			claude_status = module
		else
			claude_status = false -- Mark as unavailable
		end
	end
	return claude_status or nil
end

-- Get Claude Code icon for a pane (returns nil if no Claude session)
local function get_claude_icon(pane)
	local cs = get_claude_status()
	if not cs then
		return nil
	end

	-- Wrap pane object to match expected interface
	local pane_wrapper = {
		pane_id = function() return pane.pane_id end,
		get_foreground_process_name = function()
			return pane.foreground_process_name
		end,
	}

	return cs.get_pane_icon(pane_wrapper)
end

-- ============================================================================
-- FORMAT TAB TITLE
-- ============================================================================

-- Icon mapping for common processes
local process_icons = {
	["zsh"] = "",
	["bash"] = "",
	["nvim"] = "",
	["vim"] = "",
	["git"] = "",
	["lazygit"] = "",
	["ssh"] = "",
	["docker"] = "",
	["python"] = "",
	["node"] = "",
	["cargo"] = "",
	["tmux"] = "",
	["yazi"] = "",
	["claude"] = wezterm.nerdfonts.md_robot or "", -- Claude Code AI assistant
}

local function get_process_icon(process_name)
	-- Extract base process name (remove path)
	local basename = process_name:match("([^/]+)$") or process_name
	-- Check if we have a custom icon
	return process_icons[basename] or ""
end

-- Truncate string to max length with ".." suffix
local function truncate(str, max_len)
	if #str <= max_len then
		return str
	end
	return str:sub(1, max_len - 2) .. ".."
end

-- Get CWD or process name for display
local function get_cwd_or_process(pane)
	local cwd = pane.current_working_dir
	if cwd then
		local cwd_path = cwd.file_path or cwd
		-- Extract just the directory name
		local dir = cwd_path:match("([^/]+)/?$") or cwd_path
		return dir
	end

	-- Fallback to process name
	local process = pane.foreground_process_name or ""
	return process:match("([^/]+)$") or process
end

function M.format_tab_title(tab, tabs, panes, config, hover, max_width)
	-- Ensure this tab has mode state initialized (lazy initialization)
	ensure_tab_mode_initialized(tab.tab_id)

	local pane = tab.active_pane
	local process_name = pane.foreground_process_name or ""
	local process_icon = get_process_icon(process_name)

	-- Check for Claude Code status icon (dynamic state-based icon)
	local claude_icon = get_claude_icon(pane)
	if claude_icon then
		-- Claude Code is active - use the dynamic status icon instead
		process_icon = claude_icon
		if debug_config.is_enabled("debug_mods_claude_code") then
			wezterm.log_info("[TAB] Using Claude Code status icon for tab")
		end
	end

	-- Get user variables (tmux info)
	local user_vars = pane.user_vars or {}
	local tmux_session = user_vars.TMUX_SESSION or ""
	local tmux_window = user_vars.TMUX_WINDOW or ""
	local tmux_server_icon = user_vars.TMUX_SERVER_ICON or ""

	-- Decode base64 values
	if tmux_session ~= "" then
		local ok, decoded = pcall(wezterm.base64_decode, tmux_session)
		if ok then
			tmux_session = decoded
		end
	end
	if tmux_window ~= "" then
		local ok, decoded = pcall(wezterm.base64_decode, tmux_window)
		if ok then
			tmux_window = decoded
		end
	end
	if tmux_server_icon ~= "" then
		local ok, decoded = pcall(wezterm.base64_decode, tmux_server_icon)
		if ok then
			-- Trim any trailing newlines/whitespace from icon
			tmux_server_icon = decoded:gsub("%s+$", "")
		end
	end

	-- Get CWD/process
	local cwd_proc = get_cwd_or_process(pane)
	local cwd_proc_display = truncate(cwd_proc, 20)

	-- Build context string [tmux_icon WINDOW] or [DOMAIN]
	local context = ""
	if tmux_window ~= "" then
		-- Inside tmux: show window name with optional icon
		local window_part = truncate(tmux_window, 10)
		if tmux_server_icon ~= "" then
			context = "[" .. tmux_server_icon .. " " .. window_part .. "]"
		else
			context = "[ " .. window_part .. "]"
		end
	else
		-- Not in tmux: show domain
		local domain = pane.domain_name or "local"
		local domain_display = truncate(domain, 14)
		context = "[" .. domain_display .. "]"
	end

	-- Build final title: icon cwd/proc [context]
	local title = cwd_proc_display .. " " .. context

	-- Build the formatted title: "icon" in first section, title in second
	local process_display = process_icon ~= "" and process_icon or ""

	-- Colors matching tmux style
	local bg_inactive_arrow = "#5b4996"
	local fg_inactive_text = "#FFFFFF"
	local bg_inactive_text = "#5b4996"
	local bg_content = "#45475a"
	local fg_content = "#cdd6f4"
	local bg_tab_bar = "#292D3E"

	local bg_active_arrow = "#01F9C6"
	local fg_active_text = "#1e1e2e"
	local bg_active_text = "#01F9C6"

	local zoomed_indicator = pane.is_zoomed and "⬢ " or ""

	if tab.is_active then
		-- Active tab styling (matches tmux cyan theme)
		return {
			{ Foreground = { Color = bg_active_arrow } },
			{ Text = "" },
			{ Foreground = { Color = fg_active_text } },
			{ Background = { Color = bg_active_text } },
			{ Text = zoomed_indicator .. process_display .. " " },
			{ Foreground = { Color = bg_content } },
			{ Background = { Color = bg_active_text } },
			{ Text = "" },
			{ Foreground = { Color = fg_content } },
			{ Background = { Color = bg_content } },
			{ Text = " " .. title .. " " },
			{ Foreground = { Color = bg_content } },
			{ Background = { Color = bg_tab_bar } },
			{ Text = " " },
		}
	else
		-- Inactive tab styling (matches tmux purple theme)
		return {
			{ Foreground = { Color = bg_inactive_arrow } },
			{ Text = "" },
			{ Foreground = { Color = fg_inactive_text } },
			{ Background = { Color = bg_inactive_text } },
			{ Text = zoomed_indicator .. process_display .. " " },
			{ Foreground = { Color = bg_content } },
			{ Background = { Color = bg_inactive_text } },
			{ Text = "" },
			{ Foreground = { Color = fg_content } },
			{ Background = { Color = bg_content } },
			{ Text = " " .. title .. " " },
			{ Foreground = { Color = bg_content } },
			{ Background = { Color = bg_tab_bar } },
			{ Text = " " },
		}
	end
end

-- ============================================================================
-- TAB CLEANUP (TMUX SESSION HANDLING)
-- ============================================================================

function M.handle_mux_tab_closed(tab_id, pane_id)
	-- Try to load tmux_sessions module
	local ok, tmux_sessions = pcall(require, "modules.tmux.sessions")
	if ok and tmux_sessions then
		wezterm.log_info("Tab closed: " .. tostring(tab_id) .. ", cleaning up tmux view")
		tmux_sessions.cleanup_tab_view(tab_id)
	end

	-- Clean up Claude Code state for the closed pane
	local cs = get_claude_status()
	if cs and pane_id then
		cs.cleanup_pane(pane_id)
		cs.cleanup_tab(tab_id)
	end

	-- Clean up tab hooks state for the closed pane
	local ok_hooks, tab_hooks = pcall(require, "modules.tabs.tab_hooks")
	if ok_hooks and tab_hooks and pane_id then
		tab_hooks.cleanup_pane(pane_id)
	end

	-- Clean up per-tab mode state
	local ok_mode_state, tab_mode_state = pcall(require, "modules.utils.tab_mode_state")
	if ok_mode_state then
		tab_mode_state.cleanup_tab(tab_id)
		if debug_config.is_enabled("debug_mode_borders") then
			wezterm.log_info(string.format("[TAB-LIFECYCLE] Cleaned up mode state for tab %s", tostring(tab_id)))
		end
	end
end

function M.handle_mux_window_close(window_id)
	-- Try to load tmux_sessions module
	local ok, tmux_sessions = pcall(require, "modules.tmux.sessions")
	if ok and tmux_sessions then
		wezterm.log_info("Window closed: " .. tostring(window_id) .. ", cleaning up orphaned views")
		tmux_sessions.cleanup_orphaned_views()
	end
end

-- ============================================================================
-- SETUP
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.tab_lifecycle_initialized then
		return
	end
	wezterm.GLOBAL.tab_lifecycle_initialized = true

	-- Setup tab metadata persistence hooks
	local tab_metadata = require("modules.tabs.tab_metadata_persistence")
	tab_metadata.setup_hooks()

	-- Format tab title event
	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		return M.format_tab_title(tab, tabs, panes, config, hover, max_width)
	end)

	-- Mux tab closed event
	wezterm.on("mux-tab-closed", function(tab_id, pane_id)
		M.handle_mux_tab_closed(tab_id, pane_id)
	end)

	-- Mux window close event (cleanup orphaned tmux views)
	wezterm.on("mux-window-close", function(window_id)
		M.handle_mux_window_close(window_id)
	end)

	wezterm.log_info("[EVENT] Tab lifecycle handlers initialized")
end

return M
