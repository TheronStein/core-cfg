local wezterm = require('wezterm')

return {
  default_opts = {
    icons_enabled = false,  -- Don't use default icon
  },
  update = function(window, opts)
    local workspace = wezterm.mux.get_active_workspace()
    workspace = string.match(workspace, '[^/\\]+$')

    -- Get workspace metadata (icon, color)
    local workspace_metadata = require("modules.sessions.workspace_metadata")
    local metadata = workspace_metadata.get_metadata(workspace)

    -- Build workspace display string
    local display = ""

    -- Add workspace icon if set (as custom icon, not default)
    if metadata.icon and metadata.icon ~= "" then
      opts.icon = metadata.icon
      opts.icons_enabled = true
    end

    -- Add workspace name
    display = workspace

    -- Apply text color if set
    if metadata.color and metadata.color ~= "" then
      opts.color = {
        fg = metadata.color,
      }
    end

    -- Return display (tmux server is now shown separately in tabline_c)
    return display
  end,
}
