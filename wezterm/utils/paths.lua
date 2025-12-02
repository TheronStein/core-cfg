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
M.WEZTERM_SCRIPTS = M.WEZTERM_CONFIG .. "/scripts"
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

-- WezTerm session data
M.SESSIONS_DIR = M.WEZTERM_DATA .. "/sessions"
M.WORKSPACE_TEMPLATES_DIR = M.WEZTERM_DATA .. "/workspace-templates"
M.WORKSPACE_THEMES_DIR = M.WEZTERM_DATA .. "/workspace-themes"

-- WezTerm scripts
M.GENERATE_METADATA_SCRIPT = M.WEZTERM_SCRIPTS .. "/generate-image-metadata.sh"

-- Common config directories (for launch menu)
M.ZSH_CONFIG = M.CORE_CFG .. "/zsh"
M.HYPR_CONFIG = M.CORE_ENV .. "/desktop/hypr"
M.NVIM_CONFIG = M.CORE_CFG .. "/nvim"
M.TMUX_CONFIG = M.CORE_CFG .. "/tmux"
M.YAZI_CONFIG = M.CORE_CFG .. "/yazi"

M.MUSIC_TUI = M.CORE_CFG .. "/media/spotify-player"
M.GITHUB_COPILOT_CONFIG = M.CORE_CFG .. "/github-copilot"

return M
