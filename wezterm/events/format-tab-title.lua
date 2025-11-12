local wezterm = require 'wezterm'

local M = {}

function M.setup()
  wezterm.on('format-tab-title', function(tab)
    local prog = tab.active_pane.user_vars.PROG
    return tab.active_pane.title .. ' [' .. (prog or '') .. ']'
  end)
end 

return M

