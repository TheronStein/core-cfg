local wezterm = require('wezterm')

return {
  default_opts = {},
  update = function(tab, opts)
    -- Check if this tab has a custom icon set
    if wezterm.GLOBAL.custom_tabs and wezterm.GLOBAL.custom_tabs[tab.tab_id] then
      local icon_key = wezterm.GLOBAL.custom_tabs[tab.tab_id].icon_key
      if icon_key then
        -- Get the icon from the process component
        local process_comp = require('tabline.components.tab.process')
        local icon_data = process_comp.default_opts.process_to_icon[icon_key]
        if icon_data then
          -- Update opts with the icon data
          if type(icon_data) == 'table' then
            opts.icon = icon_data
          else
            opts.icon = icon_data
          end
          return ''  -- Return empty string since we only want the icon
        end
      end
    end
    return nil
  end,
}
