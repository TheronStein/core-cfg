local wezterm = require("wezterm")

local M = {}

function M.setup()

-- Helper function to reload themes (can be called from keybinding)
local function reload_themes()
    workspace_themes = load_workspace_themes()
    wezterm.emit("reload-tabline-themes")
end

-- Add keybinding to reload tabline themes
    wezterm.on("reload-tabline-themes", function(window, pane)
        workspace_themes = load_workspace_themes()
        window:toast_notification("Tabline", "Themes reloaded", nil, 2000)
        -- Force refresh
        window:set_config_overrides({
            tab_bar_at_bottom = config.tab_bar_at_bottom,
        })
    end)
end

return M

-- Export the apply function and reload helper
-- return function(config)
--     apply_tabline(config)
-- end

