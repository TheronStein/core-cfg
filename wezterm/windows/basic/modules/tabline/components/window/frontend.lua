local wezterm = require('wezterm')

return {
  default_opts = {
    icon = wezterm.nerdfonts.md_monitor,
    show_label = true,
  },
  update = function(window, opts)
    local effective_config = window:effective_config()
    local frontend = effective_config.front_end or 'Unknown'
    
    if opts.show_label then
      return 'FE: ' .. frontend
    else
      return frontend
    end
  end,
}
