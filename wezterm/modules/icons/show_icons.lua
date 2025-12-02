  local wezterm = require 'wezterm'

  local icons = {}
  for name, icon in pairs(wezterm.nerdfonts) do
    table.insert(icons, {label = icon .. '  ' .. name, id = name})
  end

  table.sort(icons, function(a, b) return a.id < b.id end)

  wezterm.gui.enumerate_gpus()  -- dummy call to access gui

  -- Print all icons
  for _, item in ipairs(icons) do
    print(item.label)
  end
