local wezterm = require("wezterm") ---@type Wezterm
local Config = require("config.init")
local debug_config = require("config.debug")
local paths = require("utils.paths")
-- local tabline_config = require("tabline")
local conf_dir = wezterm.config_dir
local modules_dir = conf_dir .. "/modules"
if not package.path:find(modules_dir, 1, true) then
  package.path = package.path .. ";" .. modules_dir .. "/?.lua;" .. modules_dir .. "/?/init.lua"
end
local gui_dir = modules_dir .. "/gui"
if not package.path:find(gui_dir, 1, true) then
  package.path = package.path .. ";" .. gui_dir .. "/?.lua;" .. gui_dir .. "/?/init.lua"
end
-- Add the core path to package path if not already there
local home = wezterm.home_dir
local core_env_dir = paths.WEZTERM_CONFIG
local core_env_path = home .. "/?.lua" -- .. '/core/?/init.luaa'
-- if not package.path:find(core_cfg_path, true) then
-- 	package.path = package.path .. ";" .. core_cfg_path
--     config_dir = core_env_dir
-- end
-- package.path = package.path .. ';' .. keymaps_dir .. '/?.lua;' .. keymaps_dir .. '/?/init.lua'

if debug_config.is_enabled("debug_config_init") then
  wezterm.log_info("[CONFIG] Home: " .. wezterm.home_dir)
  wezterm.log_info("[CONFIG] Config dir: " .. wezterm.config_dir)
end
-- local keymaps_dir = wezterm.home_dir .. '/keymaps'
-- if not package.path:find(keymaps_dir, 1, true) then
--     local load_keymaps = true
-- end

-- Load custom icons early to inject into wezterm.nerdfonts
-- require("modules.custom_icons")

-- Setup tabline
-- require("resurrect").setup()
-- local copilot = require("modules.ai.CopilotChat")
-- copilot:setup({
-- 	api = {
-- 		provider = "copilot",
-- 		model = "claude-3-5-sonnet-20241022",
-- 		temperature = 0.1,
-- 		max_tokens = 4096,
-- 	},
-- })
-- ============================================================================
-- LOAD CONSOLIDATED EVENT HANDLERS
-- ============================================================================
-- All event handlers have been consolidated to avoid conflicts where multiple
-- files register handlers for the same WezTerm event (only the LAST one runs!)
--
-- Event handler organization:
--   - update-status.lua        : THE unified update-status handler
--   - user-var-changed.lua     : THE unified user-var-changed handler
--   - window-lifecycle.lua     : window-created, window-config-reloaded, window-close, window-focus-changed
--   - gui-lifecycle.lua        : gui-startup, gui-shutdown, copilot-chat.prompt-input
--   - workspace-lifecycle.lua  : workspace-switched, workspace-created, workspace-changed, workspace-save-now, workspace-mark-dirty
--   - tab-lifecycle.lua        : format-tab-title, mux-tab-closed, mux-window-close
--   - custom-events.lua        : backdrop-refresh, start-theme-watcher, toggle-copilot, update-mode, refresh-tabline, reload-tabline-themes
--   - navigation.lua           : open-uri, key-event
--   - tmux-integration.lua     : tmux-session-renamed, tmux-session-deleted, smart_workspace_switcher.*
--   - mode-display.lua         : (kept separate for compatibility)

require("events.update-status").setup()           -- Must be loaded to handle update-status event
require("events.user-var-changed").setup()        -- Must be loaded to handle user-var-changed event
require("events.window-lifecycle").setup()        -- Must be loaded to handle window lifecycle events
require("events.gui-lifecycle").setup()           -- Must be loaded to handle GUI lifecycle events
require("events.workspace-lifecycle").setup()     -- Must be loaded to handle workspace events (includes auto-save)
require("events.tab-lifecycle").setup()           -- Must be loaded to handle tab events
require("events.custom-events").setup()           -- Must be loaded to handle custom events
require("events.navigation").setup()              -- Must be loaded to handle navigation events
require("events.tmux-integration").setup()        -- Must be loaded to handle TMUX integration

-- Build and return configuration
local config_builder = Config
  :init()
  :append(require("config.environment"))
  :append(require("config.appearance"))
  -- :append(require("config.binds"))  -- Replaced with keymaps system
  :append(require("config.general"))
  :append(require("config.launch"))

-- Setup keymaps (new modular keymaps system)
require("keymaps").setup(config_builder.options)

local config = config_builder.options

-- if load_keymaps then
--  local keys = Keymaps.init()
--     :append(require("keymaps.unmaps"))
--     :append(require("keymaps.leader"))
--     :append(require("keymaps.ctrl"))
--     :append(require("keymaps.ctrl-shift")).keys -- This is your version of ".options"!
-- end

-- Modules
require("tabline.tabline_custom").setup(config)
-- require("launchers.workspace_launcher").setup(config)
local backdrops = require("modules.gui.backdrops")
backdrops:set_images_dir(paths.WEZTERM_BACKDROPS) -- Set correct wallpaper directory
backdrops:set_images()
backdrops:set_scroll_attachment(true) -- Enable parallax scrolling for tall images
-- Set initial backdrop in config
-- config.background = backdrops:initial_options(false) -- DISABLED: uncomment to re-enable backdrops

require("modules.gui.overlay-mode-picker").setup()

-- Initialize tab template hooks system
local tab_hooks = require("modules.tabs.tab_hooks")
tab_hooks.initialize()

-- NOTE: Event handlers are now loaded earlier in this file (see LOAD CONSOLIDATED EVENT HANDLERS section above)
-- The old individual event files have been consolidated to avoid handler conflicts

-- if not package.path:find(core_cfg_path, true) then
-- package.path = package.path .. ";" ..
--     config_dir = core_env_dir
-- end

-- require("events.right-status").setup()  -- Handled by tabline now
-- require("events.tab-title").setup()      -- Handled by tabline now
-- require("events.new-tab-button").setup()

-- local nfparser = require("generate_nerdfonts.lua").generate()

-- Generate nerdfonts.json on startup
-- local nfparser = require 'generate_nerdfonts'
-- local json_output = nfparser.generate()
-- local file = io.open('nerdfonts.json', 'w')
-- if file then
--   file:write(json_output)
--   file:close()
--   wezterm.log_info('Generated nerdfonts.json')
-- else
--   wezterm.log_error('Failed to write nerdfonts.json')
-- end

return config
