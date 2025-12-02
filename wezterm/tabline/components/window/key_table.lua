local wezterm = require('wezterm')

return {
  default_opts = {
    icon = wezterm.nerdfonts.md_keyboard,
  },
  update = function(window, opts)
    local key_table = window:active_key_table()
    if key_table then
      return key_table:upper()
    else
      return 'NORMAL'
    end
  end,
}
