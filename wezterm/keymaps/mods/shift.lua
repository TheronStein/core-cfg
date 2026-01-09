local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.setup(config)
  config.keys = config.keys or {}

  local keys = {
    --          ╭─────────────────────────────────────────────────────────╮
    --          │                         SHIFT                           │
    --          ╰─────────────────────────────────────────────────────────╯
    {
      key = "Space",
      mods = "SHIFT",
      action = wezterm.action.SendString(" "),
    },

    -- -- Disable Shift+Space
    -- {
    -- 	key = "Space",
    -- 	mods = "SHIFT",
    -- 	action = wezterm.action.DisableDefaultAssignment,
    -- },
    -- { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
    { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
    { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
    -- { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
  }

  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return M
