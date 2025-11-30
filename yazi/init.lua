-- ╭─────────────────────────────────────────────────────────╮
-- │                    YAZI INIT.LUA                        │
-- │     Complete plugin configuration with error handling   │
-- ╰─────────────────────────────────────────────────────────╯

-- ═══════════════════════════════════════════════════════════════
-- ADAPTIVE LAYOUT - Responsive to sidebar mode
-- ═══════════════════════════════════════════════════════════════

-- Detect if running in sidebar mode and adjust UI accordingly
local sidebar_mode = os.getenv("YAZI_SIDEBAR_MODE")
if sidebar_mode == "1" then
	-- Sidebar mode: optimized for narrow width
	-- Reduce UI elements, focus on file list
	-- The ratio will be managed by yazi.toml override
end

-- [[[ Logging Setup

error_log = os.getenv("YAZI_CONFIG_HOME") .. ".data/logs/plugin_errors.log"
plugin_log = os.getenv("YAZI_CONFIG_HOME") .. ".data/plugins.log"

local plugin_prefix = "[" .. "[PLUGIN]" .. "]"
local status_prefix = "[" .. "[STATUS]" .. "]"
local preview_prefix = "[" .. "[PREVIEW]" .. "]"
local nav_prefix = "[" .. "[NAV]" .. "]"
local fs_prefix = "[" .. "[FS]" .. "]"
local util_prefix = "[" .. "[UTIL]" .. "]"
local vcs_prefix = "[" .. "[VCS]" .. "]"
local media_prefix = "[" .. "[MEDIA]" .. "]"
local mime_prefix = "[" .. "[MIME]" .. "]"
local ui_prefix = "[" .. "[UI]" .. "]"
local keymap_prefix = "[" .. "[KEYMAP]" .. "]"
local layout_prefix = "[" .. "[LAYOUT]" .. "]"
local theme_prefix = "[" .. "[THEME]" .. "]"
local yazi_prefix = "[" .. "[YAZI]" .. "]"

local error_prefix = "[" .. "[ERROR]" .. "]"
local info_prefix = "[" .. "[INFO]" .. "] "
local warn_prefix = "[" .. "[WARN]" .. "] "
local debug_prefix = "[" .. "[DEBUG]" .. "]"

-- local ya = require("yazi.api")
-- local Status = require("yazi.ui.status")

-- ]]] End Logging Setup

-- [[[ Log Message Functions
-- Logging function
--
-- Logs messages to a file with timestamp and module context

-- @log_context_prefix: string - Log level or module prefix
-- @log_type_prefix: string - Information prefix
-- @module_name: string - The name of the module
-- @message: string - The log message
-- @return: nil
local function log_message(log_context_prefix, log_type_prefix, module_name, message)
	local log_msg = string.format(
		"[%s] %s %s '%s': %s\n",
		os.date("%Y-%m-%d %H:%M:%S"),
		log_context_prefix,
		log_type_prefix,
		module_name,
		message
	)
	local file = io.open(plugin_log, "a")
	if file then
		file:write(log_msg)
		file:close()
	end
end

-- ]]] End Log Message Functions

-- [[[ Plugin Safe Require

-- Safe require with error logging
local function safe_require(module_name)
	local success, result = pcall(require, module_name)
	if not success then
		local error_msg =
			log_message(plugin_prefix, error_prefix, module_name, "Failed to load. [OUTPUT]: " .. tostring(result))
		local file = io.open(plugin_log, "a")
		if file then
			file:write(error_msg)
			file:close()
		end
		return nil
	end
	return result
end

-- Safe require with existence check
local function safe_require_checked(module_name)
	local user = os.getenv("USER") or "theron"
	local home = "/home/" .. user or os.getenv("HOME") or "/home/theron"
	local core = os.getenv("CORE") or home .. "/.core"
	local path_to_cfg = os.getenv("CORE_CFG") or os.getenv("CORECFG") or core .. "/.sys/cfg" or core .. "/cfg"
	local yazi = os.getenv("YAZI_CONFIG_HOME")
		or path_to_cfg .. "/yazi"
		or core .. "/.sys/cfg/yazi"
		or core .. "/cfg/yazi"
	local yazi_plugins = yazi .. "/plugins"
	-- local yaz_dev = os.getenv("YAZI_DEV_HOME")
	--   or os.getenv("CORE_PROJ") .. "/
	--   or core .. "/.sys/cfg/yazi/dev"
	--   or core .. "/cfg/yazi/dev"

	local plugin_dir = yazi .. "/plugins/" .. module_name .. ".yazi"
	-- local plugin_dev = yazi .. "/dev/" .. module_ame .. ".yazi"

	-- Check plugins/ directory first, then dev/ directory
	local stat = io.popen("test -d '" .. plugin_dir .. "' && echo 'exists' ")
	-- '  || test -d '" .. plugin_dev .. )
	-- local exists = stat:read("*a"):match("exists")
	local exists = stat:read("*a"):match("exists") or false
	stat:close() -- Close the popen handle

	if not exists then
		return nil
	end

	return safe_require(module_name)
end

-- ]]] End Plugin Safe Require

-- [[[ Validate Functions

local function file_exists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

local function dir_exists(path)
	local ok, err, code = os.rename(path, path)
	if not ok then
		if code == 13 then
			-- Permission denied, but it exists
			return true
		end
		return false
	end
	local attr = lfs.attributes(path)
	return attr and attr.mode == "directory"
end

local function validate_key_mapping(keymap)
	-- Add validation logic here
	-- For example, check if the keymap is a non-empty string
	if type(keymap) == "string" and keymap ~= "" then
		return true
	else
		return false
	end
end

local function validate_color_code(color_code)
	-- Add validation logic here
	-- For example, check if the color code matches a hex pattern
	if type(color_code) == "string" and color_code:match("^#%x%x%x%x%x%x$") then
		return true
	else
		return false
	end
end

local function validate_option(option, valid_options)
	-- Check if the option is in the list of valid options
	for _, valid_option in ipairs(valid_options) do
		if option == valid_option then
			return true
		end
	end
	return false
end

local function validate_api_response(response, expected_keys)
	-- Check if the response contains all expected keys
	for _, key in ipairs(expected_keys) do
		if response[key] == nil then
			return false
		end
	end
	return true
end

local function validate_plugin_api(plugin, required_functions)
	-- Check if the plugin implements all required functions
	for _, func in ipairs(required_functions) do
		if type(plugin[func]) ~= "function" then
			return false
		end
	end
	return true
end

-- ]]] End Validate Functions

--- [[[ CONTEXT DETECTION

local function detect_context()
	-- Check if running inside Neovim
	-- 	if os.getenv("NVIM") then
	-- 		return "nvim"
	-- 	end
	--
	-- 	-- Check if in a git repository
	-- 	local git_check = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
	-- 	local is_git = git_check:read("*a"):match("true")
	-- 	git_check:close()
	-- 	if is_git then
	-- 		return "dev"
	-- 	end
	--
	-- 	-- Check if in media directories
	-- 	local cwd = os.getenv("PWD") or ""
	-- 	if cwd:match("/Pictures") or cwd:match("/Videos") or cwd:match("/Music") or cwd:match("/Downloads") then
	-- 		return "media"
	-- 	end
	--
	-- 	-- Check for file manager mode
	-- 	if os.getenv("YAZI_FM_MODE") then
	-- 		return "fm"
	-- 	end
	--
	return "default"
end

local context = detect_context()

-- ═══════════════════════════════════════════════════════════════
-- IMAGE PROTOCOL DETECTION AND CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

local function detect_image_protocol()
	local term = os.getenv("TERM") or ""
	local term_program = os.getenv("TERM_PROGRAM") or ""

	-- WezTerm detection
	if term:match("wezterm") or os.getenv("WEZTERM_EXECUTABLE") then
		-- Log successful initialization
		local success_log = string.format("[%s]  (context: %s)\n", os.date("%Y-%m-%d %H:%M:%S"), "Wezterm")
		local file = io.open(plugin_log, "a")
		if file then
			file:write(success_log)
			file:close()
		end
		Status:children_add(function(self)
			local h = self._current.hovered
			if h and h.link_to then
				return " -> " .. tostring(h.link_to)
			else
				return ""
			end
		end, 3300, Status.LEFT)
		return "ueberzug" -- WezTerm imgcat protocol
	end

	-- Tmux detection (not WezTerm)
	if os.getenv("TMUX") then
		-- Log successful initialization
		local success_log = string.format("[%s]  (context: %s)\n", os.date("%Y-%m-%d %H:%M:%S"), "TMUX")
		local file = io.open(error_log, "a")
		if file then
			file:write(success_log)
			file:close()
		end
		Status:children_add(function(self)
			local h = self._current.hovered
			if h and h.link_to then
				return " -> " .. tostring(h.link_to)
			else
				return ""
			end
		end, 3300, Status.LEFT)
		return "ueberzug"
	end

	-- Tmux detection (not WezTerm)
	if os.getenv("NVIM") then
		-- Log successful initialization
		local success_log = string.format("[%s]  (context: %s)\n", os.date("%Y-%m-%d %H:%M:%S"), "NVIM")
		local file = io.open(error_log, "a")
		if file then
			file:write(success_log)
			file:close()
		end
		Status:children_add(function(self)
			local h = self._current.hovered
			if h and h.link_to then
				return " -> " .. tostring(h.link_to)
			else
				return ""
			end
		end, 3300, Status.LEFT)
		return "ueberzug"
	end

	-- Kitty detection
	if term:match("kitty") or os.getenv("KITTY_WINDOW_ID") then
		-- Log successful initialization
		local success_log = string.format("[%s]  (context: %s)\n", os.date("%Y-%m-%d %H:%M:%S"), "Kitty")
		local file = io.open(error_log, "a")
		if file then
			file:write(success_log)
			file:close()
		end
		Status:children_add(function(self)
			local h = self._current.hovered
			if h and h.link_to then
				return " -> " .. tostring(h.link_to)
			else
				return ""
			end
		end, 3300, Status.LEFT)
		return "kitty"
	end

	-- Log successful initialization
	local success_log = string.format("[%s]  (context: %s)\n", os.date("%Y-%m-%d %H:%M:%S"), "N/A")
	local file = io.open(error_log, "a")
	if file then
		file:write(success_log)
		file:close()
	end
	Status:children_add(function(self)
		local h = self._current.hovered
		if h and h.link_to then
			return " -> " .. tostring(h.link_to)
		else
			return ""
		end
	end, 3300, Status.LEFT)

	-- Default to ueberzug
	return "ueberzug"
end

-- Set the detected image protocol (this was missing!)
local protocol = detect_image_protocol()
-- Note: The protocol is now set in yazi.toml [image] section
-- This detection is kept for future dynamic configuration if needed

-- ]]] End Image Protocol Detection

-- ═══════════════════════════════════════════════════════════════
-- CORE PLUGINS SETUP
-- ═══════════════════════════════════════════════════════════════

require("git"):setup()

--- [[[ Custom Linemode Definitons

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

function Linemode:size_and_mtime_and_git()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	local git_status = ""
	local st = require("git").state
	local url = self._file.url
	local repo = st.dirs[tostring(url.base or url.parent)]
	local code
	if repo then
		code = repo == require("git").CODES.excluded and require("git").CODES.ignored
			or st.repos[repo][tostring(url):sub(#repo + 2)]
	end
	if code then
		git_status = "[" .. tostring(code) .. "]"
	end

	return string.format("%s %s %s", size and ya.readable_size(size) or "-", time, git_status)
end

-- ]]] End Custom Linemode Definitions

-- Bookmarks Management (fzf-bookmarks) - fork of whoosh with v25+ API fixes
-- Now includes global key support and bookmark groups!

local home = os.getenv("HOME") or "/home/theron"
local yazi_config = os.getenv("YAZI_CONFIG_HOME") or home .. "/.core/cfg/yazi"
local bookmarks_dir = yazi_config .. "/.data/bookmarks"
local fzf_bookmarks = safe_require_checked("fzf-bookmarks")
if fzf_bookmarks then
	fzf_bookmarks:setup({
		bookmarks_dir = bookmarks_dir,
		auto_generate_global_keymap = true, -- Auto-generate global scope keybindings
		jump_notify = true,
		keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
		special_keys = {
			create_temp = "<Enter>",
			fuzzy_search = "<Space>",
			history = "<Tab>",
			previous_dir = "<Backspace>",
		},
		home_alias_enabled = true,
		path_truncate_enabled = false,
		path_max_depth = 3,
		fzf_path_truncate_enabled = false,
		fzf_path_max_depth = 5,
		path_truncate_long_names_enabled = false,
		fzf_path_truncate_long_names_enabled = false,
		path_max_folder_name_length = 20,
		fzf_path_max_folder_name_length = 20,
		history_size = 10,
		history_fzf_path_truncate_enabled = false,
		history_fzf_path_max_depth = 5,
		history_fzf_path_truncate_long_names_enabled = false,
		history_fzf_path_max_folder_name_length = 30,
	})
end

-- Smart Enter Plugin (no setup needed)
safe_require_checked("smart-enter")

-- Fuse Archive - Mount archives transparently
local fuse_archive = safe_require_checked("fuse-archive")
if fuse_archive then
	fuse_archive:setup({
		smart_enter = true, -- Enter files to open, directories to navigate
		mount_dir = os.getenv("HOME") .. "/mnt/archives",
	})
end

-- Smart Paste Plugin (no setup needed)
safe_require_checked("smart-paste")

-- Nvim Image Paste Plugin (custom dev plugin)
-- This plugin enhances yanking/pasting images for Neovim markdown workflows
-- safe_require_checked("nvim-image-paste")

-- Wallpaper Directory Plugin (custom dev plugin)
-- Allows opening directories with Thunar or using them for wallpaper cycling
safe_require_checked("wallpaper-dir")

-- Projects Management
local projects = safe_require_checked("projects")
if projects then
	projects:setup({
		save = {
			method = "yazi", -- or "lua"
		},
	})
end

-- Simple Tag System
local simple_tag = safe_require_checked("simple-tag")
if simple_tag then
	simple_tag:setup({
		tag_storage = os.getenv("HOME") .. "/.core/cfg/yazi/tags.json",
		mode = "icon", -- "icon", "text", or "hidden"
		color_scheme = {
			["!"] = { fg = "#ff5555", icon = "🔴" },
			["1"] = { fg = "#50fa7b", icon = "🟢" },
			["q"] = { fg = "#ffb86c", icon = "🟠" },
			["*"] = { fg = "#ff79c6", icon = "⭐" },
		},
	})
end

-- SSHFS Plugin
local sshfs = safe_require_checked("sshfs")
if sshfs then
	sshfs:setup({
		mount_dir = os.getenv("HOME") .. "/mnt",
		reconnect = true,
		compression = true,
	})
end

-- Full Border Plugin
-- Available styles: "rounded", "plain", "double", "heavy", "heavy-double", "ascii", "block", "double-rounded"
local full_border = safe_require_checked("full-border")
if full_border then
	full_border:setup({
		-- style = "plain", -- Try: "heavy", "double", "block", etc.
		-- style = "rounded", -- Try: "heavy", "double", "block", etc.
		-- style = "double", -- Try: "heavy", "double", "block", etc.
		style = "double-plain", -- Try: "heavy", "double", "block", etc.
		-- style = "heavy", -- Try: "heavy", "double", "block", etc.
		-- style = "heavy-plain", -- Try: "heavy", "double", "block", etc.
		-- style = "heavy-double", -- Try: "heavy", "double", "block", etc.
		-- style = "heavy-light", -- Try: "heavy", "double", "block", etc.
		-- style = "block", -- Try: "heavy", "double", "block", etc.
		-- style = "ascii", -- Try: "heavy", "double", "block", etc.
		color = "#66FFB3",
	})
end

-- Lazy Git
safe_require_checked("lazygit")

-- Git Files
safe_require_checked("git-files")

-- ═══════════════════════════════════════════════════════════════
-- FILE OPERATIONS PLUGINS
-- ═══════════════════════════════════════════════════════════════

safe_require_checked("sudo")
safe_require_checked("rsync")
safe_require_checked("chmod")
safe_require_checked("reflink")
safe_require_checked("ouch") -- Archive management
safe_require_checked("compress")

-- ═══════════════════════════════════════════════════════════════
-- NAVIGATION PLUGINS
-- ═══════════════════════════════════════════════════════════════

safe_require_checked("fzf")
safe_require_checked("zoxide")
safe_require_checked("cdhist")
safe_require_checked("jump-to-char")
safe_require_checked("relative-motions")

-- ═══════════════════════════════════════════════════════════════
-- UI ENHANCEMENT PLUGINS
-- ═══════════════════════════════════════════════════════════════

-- Auto Layout (responsive layout)
-- DISABLED: May interfere with preview pane
-- To enable, uncomment the line below and test if preview still works
-- safe_require_checked("auto-layout")

-- Dual Pane Plugin - NOT INSTALLED
-- To install: add to package.toml and run `ya pack -i`
-- safe_require_checked("dual-pane")

-- Toggle/Zoom (called on-demand, no pre-loading needed)
safe_require_checked("toggle-pane") -- sync plugin, loaded on use
safe_require_checked("zoom")

-- ═══════════════════════════════════════════════════════════════
-- PREVIEW PLUGINS
-- ═══════════════════════════════════════════════════════════════

safe_require_checked("exifaudio")
safe_require_checked("mediainfo")
safe_require_checked("glow") -- Markdown preview
safe_require_checked("duckdb") -- Database/CSV/JSON preview
safe_require_checked("rich-preview")
safe_require_checked("thumbnail")

-- Eza Preview - DISABLED: causes preview issues
-- The eza-preview plugin interferes with the normal preview functionality
-- Uncomment below to enable (but may break preview pane)
-- local eza_preview = safe_require_checked("eza-preview")
-- if eza_preview then
-- 	eza_preview:setup({
-- 		default_tree = true,
-- 		level = 3,
-- 		follow_symlinks = true,
-- 		all = true,
-- 		ignore_glob = {},
-- 		git_ignore = true,
-- 		git_status = false,
-- 	})
-- end

-- require("eza-preview"):setup()

-- ═══════════════════════════════════════════════════════════════
-- UTILITY PLUGINS
-- ═══════════════════════════════════════════════════════════════

-- Yazibar Sync - Mirrors navigation to right sidebar (for dual sidebar setup)
safe_require_checked("yazibar-sync")

safe_require_checked("kdeconnect-send")
-- safe_require_checked("kdeconnect-mount")
safe_require_checked("command")
safe_require_checked("what-size")
safe_require_checked("fs-usage")
safe_require_checked("time-travel")
safe_require_checked("recycle-bin")
safe_require_checked("restore")
safe_require_checked("thunar-bulk-rename")
safe_require_checked("fast-enter")
safe_require_checked("piper")
safe_require_checked("smart-filter")

-- ═══════════════════════════════════════════════════════════════
-- MOUNT/FILESYSTEM PLUGINS
-- ═══════════════════════════════════════════════════════════════

safe_require_checked("mount")
safe_require_checked("gvfs")
safe_require_checked("simple-mtpfs")

-- ═══════════════════════════════════════════════════════════════
-- MEDIA/IMAGE VIEWERS
-- ═══════════════════════════════════════════════════════════════

safe_require_checked("sxiv")
safe_require_checked("allmytoes")

-- ═══════════════════════════════════════════════════════════════
-- MIME/TYPE PLUGINS
-- ═══════════════════════════════════════════════════════════════

safe_require_checked("mime-ext")
-- Note: types plugin doesn't export a proper module, loaded automatically by Yazi
-- safe_require_checked("types")

-- ═══════════════════════════════════════════════════════════════
-- VCS PLUGINS
-- ═══════════════════════════════════════════════════════════════

safe_require_checked("vcs-files")
safe_require_checked("diff")

require("mux"):setup({
	aliases = {
		eza_tree_1 = {
			previewer = "piper",
			args = {
				'cd "$1" && LS_COLORS="ex=32" eza --oneline --tree --level 1 --color=always --icons=always --group-directories-first --no-quotes .',
			},
		},
		eza_tree_2 = {
			previewer = "piper",
			args = {
				'cd "$1" && LS_COLORS="ex=32" eza --oneline --tree --level 2 --color=always --icons=always --group-directories-first --no-quotes .',
			},
		},
		eza_tree_3 = {
			previewer = "piper",
			args = {
				'cd "$1" && LS_COLORS="ex=32" eza --oneline --tree --level 3 --color=always --icons=always --group-directories-first --no-quotes .',
			},
		},
		eza_tree_4 = {
			previewer = "piper",
			args = {
				'cd "$1" && LS_COLORS="ex=32" eza --oneline --tree --level 4 --color=always --icons=always --group-directories-first --no-quotes .',
			},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- STATUS LINE (YATLINE) CONFIGURATION
-- ═══════════════════════════════════════════════════════════════

-- Load yatline and its components
safe_require_checked("yatline")
safe_require_checked("yatline-githead")
safe_require_checked("yatline-hostname-username")
safe_require_checked("yatline-tab-path")

-- Load simple-status as fallback
safe_require_checked("simple-status")

local pref_by_location = safe_require_checked("pref-by-location")
-- pref_by_location:setup({
-- 	-- Disable this plugin completely.
-- 	-- disabled = false -- true|false (Optional)
--
-- 	-- Hide "enable" and "disable" notifications.
-- 	-- no_notify = false -- true|false (Optional)
--
-- 	-- Disable the fallback/default preference (values in `yazi.toml`).
-- 	-- This mean if none of the saved or predifined perferences is matched,
-- 	-- then it won't reset preference to default values in yazi.toml.
-- 	-- For example, go from folder A to folder B (folder B matchs saved preference to show hidden files) -> show hidden.
-- 	-- Then move back to folder A -> keep showing hidden files, because the folder A doesn't match any saved or predefined preference.
-- 	-- disable_fallback_preference = false -- true|false|nil (Optional)
--
-- 	-- You can backup/restore this file. But don't use same file in the different OS.
-- 	-- save_path =  -- full path to save file (Optional)
-- 	--       - Linux/MacOS: os.getenv("HOME") .. "/.config/yazi/pref-by-location"
-- 	--       - Windows: os.getenv("APPDATA") .. "\\yazi\\config\\pref-by-location"
--
-- 	-- This is predefined preferences.
-- 	prefs = { -- (Optional)
-- 		-- location: String | Lua pattern (Required)
-- 		--   - Support literals full path, lua pattern (string.match pattern): https://www.lua.org/pil/20.2.html
-- 		--     And don't put ($) sign at the end of the location. %$ is ok.
-- 		--   - If you want to use special characters (such as . * ? + [ ] ( ) ^ $ %) in "location"
-- 		--     you need to escape them with a percent sign (%) or use a helper funtion `pref_by_location.is_literal_string`
-- 		--     Example: "/home/test/Hello (Lua) [world]" => { location = "/home/test/Hello %(Lua%) %[world%]", ....}
-- 		--     or { location = pref_by_location.is_literal_string("/home/test/Hello (Lua) [world]"), .....}
--
-- 		-- sort: {} (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.sort_by
-- 		--   - extension: "none"|"mtime"|"btime"|"extension"|"alphabetical"|"natural"|"size"|"random", (Optional)
-- 		--   - reverse: true|false (Optional)
-- 		--   - dir_first: true|false (Optional)
-- 		--   - translit: true|false (Optional)
-- 		--   - sensitive: true|false (Optional)
--
-- 		-- linemode: "none" |"size" |"btime" |"mtime" |"permissions" |"owner" (Optional) https://yazi-rs.github.io/docs/configuration/yazi#mgr.linemode
-- 		--   - Custom linemode also work. See the example below
-- 		{ location = ".*/Downloads", sort = { "mtime", reverse = true, dir_first = true } },
-- 	},
-- })

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION COMPLETE
-- ═══════════════════════════════════════════════════════════════

-- Log successful initialization
local success_log =
	string.format("[%s] Yazi init.lua loaded successfully (context: %s)\n", os.date("%Y-%m-%d %H:%M:%S"), context)
local file = io.open(error_log, "a")
if file then
	file:write(success_log)
	file:close()
end
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

--
-- [[plugin.deps]]
-- use = "yazi-rs/plugins:toggle-pane"
-- rev = "d1c8baa"
-- hash = "8a7c58225816a163a6e8730c0adafbc8"
--
--
-- [[plugin.deps]]
-- use = "ahkohd/eza-preview"
-- rev = "a97cf55"
-- hash = "cc3aef07a8b1c3fe820f1fbb9a5a2483"
--
--
-- [[plugin.deps]]
-- use = "dawsers/dual-pane"
-- rev = "c2fed12"
-- hash = "1ed3f74cb5e894cfa0ea8e0326a89b3c"
