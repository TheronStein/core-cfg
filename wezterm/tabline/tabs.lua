local config = require("tabline.config")
local util = require("tabline.util")
local extension = require("tabline.extension")

local M = {}

local left_tab_separator = { Text = config.opts.options.tab_separators.left or config.opts.options.tab_separators }
local right_tab_separator = { Text = config.opts.options.tab_separators.right or config.opts.options.tab_separators }
local active_attributes, inactive_attributes, active_separator_attributes, inactive_separator_attributes =
	{}, {}, {}, {}
local tab_active, tab_inactive = {}, {}

local function create_attributes(hover)
	local colors = config.theme.tab
	for _, ext in pairs(extension.extensions) do
		if ext.theme and ext.theme.tab then
			colors = util.deep_extend(util.deep_copy(colors), ext.theme.tab)
		end
	end

	-- Tmux-style colors: icon section and content section
	local content_bg = "#444267"
	local content_fg = "#cdd6f4"
	local bg_tab_bar = "#444267"

	local icon_bg_inactive = "#5b4996"
	local icon_fg_inactive = "#FFFFFF"

	active_attributes = {
		{ Foreground = { Color = colors.active.fg } },
		{ Background = { Color = colors.active.bg } },
	}
	inactive_attributes = {
		{ Foreground = { Color = hover and colors.inactive_hover.fg or colors.inactive.fg } },
		{ Background = { Color = hover and colors.inactive_hover.bg or colors.inactive.bg } },
	}
	active_separator_attributes = {
		{ Foreground = { Color = colors.active.bg } },
		{ Background = { Color = bg_tab_bar } },
	}
	inactive_separator_attributes = {
		{ Foreground = { Color = hover and colors.inactive_hover.bg or colors.inactive.bg } },
		{ Background = { Color = bg_tab_bar } },
	}
end

local function create_tab_content(tab)
	local sections = config.sections
	for _, ext in pairs(extension.extensions) do
		if ext.sections then
			sections = util.deep_extend(util.deep_copy(sections), ext.sections)
		end
	end
	tab_active = util.extract_components(sections.tab_active, active_attributes, tab)
	tab_inactive = util.extract_components(sections.tab_inactive, inactive_attributes, tab)
end

local function tabs(tab)
	local result = {}
	local wezterm = require("wezterm")

	-- Use mode colors for tabs
	local bg_tab_bar = "#292D3E"

	-- Use powerline glyphs for consistent height with tabline dividers
	local left_arrow = wezterm.nerdfonts.pl_left_hard_divider
	local right_arrow = wezterm.nerdfonts.pl_right_hard_divider

	-- Helper function to dim a color (reduce saturation/brightness)
	local function dim_color(hex)
		local r = tonumber(hex:sub(2, 3), 16)
		local g = tonumber(hex:sub(4, 5), 16)
		local b = tonumber(hex:sub(6, 7), 16)
		-- Reduce brightness by 40%
		r = math.floor(r * 0.6)
		g = math.floor(g * 0.6)
		b = math.floor(b * 0.6)
		return string.format("#%02x%02x%02x", r, g, b)
	end

	-- Get tab ID first (needed for per-tab mode lookup)
	local tab_id = tostring(tab.tab_id)

	-- Get THIS TAB's mode from per-tab state
	local tab_mode_state = require("modules.utils.tab_mode_state")
	local tab_state = tab_mode_state.get_tab_mode(tab_id)

	-- Each tab displays its own stored mode
	-- Active tab: Shows current live mode (including transient states like leader_mode)
	-- Inactive tabs: Show their own base_mode (independent of active tab's mode)
	local tab_mode
	if tab.is_active then
		-- Active tab shows the live current mode (may include leader_mode, etc.)
		tab_mode = wezterm.GLOBAL.current_mode or tab_state.base_mode or "wezterm_mode"
	else
		-- Inactive tabs ALWAYS show their OWN base_mode (per-tab independence)
		tab_mode = tab_state.base_mode or "wezterm_mode"
	end

	-- Get mode color directly from mode_colors module (single source of truth)
	local mode_colors_module = require("modules.utils.mode_colors")
	local mode_bg = mode_colors_module.get_color(tab_mode)
	local mode_fg = "#292D3E"  -- Default dark foreground

	-- Get tab metadata to check for workspace info
	local tab_meta = wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab_id]

	-- Color priority (highest to lowest):
	-- 1. tmux workspace color (if in tmux workspace)
	-- 2. custom tab color (from color picker)
	-- 3. per-tab mode color (each tab shows its own mode)

	-- Priority 1: Override mode color with workspace color if available (HIGHEST PRIORITY)
	if tab_meta and tab_meta.tmux_workspace_color then
		mode_bg = tab_meta.tmux_workspace_color
	else
		-- Priority 2: Use custom tab color if set (and not in tmux workspace)
		local ok_color_picker, color_picker = pcall(require, "modules.tabs.tab_color_picker")
		if ok_color_picker then
			local custom_color = color_picker.get_tab_color(tab_id)
			if custom_color then
				mode_bg = custom_color
			end
		end
		-- Priority 3: Per-tab mode color (already set above from tab_mode_state)
	end

	-- Helper function to truncate with ".." suffix
	local function truncate(str, max_len)
		if #str <= max_len then
			return str
		end
		return str:sub(1, max_len - 2) .. ".."
	end

	-- Get tmux workspace from tab metadata (tab_id and tab_meta already defined above)
	local tmux_workspace = tab_meta and tab_meta.tmux_workspace
	local tmux_workspaces = nil
	pcall(function()
		tmux_workspaces = require("modules.tmux.workspaces")
	end)

	-- Determine the icon to use (priority: tmux workspace icon > process icon)
	local display_icon = ""
	if tmux_workspace and tmux_workspaces then
		local workspace_info = tmux_workspaces.get_workspace_info(tmux_workspace)
		if workspace_info then
			display_icon = workspace_info.icon
		end
	end

	-- Fallback to process icon if not in tmux workspace
	if display_icon == "" then
		local process_comp = require("tabline.components.tab.process")
		local temp_opts = {
			icons_enabled = true,
			process_to_icon = process_comp.default_opts.process_to_icon,
		}
		process_comp.update(tab, temp_opts)
		display_icon = temp_opts.icon and (type(temp_opts.icon) == "table" and temp_opts.icon[1] or temp_opts.icon)
			or ""
	end

	-- Get tmux window name if in a tmux workspace
	local debug_config = require("config.debug")
	local tmux_window = ""
	local tmux_session = ""

	if debug_config.is_enabled("debug_tabline_tabs") then
		wezterm.log_info(
			"[TABLINE:TABS] tab_id:",
			tab.tab_id,
			"pane_id:",
			tab.active_pane.pane_id,
			"title:",
			tab.active_pane.title,
			"tmux_workspace:",
			tmux_workspace or "nil"
		)
	end

	if tmux_workspace then
		-- Store window/session info in global state indexed by tab_id
		-- This gets populated by the update-status event which has access to user vars
		local tab_tmux_info = wezterm.GLOBAL.tab_tmux_info and wezterm.GLOBAL.tab_tmux_info[tab_id]

		if debug_config.is_enabled("debug_tabline_tabs") then
			wezterm.log_info("[TABLINE:TABS] tab_tmux_info:", tab_tmux_info and "exists" or "nil")
			if tab_tmux_info then
				wezterm.log_info(
					"[TABLINE:TABS] session:",
					tab_tmux_info.session or "nil",
					"window:",
					tab_tmux_info.window or "nil"
				)
			end
		end

		if tab_tmux_info then
			tmux_window = tab_tmux_info.window or ""
			tmux_session = tab_tmux_info.session or ""
		end
	end

	-- Get tmux session name if we haven't gotten it from global state
	if tmux_workspace and tmux_session == "" then
		-- Fallback: just use the workspace name as session
		-- This will show "configuration/wezterm" instead of "0/wezterm"
		tmux_session = tmux_workspace
	end

	-- Determine the title text
	-- Priority: custom > tmux > default
	local title_text = ""
	local has_custom_title = false

	-- Check for custom title first (highest priority)
	if tab_meta and tab_meta.title then
		title_text = tab_meta.title
		has_custom_title = true

		-- If custom title AND has custom icon, override the display_icon
		if tab_meta.icon_key and tab_meta.icon_key ~= "" then
			display_icon = tab_meta.icon_key
		end
		-- Note: If in tmux workspace but no custom icon, tmux icon is preserved from above

		if debug_config.is_enabled("debug_tabline_tabs") then
			wezterm.log_info("[TABLINE:TABS] Using custom title:", title_text, "icon:", display_icon)
		end
	-- Fallback to tmux title (medium priority)
	elseif tmux_workspace and tmux_session ~= "" then
		-- Use shortname from workspace metadata if available
		local server_name = tmux_workspace
		if tmux_workspaces then
			local workspace_info = tmux_workspaces.get_workspace_info(tmux_workspace)
			if workspace_info and workspace_info.shortname then
				server_name = workspace_info.shortname
			end
		end
		title_text = server_name .. "/" .. tmux_session
	-- Fallback to default title (lowest priority)
	else
		-- Not in tmux: show CWD name
		local cwd_uri = tab.active_pane.current_working_dir
		if cwd_uri then
			local cwd_path = cwd_uri.file_path or cwd_uri
			title_text = cwd_path:match("([^/]+)/?$") or cwd_path
		end
		-- Fallback to process if no CWD
		if title_text == "" then
			local process = tab.active_pane.foreground_process_name or ""
			title_text = process:match("([^/]+)$") or process
		end
	end

	local title = truncate(title_text, 14)

	-- Check for zoomed pane
	local zoomed = ""
	for _, pane in ipairs(tab.panes) do
		if pane.is_zoomed then
			zoomed = "⬢ "
			break
		end
	end

	-- Helper function to determine if background is bright (needs dark text)
	local function needs_dark_text(bg_color)
		-- Extract RGB values
		local r = tonumber(bg_color:sub(2, 3), 16)
		local g = tonumber(bg_color:sub(4, 5), 16)
		local b = tonumber(bg_color:sub(6, 7), 16)
		-- Calculate perceived brightness (0-255)
		local brightness = (r * 0.299 + g * 0.587 + b * 0.114)
		-- If brightness > 128, use dark text
		return brightness > 128
	end

	if tab.is_active then
		-- Active tab: entire background filled with mode color
		local tab_bg = mode_bg
		-- Use dark text for bright backgrounds (like green), dimmed light blue for dark backgrounds
		local tab_fg = needs_dark_text(tab_bg) and "#1e1e2e" or "#bac2de"

		-- Leading space
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = " " })
		-- Left arrow
		table.insert(result, { Foreground = { Color = tab_bg } })
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = "" })
		-- Entire tab content with mode bg and auto fg
		table.insert(result, { Foreground = { Color = tab_fg } })
		table.insert(result, { Background = { Color = tab_bg } })
		table.insert(result, { Text = "" .. zoomed .. display_icon .. "  " .. title .. "  " })
		-- Right arrow
		table.insert(result, { Foreground = { Color = tab_bg } })
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = "" })
		-- Trailing space
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = " " })
	else
		-- Inactive tab: dimmed mode color background
		local tab_bg = dim_color(mode_bg)
		-- Use dark text for bright backgrounds (like green), dimmed light blue for dark backgrounds
		local tab_fg = needs_dark_text(tab_bg) and "#1e1e2e" or "#bac2de"

		-- Leading space
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = " " })
		-- Left arrow
		table.insert(result, { Foreground = { Color = tab_bg } })
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = "" })
		-- Entire tab content with dimmed mode bg and auto fg
		table.insert(result, { Foreground = { Color = tab_fg } })
		table.insert(result, { Background = { Color = tab_bg } })
		table.insert(result, { Text = "" .. zoomed .. display_icon .. "  " .. title .. "  " })
		-- Right arrow
		table.insert(result, { Foreground = { Color = tab_bg } })
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = "" })
		-- Trailing space
		table.insert(result, { Background = { Color = bg_tab_bar } })
		table.insert(result, { Text = " " })
	end

	return result
end

M.set_title = function(tab, hover)
	if not config.opts.options.tabs_enabled then
		return
	end
	create_attributes(hover)
	create_tab_content(tab)
	return tabs(tab)
end

return M
