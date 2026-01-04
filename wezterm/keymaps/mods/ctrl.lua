local wezterm = require("wezterm")
local act = wezterm.action
local navigate_mode = require("utils.navigation")
local M = {}
function M.setup(config)
  config.keys = config.keys or {}

  local keys = {
    --  ╭─────────────────────────────────────────────────────────╮
    --  │                        CTRL                             │
    --  ╰─────────────────────────────────────────────────────────╯
    --    ┌ Keys:
    --    │
    --    │
    --    │
    --    └

    -- { key = "i", mods = "CTRL", action = wezterm.action.SendString("\x1b[105;5u") },

    -- { key = "CapsLock", mods = "NONE", action = wezterm.action.SendKey({ key = "Hyper" }),
    -- {
    -- 	key = "`",
    -- 	mods = "CTRL",
    -- 	action = wezterm.action.SendKey({ key = "`", mods = "CTRL" }),
    -- },
    --
    -- {
    -- 	key = "2",
    -- 	mods = "CTRL",
    -- 	action = wezterm.action.SendKey({ key = "2", mods = "CTRL" }),
    -- 	-- action = wezterm.action.SendString("\x1b[96;5u"),
    -- },

    -- {
    -- 	key = "`",
    -- 	mods = "CTRL",
    -- 	action = wezterm.action.SendString("\x1b[96;5u"),
    -- },

    -- Unbind
    {
      key = "q",
      mods = "CTRL",
      action = wezterm.action.DisableDefaultAssignment,
    },

    -- Unbind
    {
      key = "d",
      mods = "CTRL",
      action = wezterm.action.DisableDefaultAssignment,
    },

    {
      key = "Tab",
      mods = "CTRL",
      action = wezterm.action.DisableDefaultAssignment,
    },

    {
      key = "F",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },

    -- {
    -- 	key = "/",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = wezterm.action.
    -- },

    -- {

    -- {
    -- 	key = "i",
    -- 	mods = "CTRL",
    -- 	action = wezterm.action.DisableDefaultAssignment,
    -- },
    --
    -- {
    -- 	key = "i",
    -- 	mods = "CTRL",
    -- 	action = wezterm.action.SendString("\x1b[105;5u"),
    -- },

    --
    --
    --
    --  ╭─────────────────────────────────────────────────────────╮
    --  │                      CTRL|SHIFT                         │
    --  ╰─────────────────────────────────────────────────────────╯
    --    ┌ Keys:
    --    │
    --    │  B,C,I,J,K,L,V
    --    │
    --    └

    {
      key = "Tab",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = "R",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },
    -- {
    -- {
    -- 	key = "W",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = act.ActivatePaneDirection("Up"),
    -- },
    --
    -- {
    -- 	key = "A",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = act.ActivatePaneDirection("LefDownt"),
    -- },
    --
    -- {
    -- 	key = "S",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = act.ActivatePaneDirection("Down"),
    -- },
    --
    -- {
    -- 	key = "D",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = act.ActivatePaneDirection("Right"),
    -- },

    {
      key = "I",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },

    {
      key = "J",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },

    {
      key = "L",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },

    {
      key = "K",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },

    {
      key = "U",
      mods = "CTRL|SHIFT",
      action = wezterm.action.DisableDefaultAssignment,
    },

    { key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
    { key = "Q", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "E", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },

    -- Handle navigation signals from tmux (Ctrl+Shift+Arrows = navigate WezTerm)
    { key = "W", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "S", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "A", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "D", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

    -- Handle navigation signals from tmux (Ctrl+Shift+Arrows = navigate WezTerm)
    { key = "I", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "K", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "J", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "L", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
    -- Handle navigation signals from tmux (Ctrl+Shift+Arrows = navigate WezTerm)
    { key = "UpArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

    -- {
    --   key = "W",
    --   mods = "CTRL|SHIFT",
    --   action = wezterm.action_callback(function(window, pane)
    --     navigate_mode(window, pane, "Up", "w")
    --   end),
    -- },
    -- {
    --   key = "S",
    --   mods = "CTRL|SHIFT",
    --   action = wezterm.action_callback(function(window, pane)
    --     navigate_mode(window, pane, "Down", "s")
    --   end),
    -- },
    -- {
    --   key = "A",
    --   mods = "CTRL|SHIFT",
    --   action = wezterm.action_callback(function(window, pane)
    --     navigate_mode(window, pane, "Left", "a")
    --   end),
    -- },
    --
    -- {
    --   key = "D",
    --   mods = "CTRL|SHIFT",
    --   action = wezterm.action_callback(function(window, pane)
    --     navigate_mode(window, pane, "Right", "d")
    --   end),
    -- },
    --
    -- {
    -- 	key = "I",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		navigate_mode(window, pane, "Up", "i")
    -- 	end),
    -- },
    -- {
    -- 	key = "K",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		navigate_mode(window, pane, "Down", "k")
    -- 	end),
    -- },
    -- {
    -- 	key = "J",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		navigate_mode(window, pane, "Left", "j")
    -- 	end),
    -- },
    --
    -- {
    -- 	key = "L",
    -- 	mods = "CTRL|SHIFT",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		navigate_mode(window, pane, "Right", "l")
    -- 	end),
    -- },
    --
  }

  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return M
