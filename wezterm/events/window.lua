
local wezterm = require("wezterm")


local M = {}

-- Track last cycle time per window
local last_cycle = {}
local CYCLE_INTERVAL = 300 -- seconds
local CONFIG_RELOAD = 1

function M.setup()

  wezterm.on("window-created", function(window, pane)
    start_theme_watcher(window) -- pass the correct GUI window
    -- local title = pane:get_title() or ""
    local session_name = pane:inject_output("tmux display-message -p '#S'\n")
    window.set_title(session_name)
    pane.set_title(session_name)
  end)

    wezterm.on("window-config-reloaded", function(window, pane)
        start_theme_watcher(window)
        local window_id = tostring(window:window_id())
        -- Set initial backdrop for new window
        if not last_cycle[window_id] then
          backdrops:set_img(window, 1)
          wezterm.log_info("Initial backdrop set for window " .. window_id)
        end
      -- window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
    end)
  end
end

return M









