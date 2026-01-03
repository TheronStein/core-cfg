-- Per-Tab Mode State Management
-- Stores and manages mode state for each tab independently
--
-- This enables:
-- 1. Each tab to have its own mode (wezterm, tmux, copy, pane, resize, etc.)
-- 2. Tab background colors in tabline to reflect each tab's mode
-- 3. Border color to update when switching tabs
-- 4. Session persistence of per-tab modes

local wezterm = require("wezterm")

local M = {}

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Ensure GLOBAL storage exists
local function ensure_storage()
  wezterm.GLOBAL.tab_modes = wezterm.GLOBAL.tab_modes or {}
  wezterm.GLOBAL.last_active_tab_per_window = wezterm.GLOBAL.last_active_tab_per_window or {}
end

-- ============================================================================
-- TAB MODE GETTERS/SETTERS
-- ============================================================================

-- Get mode state for a specific tab
-- Returns: { base_mode = "wezterm_mode", context = "wezterm" }
-- Auto-initializes and stores the default if tab doesn't exist yet
function M.get_tab_mode(tab_id)
  ensure_storage()
  local id = tostring(tab_id)

  -- Return existing state if present
  if wezterm.GLOBAL.tab_modes[id] then
    return wezterm.GLOBAL.tab_modes[id]
  end

  -- Auto-initialize with default state and STORE it in GLOBAL
  -- This ensures the tab is tracked from first access
  local context = wezterm.GLOBAL.leader_context or "wezterm"
  local default_state = {
    base_mode = context == "tmux" and "tmux_mode" or "wezterm_mode",
    context = context,
  }
  wezterm.GLOBAL.tab_modes[id] = default_state

  return default_state
end

-- Set mode state for a specific tab
function M.set_tab_mode(tab_id, mode_data)
  ensure_storage()
  local id = tostring(tab_id)

  -- Merge with existing state
  local existing = wezterm.GLOBAL.tab_modes[id] or {}
  wezterm.GLOBAL.tab_modes[id] = {
    base_mode = mode_data.base_mode or existing.base_mode or "wezterm_mode",
    context = mode_data.context or existing.context or "wezterm",
  }

  return wezterm.GLOBAL.tab_modes[id]
end

-- Set just the base_mode for a tab (convenience function)
function M.set_tab_base_mode(tab_id, base_mode)
  return M.set_tab_mode(tab_id, { base_mode = base_mode })
end

-- Set just the context for a tab (convenience function)
function M.set_tab_context(tab_id, context)
  return M.set_tab_mode(tab_id, { context = context })
end

-- ============================================================================
-- TAB LIFECYCLE
-- ============================================================================

-- Initialize mode state for a new tab
-- Can optionally inherit from a spawner tab
function M.initialize_tab(tab_id, spawner_tab_id)
  ensure_storage()
  local id = tostring(tab_id)

  -- Check if already initialized
  if wezterm.GLOBAL.tab_modes[id] then
    return wezterm.GLOBAL.tab_modes[id]
  end

  -- Inherit from spawner tab if available
  if spawner_tab_id then
    local spawner_state = M.get_tab_mode(spawner_tab_id)
    wezterm.GLOBAL.tab_modes[id] = {
      base_mode = spawner_state.base_mode,
      context = spawner_state.context,
    }
  else
    -- Use global context as default
    local context = wezterm.GLOBAL.leader_context or "wezterm"
    wezterm.GLOBAL.tab_modes[id] = {
      base_mode = context == "tmux" and "tmux_mode" or "wezterm_mode",
      context = context,
    }
  end

  return wezterm.GLOBAL.tab_modes[id]
end

-- Cleanup mode state when tab is closed
function M.cleanup_tab(tab_id)
  ensure_storage()
  local id = tostring(tab_id)
  wezterm.GLOBAL.tab_modes[id] = nil
end

-- ============================================================================
-- TAB SWITCH DETECTION
-- ============================================================================

-- Check if active tab changed for a window
-- Returns: switched (bool), from_tab_id, to_tab_id
function M.detect_tab_switch(window)
  ensure_storage()

  local window_id = tostring(window:window_id())
  local mux_window = window:mux_window()
  if not mux_window then
    return false, nil, nil
  end

  local active_tab = mux_window:active_tab()
  if not active_tab then
    return false, nil, nil
  end

  local current_tab_id = tostring(active_tab:tab_id())
  local last_tab_id = wezterm.GLOBAL.last_active_tab_per_window[window_id]

  if last_tab_id ~= current_tab_id then
    wezterm.GLOBAL.last_active_tab_per_window[window_id] = current_tab_id
    return true, last_tab_id, current_tab_id
  end

  return false, nil, nil
end

-- ============================================================================
-- HELPERS
-- ============================================================================

-- Get the active tab ID for a window
function M.get_active_tab_id(window)
  local mux_window = window:mux_window()
  if not mux_window then
    return nil
  end

  local active_tab = mux_window:active_tab()
  if not active_tab then
    return nil
  end

  return tostring(active_tab:tab_id())
end

-- Get mode color for a specific tab (convenience function)
function M.get_tab_color(tab_id)
  local mode_colors = require("modules.utils.mode_colors")
  local tab_state = M.get_tab_mode(tab_id)
  return mode_colors.get_color(tab_state.base_mode)
end

-- ============================================================================
-- SESSION PERSISTENCE HELPERS
-- ============================================================================

-- Export all tab modes for session saving
function M.export_all_modes()
  ensure_storage()
  local export = {}
  for tab_id, state in pairs(wezterm.GLOBAL.tab_modes) do
    export[tab_id] = {
      base_mode = state.base_mode,
      context = state.context,
    }
  end
  return export
end

-- Import tab modes from session data
-- tab_id_map: { old_tab_id = new_tab_id } for remapping after restore
function M.import_modes(modes_data, tab_id_map)
  ensure_storage()

  for old_id, state in pairs(modes_data) do
    local new_id = tab_id_map and tab_id_map[old_id] or old_id
    wezterm.GLOBAL.tab_modes[tostring(new_id)] = {
      base_mode = state.base_mode or "wezterm_mode",
      context = state.context or "wezterm",
    }
  end
end

return M
