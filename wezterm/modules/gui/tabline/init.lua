local wezterm = require('wezterm')
local debug_config = require('config.debug')
local DEBUG = debug_config.debug_mods_tabline or debug_config.debug_all

local M = {}

-- Add the parent directory to package path so 'tabline.X' requires work
local home = wezterm.config_dir
local modules_dir = home .. '/modules'
if not package.path:find(modules_dir, 1, true) then
  package.path = package.path .. ';' .. modules_dir .. '/?.lua;' .. modules_dir .. '/?/init.lua'
end
local gui_dir = modules_dir .. '/gui'
if not package.path:find(gui_dir, 1, true) then
  package.path = package.path .. ';' .. gui_dir .. '/?.lua;' .. gui_dir .. '/?/init.lua'
end

function M.setup(opts)
  if not wezterm.gui then
    if DEBUG then
      wezterm.log_info('Skipping tabline setup - not running in GUI context')
    end
    return
  end

  -- Load config first and set it before loading other modules
  local config = require('tabline.config')
  config.set(opts)

  -- Now we can safely load modules that depend on config
  local tabs = require('tabline.tabs')
  local component = require('tabline.component')
  local extension = require('tabline.extension')

  -- Load extensions
  if opts and opts.options and opts.options.extensions then
    for _, ext in ipairs(opts.options.extensions) do
      extension.load(ext)
    end
  end

  -- Register event handlers
  wezterm.on('format-tab-title', function(tab, tabs_list, panes, config_obj, hover, max_width)
    return tabs.set_title(tab, hover)
  end)

  wezterm.on('update-status', function(window, pane)
    component.set_status(window)
  end)

  return M
end

return M
