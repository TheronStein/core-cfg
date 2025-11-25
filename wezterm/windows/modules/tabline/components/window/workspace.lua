local wezterm = require('wezterm')

return {
  default_opts = {
    icon = wezterm.nerdfonts.cod_terminal_tmux,
  },
  update = function(window)
    local workspace = wezterm.mux.get_active_workspace()
    workspace = string.match(workspace, '[^/\\]+$')

    -- Try to get tmux server info if attached to tmux
    local pane = window:active_pane()
    if pane then
      -- Try to get TMUX from user vars (requires shell to export via OSC 1337)
      local user_vars = pane:get_user_vars()
      local tmux_env = user_vars.TMUX

      -- If not in user_vars, try to get from foreground process info
      if not tmux_env or tmux_env == '' then
        local proc_info = pane:get_foreground_process_info()
        if proc_info and proc_info.environ then
          tmux_env = proc_info.environ.TMUX
        end
      end

      if tmux_env and tmux_env ~= '' then
        -- Extract server name from the socket path
        -- Format: /tmp/tmux-{uid}/server_name,session_id,window_id
        local socket_path = tmux_env:match('^([^,]+)')
        if socket_path then
          -- Get the server name (basename of the socket path)
          local server_name = socket_path:match('[^/]+$')
          if server_name then
            return workspace .. ' (' .. server_name .. ')'
          end
        end
      end
    end

    return workspace
  end,
}
