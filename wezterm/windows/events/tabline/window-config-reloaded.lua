-- Optional: Hook into other events for dynamic updates (e.g., mode changes)
wezterm.on('window-config-reloaded', function(window, pane)
  tabline_component.set_status(window)  -- Refresh on config reload
end
