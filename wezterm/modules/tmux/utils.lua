-- ~/.core/.sys/configs/wezterm/events/tab-cleanup.lua
-- Cleanup temporary tmux views when tabs are closed
-- Monitor and close tabs when their tmux sessions die

local M = {}

-- Check if tmux is available
function M.is_tmux_available()
  local handle = io.popen("command -v tmux 2>/dev/null")
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

return M
