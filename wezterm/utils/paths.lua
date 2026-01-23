-- ~/.core/.sys/configs/wezterm/utils/paths.lua
-- Centralized path management using ChaosCore environment variables

local M = {}

-- Get environment variable with fallback
local function getenv(var, fallback)
	return os.getenv(var) or fallback
end

-- Core paths from environment
M.HOME = getenv("HOME", os.getenv("USERPROFILE"))
M.CORE_CFG = getenv("CORE_CFG", M.HOME .. "/.core/.sys/cfg")
M.CORE_ENV = getenv("CORE_ENV", M.HOME .. "/.core/.sys/")
M.CORE_PROJ = getenv("CORE_PROJ", M.HOME .. "/.core/.proj")
M.CORE_VAULT = getenv("CORE_VAULT", M.HOME .. "/.core/.vault")
M.CORE_WORK = getenv("CORE_WORK", M.HOME .. "/.core/.work")

-- WezTerm specific paths (all relative to CORECFG)
M.WEZTERM_CONFIG = M.CORE_CFG .. "/wezterm"
M.WEZTERM_DATA = M.WEZTERM_CONFIG .. "/.data"
M.WEZTERM_STATE = M.WEZTERM_CONFIG .. "/.state"
M.WEZTERM_SCRIPTS = M.WEZTERM_CONFIG .. "/modules/menus"  -- Migrated from /scripts to /modules/menus
M.WEZTERM_BACKDROPS = M.WEZTERM_CONFIG .. "/backdrops"
M.WEZTERM_SESSIONS = M.WEZTERM_CONFIG .. "/sessions"

-- WezTerm data files
M.THEMES_FILE = M.WEZTERM_DATA .. "/themes.json"
M.FAVORITES_FILE = M.WEZTERM_DATA .. "/favorite-themes.json"
M.DELETED_THEMES_FILE = M.WEZTERM_DATA .. "/deleted-themes.json"
M.BACKGROUNDS_FILE = M.WEZTERM_DATA .. "/backgrounds.json"
M.BACKDROP_STATE_FILE = M.WEZTERM_DATA .. "/.backdrop_state"
M.METADATA_BACKUP_DIR = M.WEZTERM_DATA .. "/metadata-backups"

-- WezTerm tab data
M.TABS_DATA = M.WEZTERM_DATA .. "/tabs"
M.TAB_TEMPLATES_FILE = M.TABS_DATA .. "/templates.json"
M.TAB_COLORS_FILE = M.TABS_DATA .. "/colors.json"
M.TAB_METADATA_FILE = M.TABS_DATA .. "/metadata.json"

-- WezTerm tab scripts
M.TAB_METADATA_BROWSER_SCRIPT = M.WEZTERM_CONFIG .. "/scripts/tab-metadata-browser/browser.sh"

-- WezTerm session data
M.SESSIONS_DIR = M.WEZTERM_DATA .. "/sessions"
M.WORKSPACE_TEMPLATES_DIR = M.WEZTERM_DATA .. "/workspace-templates"
M.WORKSPACE_THEMES_DIR = M.WEZTERM_DATA .. "/workspace-themes"

-- WezTerm scripts
M.GENERATE_METADATA_SCRIPT = M.WEZTERM_CONFIG .. "/modules/menus/utilities/generate-image-metadata.sh"

-- Local core state directories (ephemeral runtime data)
-- Per environment-hierarchy.md: ephemeral state goes to ~/.local/core/
M.LOCAL_CORE = M.HOME .. "/.local/core"
M.LOCAL_CORE_STATE = M.LOCAL_CORE .. "/state"
M.LOCAL_CORE_DATA = M.LOCAL_CORE .. "/data"
M.LOCAL_CORE_CACHE = M.LOCAL_CORE .. "/cache"
M.LOCAL_WEZTERM_STATE = M.LOCAL_CORE_STATE .. "/wezterm"
M.LOCAL_WEZTERM_SESSIONS = M.LOCAL_WEZTERM_STATE .. "/sessions"

-- Common config directories (for launch menu)
M.ZSH_CONFIG = M.CORE_CFG .. "/zsh"
M.HYPR_CONFIG = M.CORE_ENV .. "/desktop/hypr"
M.NVIM_CONFIG = M.CORE_CFG .. "/nvim"
M.TMUX_CONFIG = M.CORE_CFG .. "/tmux"
M.YAZI_CONFIG = M.CORE_CFG .. "/yazi"

M.MUSIC_TUI = M.CORE_CFG .. "/media/spotify-player"
M.GITHUB_COPILOT_CONFIG = M.CORE_CFG .. "/github-copilot"

-- ============================================================================
-- PATH UTILITY FUNCTIONS
-- ============================================================================

--- Extract filesystem path from file:// URL or return as-is
--- Handles WezTerm's various CWD formats:
---   - file://hostname/path/to/dir
---   - file:///path/to/dir
---   - /path/to/dir (passthrough)
---   - {file_path = "/path/to/dir"} (table format)
---@param cwd any The CWD value from pane:get_current_working_dir()
---@return string The extracted filesystem path
function M.extract_path(cwd)
	if not cwd then
		return M.HOME
	end

	-- Handle table format with file_path (WezTerm URL object)
	if type(cwd) == "table" and cwd.file_path then
		return cwd.file_path
	end

	-- Convert to string
	cwd = tostring(cwd)

	-- Handle file:// URLs
	if cwd:match("^file://") then
		-- Remove file://hostname prefix (handles both file://hostname/path and file:///path)
		local path = cwd:gsub("^file://[^/]*", "") or cwd:gsub("^file://", "")
		return path
	end

	return cwd
end

--- Ensure a directory exists, creating it if necessary
---@param dir string The directory path to ensure
---@return boolean success Whether the directory exists or was created
function M.ensure_dir(dir)
	os.execute('mkdir -p "' .. dir .. '"')
	return true
end

return M
