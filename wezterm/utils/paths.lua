-- ~/.core/.sys/configs/wezterm/utils/paths.lua
-- Centralized path management using ChaosCore environment variables

local M = {}

-- Get environment variable with fallback
local function getenv(var, fallback)
	return os.getenv(var) or fallback
end

-- Core paths from environment
M.HOME = getenv("HOME", os.getenv("USERPROFILE"))
M.CORECFG = getenv("CORECFG", M.HOME .. "/.core/.sys/configs")
M.COREENV = getenv("COREENV", M.HOME .. "/.core/.sys/environment")
M.COREDEV = getenv("COREDEV", M.HOME .. "/.core/.proj")
M.CORE_VAULT = getenv("CORE_VAULT", M.HOME .. "/.core/.vault")
M.CORE_WORK = getenv("CORE_WORK", M.HOME .. "/.core/.work")

-- WezTerm specific paths (all relative to CORECFG)
M.WEZTERM_CONFIG = M.CORECFG .. "/wezterm"
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

-- WezTerm scripts
M.GENERATE_METADATA_SCRIPT = M.WEZTERM_SCRIPTS .. "/generate-image-metadata.sh"

-- Common config directories (for launch menu)
M.ZSH_CONFIG = M.CORECFG .. "/zsh"
M.HYPR_CONFIG = M.COREENV .. "/desktop/hypr"
M.NVIM_CONFIG = M.CORECFG .. "/nvim"
M.TMUX_CONFIG = M.CORECFG .. "/tmux"
M.YAZI_CONFIG = M.CORECFG .. "/yazi"
M.NCSPOT_CONFIG = M.CORECFG .. "/media/ncspot"
M.GITHUB_COPILOT_CONFIG = M.CORECFG .. "/github-copilot"

return M
