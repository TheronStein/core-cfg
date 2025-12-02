-- Event handler for workspace theme management
-- Automatically applies workspace-specific themes and manages theme watcher

local wezterm = require("wezterm")
local workspace_themes = require("modules.sessions.themes")
local theme_watcher = require("modules.sessions.theme_watcher")

local M = {}

function M.setup()
  -- NOTE: Workspace theme application on update-status moved to update-status-unified.lua
  -- This avoids event handler conflicts where only the last registered handler runs.

  -- Event handler for starting theme watcher
  wezterm.on("start-theme-watcher", function(window, pane)
    local workspace = window:active_workspace()
    if not theme_watcher.is_active(window) then
      theme_watcher.start_watcher(window, workspace)
      wezterm.log_info("Started theme watcher for workspace: " .. (workspace or "default"))
    end
  end)

  -- User var handler for theme browser integration
  wezterm.on("user-var-changed", function(window, pane, name, value)
    if name == "theme_applied" and value and value ~= "" then
      local workspace = window:active_workspace()
      if workspace then
        -- Save the theme to workspace (legacy system)
        workspace_themes.set_workspace_theme(workspace, value)

        -- ALSO save to metadata system (new persistent storage)
        local workspace_metadata = require("modules.sessions.workspace_metadata")
        workspace_metadata.set_theme(workspace, value)
        wezterm.log_info("Auto-saved theme '" .. value .. "' to workspace metadata '" .. workspace .. "'")

        wezterm.log_info("Saved theme '" .. value .. "' for workspace '" .. workspace .. "'")
      end
    elseif name == "stop_theme_watcher" then
      -- Stop theme watcher
      theme_watcher.stop_watcher(window)
      wezterm.log_info("Stopped theme watcher")
    end
  end)

  -- Window focus handler to start theme watcher if needed
  wezterm.on("window-focus-changed", function(window, pane)
    if window:is_focused() then
      local workspace = window:active_workspace()

      -- Check if a preview file exists for this workspace
      local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
      local preview_file
      if workspace and workspace ~= "" then
        preview_file = string.format("%s/wezterm_theme_preview_%s.txt", runtime_dir, workspace)
      else
        preview_file = runtime_dir .. "/wezterm_theme_preview.txt"
      end

      -- If preview file exists and has content, start watcher
      local f = io.open(preview_file, "r")
      if f then
        local content = f:read("*line")
        f:close()

        if content and content ~= "" and not theme_watcher.is_active(window) then
          theme_watcher.start_watcher(window, workspace)
          wezterm.log_info("Auto-started theme watcher for workspace: " .. (workspace or "default"))
        end
      end
    end
  end)

  wezterm.log_info("Workspace theme handler initialized")
end

return M
