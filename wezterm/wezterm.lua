local wezterm = require("wezterm") ---@type Wezterm
local Config = require("config")
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
require("resurrect").setup()
-- local copilot = require("modules.ai.CopilotChat")
-- copilot:setup({
-- 	api = {
-- 		provider = "copilot",
-- 		model = "claude-3-5-sonnet-20241022",
-- 		temperature = 0.1,
-- 		max_tokens = 4096,
-- 	},
-- })
-- Load event handlers (no .setup()!)
-- require("events.toggle-copilot") -- Just require to register wezterm.on(...)
require("events.workspace_theme_handler").setup() -- Theme management for workspaces
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
require("tabline_custom").setup(config)
-- require("launchers.workspace_launcher").setup(config)
local backdrops = require("backdrops")
backdrops:set_images_dir(paths.WEZTERM_BACKDROPS) -- Set correct wallpaper directory
backdrops:set_images()
backdrops:set_scroll_attachment(true) -- Enable parallax scrolling for tall images
-- Set initial backdrop in config
-- config.background = backdrops:initial_options(false) -- DISABLED: uncomment to re-enable backdrops

require("themes").setup()
require("modules.gui.overlay-mode-picker").setup()

-- Load event handlers
-- NOTE: Multiple update-status handlers will override each other!
-- Use unified handler instead of individual ones
require("events.update-status-unified").setup() -- Must be LAST to not be overridden
require("events.gui-startup").setup()
require("events.user-var").setup()
-- require("events.notifications").setup()

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
