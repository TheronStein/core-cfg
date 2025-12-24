local wezterm = require("wezterm")
local keymode = require("keymaps.keymode")
local mode_colors = require("keymaps.mode-colors")
local act = wezterm.action

local M = {}

function M.setup(config)
  keymode.create_mode("pane_mode", {
    {
      key = "Tab",
      action = wezterm.action_callback(function(window, pane)
        -- Switch to resize mode
        window:perform_action(
          wezterm.action.ActivateKeyTable({
            name = "resize_mode",
            one_shot = false,
            timeout_milliseconds = 2000,
          }),
          pane
        )
        -- Sync border AFTER switching key table
        mode_colors.sync_border_with_mode(window)
      end),
    },
    -- Pane navigation
    { key = "r", action = act.RotatePanes("Clockwise") },
    { key = "R", action = act.RotatePanes("CounterClockwise") },
    { key = "a", action = act.ActivatePaneDirection("Left") },
    { key = "d", action = act.ActivatePaneDirection("Right") },
    { key = "w", action = act.ActivatePaneDirection("Up") },
    { key = "s", action = act.ActivatePaneDirection("Down") },
    { key = "J", mods = "CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "L", mods = "CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "I", mods = "CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "K", mods = "CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },
    { key = "j", action = act.AdjustPaneSize({ "Left", 2 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 2 }) },
    { key = "i", action = act.AdjustPaneSize({ "Up", 2 }) },
    { key = "k", action = act.AdjustPaneSize({ "Down", 2 }) },
    { key = "j", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 10 }) },
    { key = "l", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 10 }) },
    { key = "i", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 10 }) },
    { key = "k", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 10 }) },
    { key = "b", mods = "NONE", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "v", mods = "NONE", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "x", mods = "NONE", action = act.CloseCurrentPane({ confirm = false }) },
    {
      key = "Escape",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(wezterm.action.PopKeyTable, pane)
        -- Sync border AFTER popping key table
        mode_colors.sync_border_with_mode(window)
      end),
    },
    {
      key = "C",
      mods = "CTRL",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(wezterm.action.PopKeyTable, pane)
        -- Sync border AFTER popping key table
        mode_colors.sync_border_with_mode(window)
      end),
    },

    {
      key = "q",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(wezterm.action.PopKeyTable, pane)
        -- Sync border AFTER popping key table
        mode_colors.sync_border_with_mode(window)
      end),
    },
  })
end

return M
