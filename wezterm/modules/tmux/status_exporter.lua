-- WezTerm to tmux status bar exporter
-- Exports WezTerm mode/context information for tmux status bar consumption

local wezterm = require("wezterm")
local mode_module = require("modules.gui.tabline.components.window.mode")

local M = {}

-- Where to write the status information for tmux to read
local STATUS_FILE = os.getenv("XDG_RUNTIME_DIR") .. "/wezterm-tmux-status"

-- Format colors for tmux status bar (using your existing color scheme)
local COLORS = {
	leader = { fg = "#DDB863", bg = "#4D908E" }, -- duskyellow on jewelcyan
	normal = { fg = "#1A1A1A", bg = "#4D908E" }, -- baseblack on jewelcyan
	resize = { fg = "#1A1A1A", bg = "#D4F88D" }, -- baseblack on limeyellow
	select = { fg = "#1A1A1A", bg = "#8EBAA8" }, -- baseblack on softcyan
	copy = { fg = "#1A1A1A", bg = "#000000" }, -- baseblack on black (from prefix-highlight)
	other = { fg = "#1A1A1A", bg = "#7FCDCD" }, -- baseblack on duskaqua
}

-- Icons for different modes
local ICONS = {
	leader = "⌨",
	normal = "⌨",
	resize = "",
	select = "",
	copy = "C",
	search = "",
}

-- Generate tmux status format string for mode indicator
local function format_mode_segment(window)
	local mode = mode_module.get(window)
	local display_mode = mode:gsub("_mode", ""):upper()

	-- Determine which color scheme to use
	local color_key = "normal"
	if mode == "leader_mode" then
		color_key = "leader"
	elseif mode:find("resize") then
		color_key = "resize"
	elseif mode:find("select") or mode:find("pane_select") then
		color_key = "select"
	elseif mode:find("copy") then
		color_key = "copy"
	elseif mode ~= "core_mode" then
		color_key = "other"
	end

	local colors = COLORS[color_key]
	local icon = ICONS[color_key] or ICONS.normal

	-- Generate tmux format string
	-- This matches the style from your current status-left
	local tmux_format = string.format(
		"#[bold,fg=%s,bg=%s] %s %s ",
		colors.fg,
		colors.bg,
		icon,
		display_mode
	)

	return tmux_format
end

-- Get context information (like tmux mode detection)
local function get_context_info(window, pane)
	local context = {}

	-- Check if we're in a tmux session
	local user_vars = pane:get_user_vars()
	context.in_tmux = user_vars.TMUX ~= nil or os.getenv("TMUX") ~= nil

	-- Get current workspace
	local workspace = window:active_workspace()
	context.workspace = workspace

	-- Get domain
	local domain = pane:get_domain_name() or "Unknown"
	context.domain = domain

	return context
end

-- Write status information to file for tmux to consume
local function write_status_file(mode_segment, context)
	local file = io.open(STATUS_FILE, "w")
	if file then
		-- Write mode segment
		file:write("MODE=" .. mode_segment .. "\n")
		-- Write context info
		file:write("IN_TMUX=" .. tostring(context.in_tmux) .. "\n")
		file:write("WORKSPACE=" .. context.workspace .. "\n")
		file:write("DOMAIN=" .. context.domain .. "\n")
		file:close()
	end
end

-- Main update function called from update-status event
function M.update(window, pane)
	-- Only export if we're in a tmux session
	local user_vars = pane:get_user_vars()
	local in_tmux = user_vars.TMUX ~= nil or os.getenv("TMUX") ~= nil

	if not in_tmux then
		return
	end

	local mode_segment = format_mode_segment(window)
	local context = get_context_info(window, pane)

	write_status_file(mode_segment, context)
end

-- Setup function to register event handler
function M.setup()
	wezterm.on("tmux-status-export", function(window, pane)
		M.update(window, pane)
	end)
end

return M
