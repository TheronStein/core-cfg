local wezterm = require('wezterm')
local util = require('tabline.util')
local config = require('tabline.config')
local extension = require('tabline.extension')
local mode = require('tabline.components.window.mode')

local M = {}

-- Lazy getters for separators to avoid accessing config.opts before initialization
local function get_left_section_separator()
  return { Text = config.opts.options.section_separators.left or config.opts.options.section_separators }
end
local function get_right_section_separator()
  return { Text = config.opts.options.section_separators.right or config.opts.options.section_separators }
end
local function get_left_component_separator()
  return { Text = config.opts.options.component_separators.left or config.opts.options.component_separators }
end
local function get_right_component_separator()
  return { Text = config.opts.options.component_separators.right or config.opts.options.component_separators }
end

local attributes_a, attributes_b, attributes_c, attributes_x, attributes_y, attributes_z = {}, {}, {}, {}, {}, {}
local section_seperator_attributes_a, section_seperator_attributes_b, section_seperator_attributes_c, section_seperator_attributes_x, section_seperator_attributes_y, section_seperator_attributes_z =
  {}, {}, {}, {}, {}, {}
local section_seperator_attributes_c_to_tab, section_seperator_attributes_tab_to_x = {}, {}
local tabline_a, tabline_b, tabline_c, tabline_x, tabline_y, tabline_z = {}, {}, {}, {}, {}, {}

local function create_attributes(window)
  local current_mode = mode.get(window)
  local colors = config.theme[current_mode]
  for _, ext in pairs(extension.extensions) do
    if ext.theme then
      colors = util.deep_extend(util.deep_copy(colors), ext.theme)
    end
  end

  -- Get workspace color from tmux metadata if available
  local workspace_color = nil
  local mux_window = window:mux_window()
  if mux_window then
    local active_tab = mux_window:active_tab()
    if active_tab and wezterm.GLOBAL.custom_tabs then
      local tab_id = tostring(active_tab:tab_id())
      local tab_meta = wezterm.GLOBAL.custom_tabs[tab_id]
      if tab_meta and tab_meta.tmux_workspace_color then
        workspace_color = tab_meta.tmux_workspace_color
      end
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

  -- Override b section background with workspace color if in tmux
  local b_bg = workspace_color or colors.b.bg
  local b_fg = workspace_color and (needs_dark_text(workspace_color) and "#1e1e2e" or "#bac2de") or colors.b.fg

  local debug_config = require('config.debug')
  if debug_config.is_enabled('debug_tabline_colors') then
    wezterm.log_info('[TABLINE:COLORS] workspace_color:', workspace_color or 'nil')
    wezterm.log_info('[TABLINE:COLORS] b_bg:', b_bg)
    wezterm.log_info('[TABLINE:COLORS] colors.b.bg:', colors.b.bg)
  end

  attributes_a = {
    { Foreground = { Color = colors.a.fg } },
    { Background = { Color = colors.a.bg } },
    { Attribute = { Intensity = 'Bold' } },
  }
  attributes_b = {
    { Foreground = { Color = b_fg } },
    { Background = { Color = b_bg } },
    { Attribute = { Intensity = 'Bold' } },
  }
  attributes_c = {
    { Foreground = { Color = colors.c.fg } },
    { Background = { Color = colors.c.bg } },
  }
  attributes_x = {
    { Foreground = { Color = colors.x and colors.x.fg or colors.c.fg } },
    { Background = { Color = colors.x and colors.x.bg or colors.c.bg } },
  }
  attributes_y = {
    { Foreground = { Color = colors.y and colors.y.fg or colors.b.fg } },
    { Background = { Color = colors.y and colors.y.bg or colors.b.bg } },
    { Attribute = { Intensity = 'Normal' } },
  }
  attributes_z = {
    { Foreground = { Color = colors.z and colors.z.fg or colors.a.fg } },
    { Background = { Color = colors.z and colors.z.bg or colors.a.bg } },
    { Attribute = { Intensity = 'Bold' } },
  }
  section_seperator_attributes_a = {
    { Foreground = { Color = colors.a.bg } },
    { Background = { Color = b_bg } },
  }
  section_seperator_attributes_b = {
    { Foreground = { Color = b_bg } },
    { Background = { Color = colors.c.bg } },
  }
  section_seperator_attributes_c = {
    { Foreground = { Color = colors.a.bg } },
    { Background = { Color = colors.c.bg } },
  }
  section_seperator_attributes_x = {
    { Foreground = { Color = colors.z and colors.z.bg or colors.a.bg } },
    { Background = { Color = colors.x and colors.x.bg or colors.c.bg } },
  }
  section_seperator_attributes_y = {
    { Foreground = { Color = colors.y and colors.y.bg or colors.b.bg } },
    { Background = { Color = colors.x and colors.x.bg or colors.c.bg } },
  }
  section_seperator_attributes_z = {
    { Foreground = { Color = colors.z and colors.z.bg or colors.a.bg } },
    { Background = { Color = colors.y and colors.y.bg or colors.b.bg } },
  }
  -- Separator from tabline_c to tab area
  section_seperator_attributes_c_to_tab = {
    { Foreground = { Color = colors.c.bg } },
    { Background = { Color = 'rgba(0, 0, 0, 0.4)' } },  -- Tab background color
  }
  -- Separator from tab area to tabline_x
  section_seperator_attributes_tab_to_x = {
    { Foreground = { Color = colors.x and colors.x.bg or colors.c.bg } },
    { Background = { Color = 'rgba(0, 0, 0, 0.4)' } },  -- Tab background color
  }
end

local function insert_component_separators(components, is_left)
  local i = 1
  while i <= #components do
    if type(components[i]) == 'table' and components[i].Text and i < #components then
      table.insert(components, i + 1, is_left and get_left_component_separator() or get_right_component_separator())
      i = i + 1
    end
    i = i + 1
  end
  return components
end

local function create_sections(window)
  local debug_config = require('config.debug')
  local sections = config.sections

  if debug_config.is_enabled('debug_tabline_components') then
    wezterm.log_info('[TABLINE:COMPONENTS] tabline_b config:', sections.tabline_b)
  end

  for _, ext in pairs(extension.extensions) do
    if ext.sections then
      sections = util.deep_extend(util.deep_copy(sections), ext.sections)
    end
  end

  tabline_a = insert_component_separators(util.extract_components(sections.tabline_a, attributes_a, window, true), true)
  tabline_b = insert_component_separators(util.extract_components(sections.tabline_b, attributes_b, window, true), true)

  if debug_config.is_enabled('debug_tabline_components') then
    wezterm.log_info('[TABLINE:COMPONENTS] tabline_b result count:', #tabline_b)
  end

  tabline_c = insert_component_separators(util.extract_components(sections.tabline_c, attributes_c, window, true), true)
  tabline_x =
    insert_component_separators(util.extract_components(sections.tabline_x, attributes_x, window, true), false)
  tabline_y =
    insert_component_separators(util.extract_components(sections.tabline_y, attributes_y, window, true), false)
  tabline_z =
    insert_component_separators(util.extract_components(sections.tabline_z, attributes_z, window, true), false)
end

local function right_section()
  local result = {}
  if #tabline_x > 0 then
    -- Add arrow separator before tabline_x transitioning from tab area
    util.insert_elements(result, section_seperator_attributes_tab_to_x)
    table.insert(result, get_right_section_separator())
    util.insert_elements(result, attributes_x)
    util.insert_elements(result, tabline_x)
  end
  -- Add arrow separator between X and Y
  if #tabline_x > 0 and #tabline_y > 0 then
    util.insert_elements(result, section_seperator_attributes_y)
    table.insert(result, get_right_section_separator())
  end
  if #tabline_y > 0 then
    util.insert_elements(result, attributes_y)
    util.insert_elements(result, tabline_y)
  end
  if #tabline_z > 0 and #tabline_y > 0 then
    util.insert_elements(result, section_seperator_attributes_z)
    table.insert(result, get_right_section_separator())
  elseif #tabline_z > 0 and #tabline_x > 0 then
    util.insert_elements(result, section_seperator_attributes_x)
    table.insert(result, get_right_section_separator())
  end
  if #tabline_z > 0 then
    util.insert_elements(result, attributes_z)
    util.insert_elements(result, tabline_z)
  end
  return result
end

local function left_section()
  local result = {}
  if #tabline_a > 0 then
    util.insert_elements(result, attributes_a)
    util.insert_elements(result, tabline_a)
  end
  if #tabline_a > 0 and #tabline_b > 0 then
    util.insert_elements(result, section_seperator_attributes_a)
    table.insert(result, get_left_section_separator())
  elseif #tabline_a > 0 then
    util.insert_elements(result, section_seperator_attributes_c)
    table.insert(result, get_left_section_separator())
  end
  if #tabline_b > 0 then
    util.insert_elements(result, attributes_b)
    util.insert_elements(result, tabline_b)
  end
  if #tabline_b > 0 then
    util.insert_elements(result, section_seperator_attributes_b)
    table.insert(result, get_left_section_separator())
  end
  if #tabline_c > 0 then
    util.insert_elements(result, attributes_c)
    util.insert_elements(result, tabline_c)
    -- Add arrow separator after tabline_c transitioning to tab area
    util.insert_elements(result, section_seperator_attributes_c_to_tab)
    table.insert(result, get_left_section_separator())
  end
  return result
end

function M.set_status(window)
  local debug_config = require('config.debug')
  if debug_config.is_enabled('debug_tabline_events') then
    wezterm.log_info('[TABLINE:STATUS] set_status called')
  end
  create_attributes(window)
  create_sections(window)

  -- Store current mode in global for tab formatting
  local current_mode = mode.get(window)
  wezterm.GLOBAL.current_mode = current_mode

  -- Store tmux user variables in global for tab formatting
  local pane = window:active_pane()
  if pane then
    local user_vars = pane:get_user_vars()
    local tmux_session = user_vars.TMUX_SESSION or ""
    local tmux_server_icon = user_vars.TMUX_SERVER_ICON or ""
    local tmux_window = user_vars.TMUX_WINDOW or ""
    local tmux_pane = user_vars.TMUX_PANE or ""

    -- Decode base64 values
    if tmux_session ~= "" then
      local ok, decoded = pcall(wezterm.base64_decode, tmux_session)
      if ok then
        tmux_session = decoded
      end
    end
    if tmux_server_icon ~= "" then
      local ok, decoded = pcall(wezterm.base64_decode, tmux_server_icon)
      if ok then
        tmux_server_icon = decoded
      end
    end
    if tmux_window ~= "" then
      local ok, decoded = pcall(wezterm.base64_decode, tmux_window)
      if ok then
        tmux_window = decoded
      end
    end

    -- Only update GLOBAL if we have valid tmux data, otherwise preserve previous values
    -- This prevents flickering when switching between tabs
    if tmux_session ~= "" or tmux_server_icon ~= "" then
      wezterm.GLOBAL.tmux_user_vars = {
        session = tmux_session,
        server_icon = tmux_server_icon,
      }
    elseif not wezterm.GLOBAL.tmux_user_vars then
      -- Initialize with empty values if not set
      wezterm.GLOBAL.tmux_user_vars = {
        session = "",
        server_icon = "",
      }
    end
    -- If tmux_session and icon are empty but GLOBAL exists, preserve GLOBAL values (don't overwrite)

    -- Store tmux info for the active tab only
    -- The TMUX_WINDOW user var is set by tmux hooks, so we just use that
    if tmux_session ~= "" and tmux_window ~= "" then
      if not wezterm.GLOBAL.tab_tmux_info then
        wezterm.GLOBAL.tab_tmux_info = {}
      end

      local mux_window = window:mux_window()
      if mux_window then
        local active_tab = mux_window:active_tab()
        if active_tab then
          local tab_id = tostring(active_tab:tab_id())
          -- Remove -view suffix from session name
          local clean_session = tmux_session:match("^([^%-]+)") or tmux_session
          wezterm.GLOBAL.tab_tmux_info[tab_id] = {
            session = clean_session,
            window = tmux_window,
          }
        end
      end
    end
  end

  window:set_left_status(wezterm.format(left_section()))
  window:set_right_status(wezterm.format(right_section()))
end

return M
