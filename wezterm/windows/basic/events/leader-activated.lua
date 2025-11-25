local wezterm = require("wezterm")

local M = {}

function M.setup()
  -- Listen for leader activation
  wezterm.on("update-status", function(window, pane)
    local leader_active = window:leader_is_active()

    if leader_active then
      wezterm.GLOBAL.current_mode = "LEADER"
      wezterm.GLOBAL.leader_active = true
    else
      -- Only reset if we were in leader mode
      if wezterm.GLOBAL.leader_active then
        wezterm.GLOBAL.current_mode = "CORE"
        wezterm.GLOBAL.leader_active = false
      end
    end
  end)
end

return M
