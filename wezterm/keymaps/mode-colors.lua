-- Centralized mode border color management
-- This module provides a single source of truth for border colors across all modes
-- Border colors are derived from the tabline theme to ensure visual consistency
-- The border color ALWAYS matches the current mode indicator in the status bar

local wezterm = require("wezterm")
local M = {}

-- ============================================================================
-- MODE DETECTION (mirrors tabline/components/window/mode.lua)
-- ============================================================================

-- Get the current mode - this is the single source of truth
-- Returns the mode name exactly as used in tabline theme (e.g., "wezterm_mode", "leader_mode")
function M.get_current_mode(window)
  -- 1. Leader key takes highest priority
  if window:leader_is_active() then
    return "leader_mode"
  end

  -- 2. Check for active key table (copy_mode, resize_mode, pane_mode, search_mode, etc.)
  local key_table = window:active_key_table()
  if key_table then
    -- Ensure it ends with _mode for consistency
    if not key_table:find("_mode$") then
      return key_table .. "_mode"
    end
    return key_table
  end

  -- 3. Default: context-based mode (wezterm or tmux)
  local context = wezterm.GLOBAL.leader_context or "wezterm"
  if context == "tmux" then
    return "tmux_mode"
  else
    return "wezterm_mode"
  end
end

-- ============================================================================
-- THEME COLOR EXTRACTION
-- ============================================================================

-- Get the border color for a specific mode from the tabline theme
-- The color comes from the mode's 'a' section background (the mode indicator)
function M.get_color_for_mode(mode_name)
  local ok, tabline_config = pcall(require, "tabline.config")
  if not ok or not tabline_config.theme then
    -- Fallback colors if tabline not initialized
    local fallbacks = {
      wezterm_mode = "#b4befe",      -- blue/lavender
      tmux_mode = "#94e2d5",         -- cyan/teal
      leader_mode = "#f38ba8",       -- red
      pane_mode = "#a6e3a1",         -- green
      resize_mode = "#fab387",       -- peach/yellow
      copy_mode = "#fab387",         -- peach/yellow
      search_mode = "#a6e3a1",       -- green
      pane_selection_mode = "#89b4fa", -- blue
    }
    return fallbacks[mode_name] or "#b4befe"
  end

  -- Get color from theme's 'a' section background for this mode
  local theme = tabline_config.theme
  if theme[mode_name] and theme[mode_name].a and theme[mode_name].a.bg then
    return theme[mode_name].a.bg
  end

  -- Fallback to wezterm_mode color if mode not found in theme
  if theme.wezterm_mode and theme.wezterm_mode.a and theme.wezterm_mode.a.bg then
    return theme.wezterm_mode.a.bg
  end

  return "#b4befe"  -- Ultimate fallback
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- Get the color for a specific mode
-- @param mode - Mode name (e.g., "leader_mode", "copy_mode", "wezterm_mode")
-- @return color hex string
function M.get_color(mode)
  -- Normalize mode name to include _mode suffix if needed
  local mode_name = tostring(mode or "wezterm_mode")
  if not mode_name:find("_mode$") then
    mode_name = mode_name:lower() .. "_mode"
  end
  return M.get_color_for_mode(mode_name)
end

-- Set border color for a specific mode
-- @param window - WezTerm window object
-- @param mode - Mode name (e.g., "pane_mode", "resize_mode", "leader_mode")
function M.set_mode_border(window, mode)
  -- Normalize mode name
  local mode_name = tostring(mode or "wezterm_mode")
  if not mode_name:find("_mode$") then
    mode_name = mode_name:lower() .. "_mode"
  end

  local color = M.get_color_for_mode(mode_name)

  -- Apply the border color
  local overrides = window:get_config_overrides() or {}
  overrides.colors = overrides.colors or {}
  overrides.colors.split = color
  window:set_config_overrides(overrides)

  -- Store current mode in global for reference
  wezterm.GLOBAL.current_border_mode = mode_name

  -- Debug logging
  local ok, debug_config = pcall(require, "config.debug")
  if ok and debug_config.is_enabled("debug_mode_borders") then
    wezterm.log_info(string.format("[MODE-COLORS] Set border to %s for mode: %s", color, mode_name))
  end
end

-- Sync border color with current mode (call from update-status)
-- This is the main function that keeps borders in sync with the status bar
-- @param window - WezTerm window object
-- @return current mode name
function M.sync_border_with_mode(window)
  local current_mode = M.get_current_mode(window)
  M.set_mode_border(window, current_mode)
  return current_mode
end

-- Create an action callback that syncs border color immediately
-- This is used to trigger border updates on mode entry/exit without waiting for update-status
-- @param wrapped_action - Optional action to perform after syncing (can be nil for sync-only)
-- @return action_callback that syncs border then performs wrapped action
function M.sync_and_perform(wrapped_action)
  return wezterm.action_callback(function(window, pane)
    -- Sync border color to match current mode
    M.sync_border_with_mode(window)

    -- Perform the wrapped action if provided
    if wrapped_action then
      window:perform_action(wrapped_action, pane)
    end
  end)
end

-- Convenience function for resetting to default context mode
-- @param window - WezTerm window object
function M.reset_border(window)
  -- Don't reset to a hardcoded "normal" - detect the actual context mode
  local context = wezterm.GLOBAL.leader_context or "wezterm"
  local default_mode = context == "tmux" and "tmux_mode" or "wezterm_mode"
  M.set_mode_border(window, default_mode)
end

return M
