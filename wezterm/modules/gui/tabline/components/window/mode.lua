local wezterm = require("wezterm")

local M = {}

function M.get(window)
  -- Check if leader is active first
  if window:leader_is_active() then
    return 'leader_mode'
  end

  local key_table = window:active_key_table()

  if key_table == nil or not key_table:find('_mode$') then
    key_table = 'core_mode'
  end

  return key_table
end

return {
  default_opts = {},
  get = M.get,
  update = function(window, opts)
    local mode = M.get(window):gsub('_mode', '')
    mode = mode:upper()
    return mode
  end,
}
