-- MODE COLOR CONSTANTS
-- Single source of truth for mode colors used by BOTH tabline AND pane borders
--
-- This module provides:
-- 1. Direct hex color constants for each mode
-- 2. A single mode detection function used everywhere
-- 3. Helper to get the current mode's color
--
-- All mode color application should use this module to ensure consistency

local wezterm = require("wezterm")

local M = {}

-- ============================================================================
-- COLOR CONSTANTS (DIRECT HEX VALUES)
-- ============================================================================
-- These are the exact colors used for both borders and tabline mode backgrounds

local MODE_COLOR_MAP = {
  wezterm_mode = "#8470FF",        -- purple/lavender - default wezterm context
  tmux_mode = "#01F9C6",           -- bright cyan/teal - tmux context
  leader_mode = "#FF5370",         -- red - leader key active (black text)
  pane_mode = "#f1fc79",           -- bright yellow/lime - pane navigation
  resize_mode = "#F78C6C",         -- orange/peach - resize operations
  copy_mode = "#F78C6C",           -- orange/peach - copy mode (same as resize)
  search_mode = "#8BE9FD",         -- cyan - search mode
  pane_selection_mode = "#8470FF", -- purple (same as wezterm) - pane selection
}

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- Get the color for a specific mode (returns hex color string)
function M.get_color(mode_name)
  -- Normalize mode name (ensure it has _mode suffix)
  local normalized = mode_name
  if not normalized:find("_mode$") then
    normalized = normalized:lower() .. "_mode"
  end

  return MODE_COLOR_MAP[normalized] or MODE_COLOR_MAP.wezterm_mode
end

-- Get all mode colors (returns table of mode_name -> hex_color)
function M.get_all_colors()
  return MODE_COLOR_MAP
end

-- Invalidate the color cache (no-op now, kept for API compatibility)
function M.invalidate_cache()
  -- No caching needed with direct hex values
end

-- ============================================================================
-- MODE DETECTION
-- ============================================================================
-- Single source of truth for detecting the current mode
-- Priority: leader > key_table > context (wezterm/tmux)

function M.get_current_mode(window)
  -- 1. Leader key takes highest priority
  if window:leader_is_active() then
    return "leader_mode"
  end

  -- 2. Check for active key table
  local key_table = window:active_key_table()
  if key_table then
    -- Normalize to _mode suffix
    if not key_table:find("_mode$") then
      return key_table .. "_mode"
    end
    return key_table
  end

  -- 3. Default: context-based mode
  local context = wezterm.GLOBAL.leader_context or "wezterm"
  return context == "tmux" and "tmux_mode" or "wezterm_mode"
end

-- ============================================================================
-- CONSTANTS FOR DIRECT ACCESS
-- ============================================================================
-- Export the color map so other modules can use the same colors
M.MODE_COLOR_MAP = MODE_COLOR_MAP

return M
