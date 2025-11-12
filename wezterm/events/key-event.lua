local wezterm = require"wezterm"

local M = {}

function M.setup()
  -- Example: Hook into key events if you want custom handling (optional, requires WezTerm nightly or recent version)
  wezterm.on("key-event", function(window, pane, key, mods, event)
    log_key_event({ key = key, mods = mods, event = event }) -- Custom log for every key
    return true -- Allow the event to propagate
  end)
end

return M
