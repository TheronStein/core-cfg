local wezterm = require('wezterm')

return {
  default_opts = {
    icon = wezterm.nerdfonts.cod_terminal_tmux,
    show_when_not_in_tmux = false,
    fallback_text = '',
  },
  update = function(window, opts)
    local pane = window:active_pane()
    if not pane then
      return opts.show_when_not_in_tmux and opts.fallback_text or nil
    end

    -- Try to get TMUX from user vars (requires shell to export via OSC 1337)
    local user_vars = pane:get_user_vars()
    local tmux_env = user_vars.TMUX or user_vars.tmux_server

    -- If not in user_vars, try to get from foreground process info
    if not tmux_env or tmux_env == '' then
      local proc_info = pane:get_foreground_process_info()
      if proc_info and proc_info.environ then
        tmux_env = proc_info.environ.TMUX
      end
    end

    if not tmux_env or tmux_env == '' then
      return opts.show_when_not_in_tmux and opts.fallback_text or nil
    end

    -- Extract server name from the socket path
    -- Format: /tmp/tmux-{uid}/server_name,session_id,window_id
    local socket_path = tmux_env:match('^([^,]+)')
    if not socket_path then
      return opts.show_when_not_in_tmux and opts.fallback_text or nil
    end

    -- Get the server name (basename of the socket path)
    local server_name = socket_path:match('[^/]+$')

    return server_name or (opts.show_when_not_in_tmux and opts.fallback_text or nil)
  end,
}
