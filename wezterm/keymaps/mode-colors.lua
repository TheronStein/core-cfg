-- Mode State & Border Color Management
-- Applies mode colors to BOTH pane borders AND tabline (via GLOBAL state)
-- Single point of control for mode color transitions
--
-- This module:
-- 1. Uses mode_colors constants (single source of truth)
-- 2. Sets border color via config overrides
-- 3. Sets GLOBAL state that tabline reads for its colors
-- 4. Provides helpers for mode transitions
--
-- When you enter a mode, call enter_mode() - it sets BOTH border and tabline
-- When you exit a mode, call exit_mode() - it syncs back to current state

local wezterm = require("wezterm")
local mode_colors_const = require("modules.utils.mode_colors")

local M = {}

-- ============================================================================
-- APPLY MODE COLORS (BOTH BORDER + TABLINE)
-- ============================================================================

-- Set both border color AND tabline state for a specific mode
-- This is the SINGLE function that applies mode colors - use it everywhere
function M.set_mode(window, mode_name)
  -- Get the color for this mode
  local color = mode_colors_const.get_color(mode_name)

  -- 1. Set pane border color
  local overrides = window:get_config_overrides() or {}
  overrides.colors = overrides.colors or {}
  overrides.colors.split = color
  window:set_config_overrides(overrides)

  -- 2. Set GLOBAL state that tabline reads
  -- The tabline mode component reads wezterm.GLOBAL.current_mode to determine its color
  wezterm.GLOBAL.current_mode = mode_name
  wezterm.GLOBAL.current_border_color = color

  -- 3. Update tracking so sync_mode_border doesn't redundantly call set_mode
  wezterm.GLOBAL.last_mode_per_window = wezterm.GLOBAL.last_mode_per_window or {}
  local window_id = tostring(window:window_id())
  wezterm.GLOBAL.last_mode_per_window[window_id] = mode_name

  -- 4. Directly update tabline to reflect the mode change immediately
  -- This avoids recursion issues with update-status while ensuring instant feedback
  local ok, tabline_component = pcall(require, "tabline.component")
  if ok and tabline_component and tabline_component.set_status then
    tabline_component.set_status(window)
  end

  -- Debug logging
  local ok2, debug_config = pcall(require, "config.debug")
  if ok2 and debug_config.is_enabled("debug_mode_borders") then
    wezterm.log_info(string.format("[MODE] Set mode to %s (color: %s)", mode_name, color))
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

-- Set context and update colors if appropriate
function M.set_context(window, context)
  wezterm.GLOBAL.leader_context = context

  -- If no key table is active and leader isn't active, update to context mode
  if not window:active_key_table() and not window:leader_is_active() then
    local mode = context == "tmux" and "tmux_mode" or "wezterm_mode"
    M.set_mode(window, mode)
  end
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
