local wezterm = require('wezterm')

return {
  default_opts = {},
  update = function(tab, opts)
    -- Check if this tab has a custom title set
    if wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab.tab_id] then
      return wezterm.GLOBAL.custom_tabs[tab.tab_id].title
    end
    return nil
  end,
}
