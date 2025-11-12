-- File: ~/.core/cfg/wezterm/mdi_icons.lua
-- WezTerm module that provides corrected Material Design Icons mappings (mdi_* → md_*)
-- This fixes the missing icons issue caused by Nerd Fonts v3.0.0 breaking changes
--
-- ⚠️  LEGACY COMPATIBILITY LAYER - Limited to ~112 common icons
--
-- PURPOSE:
--   This module helps migrate old code that uses deprecated mdi_* icon names
--   to the new md_* format introduced in Nerd Fonts v3.0.0
--
-- USAGE:
--   Only use this for backward compatibility with existing code.
--   For new icon selections, use:
--   - tab_rename.lua (session manager icon picker) - 10,700+ icons
--   - scripts/nerdfont-browser/wezterm-browser.sh (bash FZF picker)
--
-- NOTE:
--   All Material Design icons (6,880+) are available via wezterm.nerdfonts.md_*
--   This module only provides a curated subset for common use cases.
--

local wezterm = require("wezterm")

-- Material Design Icons mapping from old mdi_* to new md_* format
local mdi_icons = {
	-- Common file and folder icons
	mdi_folder = wezterm.nerdfonts.md_folder,
	mdi_folder_open = wezterm.nerdfonts.md_folder_open,
	mdi_file = wezterm.nerdfonts.md_file,
	mdi_file_document = wezterm.nerdfonts.md_file_document,
	mdi_file_code = wezterm.nerdfonts.md_file_code,

	-- Vector and design icons
	mdi_vector_polyline = wezterm.nerdfonts.md_vector_polyline,
	mdi_vector_triangle = wezterm.nerdfonts.md_vector_triangle,
	mdi_vector_circle = wezterm.nerdfonts.md_vector_circle,
	mdi_vector_square = wezterm.nerdfonts.md_vector_square,

	-- Terminal and development icons
	mdi_terminal = wezterm.nerdfonts.md_terminal,
	mdi_console = wezterm.nerdfonts.md_console,
	mdi_bash = wezterm.nerdfonts.md_bash,
	mdi_powershell = wezterm.nerdfonts.md_powershell,

	-- Git and version control
	mdi_git = wezterm.nerdfonts.md_git,
	mdi_github = wezterm.nerdfonts.md_github,
	mdi_gitlab = wezterm.nerdfonts.md_gitlab,
	mdi_source_branch = wezterm.nerdfonts.md_source_branch,
	mdi_source_commit = wezterm.nerdfonts.md_source_commit,
	mdi_source_merge = wezterm.nerdfonts.md_source_merge,

	-- System and hardware icons
	mdi_memory = wezterm.nerdfonts.md_memory,
	mdi_cpu = wezterm.nerdfonts.md_cpu_64_bit,
	mdi_harddisk = wezterm.nerdfonts.md_harddisk,
	mdi_network = wezterm.nerdfonts.md_network,
	mdi_wifi = wezterm.nerdfonts.md_wifi,

	-- Navigation and UI icons
	mdi_arrow_left = wezterm.nerdfonts.md_arrow_left,
	mdi_arrow_right = wezterm.nerdfonts.md_arrow_right,
	mdi_arrow_up = wezterm.nerdfonts.md_arrow_up,
	mdi_arrow_down = wezterm.nerdfonts.md_arrow_down,
	mdi_chevron_left = wezterm.nerdfonts.md_chevron_left,
	mdi_chevron_right = wezterm.nerdfonts.md_chevron_right,

	-- Status and notification icons
	mdi_bell = wezterm.nerdfonts.md_bell,
	mdi_alert = wezterm.nerdfonts.md_alert,
	mdi_check = wezterm.nerdfonts.md_check,
	mdi_close = wezterm.nerdfonts.md_close,
	mdi_information = wezterm.nerdfonts.md_information,
	mdi_warning = wezterm.nerdfonts.md_alert,

	-- Application icons
	mdi_application = wezterm.nerdfonts.md_application,
	mdi_database = wezterm.nerdfonts.md_database,
	mdi_web = wezterm.nerdfonts.md_web,
	mdi_browser = wezterm.nerdfonts.md_web,

	-- Time and calendar
	mdi_clock = wezterm.nerdfonts.md_clock,
	mdi_calendar = wezterm.nerdfonts.md_calendar,
	mdi_timer = wezterm.nerdfonts.md_timer,

	-- Programming languages
	mdi_language_python = wezterm.nerdfonts.md_language_python,
	mdi_language_javascript = wezterm.nerdfonts.md_language_javascript,
	mdi_language_typescript = wezterm.nerdfonts.md_language_typescript_original,
	mdi_language_rust = wezterm.nerdfonts.md_language_rust,
	mdi_language_go = wezterm.nerdfonts.md_language_go,

	-- Tools and utilities
	mdi_wrench = wezterm.nerdfonts.md_wrench,
	mdi_settings = wezterm.nerdfonts.md_cog,
	mdi_cog = wezterm.nerdfonts.md_cog,
	mdi_gear = wezterm.nerdfonts.md_cog,

	-- Media and content
	mdi_play = wezterm.nerdfonts.md_play,
	mdi_pause = wezterm.nerdfonts.md_pause,
	mdi_stop = wezterm.nerdfonts.md_stop,
	mdi_music = wezterm.nerdfonts.md_music,

	-- Security and access
	mdi_lock = wezterm.nerdfonts.md_lock,
	mdi_key = wezterm.nerdfonts.md_key,
	mdi_shield = wezterm.nerdfonts.md_shield,

	-- Common utility icons
	mdi_home = wezterm.nerdfonts.md_home,
	mdi_user = wezterm.nerdfonts.md_account,
	mdi_account = wezterm.nerdfonts.md_account,
	mdi_search = wezterm.nerdfonts.md_magnify,
	mdi_plus = wezterm.nerdfonts.md_plus,
	mdi_minus = wezterm.nerdfonts.md_minus,

	-- Battery icons
	mdi_battery = wezterm.nerdfonts.md_battery,
	mdi_battery_charging = wezterm.nerdfonts.md_battery_charging,
	mdi_battery_low = wezterm.nerdfonts.md_battery_20,

	-- Connection and sync
	mdi_sync = wezterm.nerdfonts.md_sync,
	mdi_download = wezterm.nerdfonts.md_download,
	mdi_upload = wezterm.nerdfonts.md_upload,
	mdi_cloud = wezterm.nerdfonts.md_cloud,
}

-- Helper function to get an icon safely
local function get_icon(icon_name)
	local icon = mdi_icons[icon_name]
	if icon then
		return icon
	else
		wezterm.log_warn("Icon not found: " .. icon_name .. ". Consider updating to use md_* format directly.")
		return "?" -- Fallback character
	end
end

-- Export the module
return {
	icons = mdi_icons,
	get = get_icon,

	-- Convenience functions for common use cases
	folder = function()
		return mdi_icons.mdi_folder
	end,
	file = function()
		return mdi_icons.mdi_file
	end,
	git = function()
		return mdi_icons.mdi_git
	end,
	terminal = function()
		return mdi_icons.mdi_terminal
	end,
	vector_polyline = function()
		return mdi_icons.mdi_vector_polyline
	end,

	-- Status icons
	ok = function()
		return mdi_icons.mdi_check
	end,
	warning = function()
		return mdi_icons.mdi_warning
	end,
	error = function()
		return mdi_icons.mdi_close
	end,
	info = function()
		return mdi_icons.mdi_information
	end,
}
