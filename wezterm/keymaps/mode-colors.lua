-- Mode State & Border Color Management
-- Applies mode colors to BOTH pane borders AND tabline (via per-tab state)
-- Single point of control for mode color transitions
--
-- This module:
-- 1. Uses mode_colors constants (single source of truth)
-- 2. Sets border color via config overrides (window-wide)
-- 3. Stores mode state per-tab for individual tab coloring
-- 4. Provides helpers for mode transitions
--
-- When you enter a mode, call enter_mode() - it sets border and per-tab state
-- When you exit a mode, call exit_mode() - it syncs back to tab's base mode

local wezterm = require("wezterm")
local mode_colors_const = require("modules.utils.mode_colors")

local M = {}

-- ============================================================================
-- HELPER: Get active tab ID
-- ============================================================================

local function get_active_tab_id(window)
  local mux_window = window:mux_window()
  if not mux_window then return nil end
  local active_tab = mux_window:active_tab()
  if not active_tab then return nil end
  return tostring(active_tab:tab_id())
end

-- ============================================================================
-- APPLY MODE COLORS (BORDER + PER-TAB STATE)
-- ============================================================================

-- Set both border color AND per-tab state for a specific mode
-- This is the SINGLE function that applies mode colors - use it everywhere
function M.set_mode(window, mode_name, tab_id)
  -- Get the color for this mode
  local color = mode_colors_const.get_color(mode_name)

  -- Determine which tab to update (default to active tab)
  tab_id = tab_id or get_active_tab_id(window)

  -- 1. Set pane border color (this is window-wide, applies to active tab's mode)
  local overrides = window:get_config_overrides() or {}
  overrides.colors = overrides.colors or {}
  overrides.colors.split = color
  window:set_config_overrides(overrides)

  -- 2. Store mode in PER-TAB state (but NOT transient modes like leader_mode)
  -- Leader mode is a temporary overlay and should not be stored as base_mode
  if tab_id and mode_name ~= "leader_mode" then
    local tab_mode_state = require("modules.utils.tab_mode_state")
    tab_mode_state.set_tab_base_mode(tab_id, mode_name)
  end

  -- 3. Set GLOBAL state for tabline mode section (shows active tab's mode)
  wezterm.GLOBAL.current_mode = mode_name
  wezterm.GLOBAL.current_border_color = color

  -- 4. Update tracking so sync_mode_border doesn't redundantly call set_mode
  wezterm.GLOBAL.last_mode_per_window = wezterm.GLOBAL.last_mode_per_window or {}
  local window_id = tostring(window:window_id())
  wezterm.GLOBAL.last_mode_per_window[window_id] = mode_name

  -- 5. Directly update tabline to reflect the mode change immediately
  local ok, tabline_component = pcall(require, "tabline.component")
  if ok and tabline_component and tabline_component.set_status then
    tabline_component.set_status(window)
  end

  -- Debug logging
  local ok2, debug_config = pcall(require, "config.debug")
  if ok2 and debug_config.is_enabled("debug_mode_borders") then
    wezterm.log_info(string.format("[MODE] Set mode to %s for tab %s (color: %s)", mode_name, tab_id or "unknown", color))
  end
end

-- ============================================================================
-- MODE TRANSITION HELPERS
-- ============================================================================

-- Enter a mode (sets border and tabline colors)
function M.enter_mode(window, mode_name)
  M.set_mode(window, mode_name)
end

-- Exit current mode and sync to actual state
-- This detects what mode we should be in now (after exiting key table, etc.)
function M.exit_mode(window)
  -- Small delay to let key table pop complete, then sync
  wezterm.time.call_after(0.01, function()
    local current_mode = mode_colors_const.get_current_mode(window)
    M.set_mode(window, current_mode)
  end)
end

-- Sync to current detected mode (used by update-status as fallback)
-- This is the ONLY place we "poll" - everything else is direct
function M.sync_to_current_mode(window)
  local current_mode = mode_colors_const.get_current_mode(window)
  M.set_mode(window, current_mode)
  return current_mode
end

-- ============================================================================
-- CONTEXT SWITCHING
-- ============================================================================

-- Set context and update colors for the CURRENT TAB
function M.set_context(window, context)
  -- Update global context as fallback
  wezterm.GLOBAL.leader_context = context

  -- Update per-tab context
  local tab_id = get_active_tab_id(window)
  if tab_id then
    local tab_mode_state = require("modules.utils.tab_mode_state")
    tab_mode_state.set_tab_context(tab_id, context)
  end

  -- If no key table is active and leader isn't active, update to context mode
  if not window:active_key_table() and not window:leader_is_active() then
    local mode = context == "tmux" and "tmux_mode" or "wezterm_mode"
    M.set_mode(window, mode)
  end
end

-- ============================================================================
-- TAB SWITCH HANDLING
-- ============================================================================

-- Called when switching tabs - restores the destination tab's mode
function M.on_tab_switch(window, pane, from_tab_id, to_tab_id)
  -- If a key table is active, pop it (key tables are window-wide)
  if window:active_key_table() then
    window:perform_action(wezterm.action.PopKeyTable, pane)
  end

  -- Get the destination tab's stored mode
  local tab_mode_state = require("modules.utils.tab_mode_state")
  local dest_state = tab_mode_state.get_tab_mode(to_tab_id)

  -- Apply the destination tab's mode (updates border and global state)
  M.set_mode(window, dest_state.base_mode, to_tab_id)

  -- Update global context to match destination tab
  wezterm.GLOBAL.leader_context = dest_state.context
end

-- ============================================================================
-- ACTION CREATORS
-- ============================================================================

-- Create an action that enters a mode with color update, then performs an action
function M.enter_mode_action(mode_name, then_action)
  return wezterm.action_callback(function(window, pane)
    M.enter_mode(window, mode_name)
    if then_action then
      window:perform_action(then_action, pane)
    end
  end)
end

-- Create an action that exits mode and syncs colors
function M.exit_mode_action(exit_action)
  return wezterm.action_callback(function(window, pane)
    if exit_action then
      window:perform_action(exit_action, pane)
    end
    M.exit_mode(window)
  end)
end

-- ============================================================================
-- LEGACY API (for compatibility)
-- ============================================================================

function M.get_current_mode(window)
  return mode_colors_const.get_current_mode(window)
end

function M.get_color(mode_name)
  return mode_colors_const.get_color(mode_name)
end

function M.set_border(window, mode_name)
  M.set_mode(window, mode_name)
end

function M.sync_border(window)
  return M.sync_to_current_mode(window)
end

function M.sync_border_with_mode(window)
  return M.sync_to_current_mode(window)
end

function M.invalidate_cache()
  mode_colors_const.invalidate_cache()
end

return M
