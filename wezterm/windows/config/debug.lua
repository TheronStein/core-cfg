-- WezTerm Debug Configuration
-- This file controls debug logging for various WezTerm modules
-- Set flags to true to enable debug logging for specific categories

local M = {
  -- ============================================================================
  -- CONFIG-LEVEL DEBUGGING
  -- ============================================================================
  debug_config_init = false,         -- Config initialization and module loading
  debug_config_duplicates = false,   -- Duplicate config key warnings
  debug_config_gpu = false,          -- GPU adapter selection

  -- ============================================================================
  -- KEYMAPS
  -- ============================================================================
  debug_keymaps_init = false,        -- Keymap initialization and setup
  debug_keymaps_groups = false,      -- Keymap group loading (modes, panes, etc)
  debug_key_events = false,          -- Key event processing (very verbose)

  -- ============================================================================
  -- TABLINE DEBUGGING (granular control)
  -- ============================================================================
  debug_tabline_init = false,        -- Tabline initialization
  debug_tabline_events = false,      -- Event handlers (update-status, format-tab-title)
  debug_tabline_components = false,  -- Component loading and rendering
  debug_tabline_tabs = false,        -- Tab rendering and formatting
  debug_tabline_tmux = false,        -- Tmux-related components and user vars
  debug_tabline_colors = false,      -- Tabline color calculations (b_bg, workspace colors)
  debug_tabline_smart_title = false, -- Smart title component (very verbose when active)
  debug_tabline_all = false,         -- All tabline debug logs

  -- ============================================================================
  -- GUI/VISUAL MODULES
  -- ============================================================================
  debug_mods_backdrops = false,      -- Backdrop system (image loading, switching)
  debug_mods_backdrop_metadata = false, -- Image metadata loading (can be very verbose)
  debug_mods_backdrop_events = false,   -- Backdrop event handlers (cycle, opacity, refresh)
  debug_mods_themes = false,         -- Theme management (workspace themes, theme watcher)
  debug_mods_icons = false,          -- Icon systems (custom_icons, mdi_icons, nerdfonts)

  -- ============================================================================
  -- SESSION/STATE MODULES
  -- ============================================================================
  debug_mods_resurrect = false,      -- Session resurrection (save/restore state)
  debug_mods_workspace = false,      -- Workspace management (workspace sessions, themes)
  debug_mods_workspace_templates = false, -- Workspace templates (save/load)
  debug_mods_workspace_themes = false,    -- Workspace-specific theme management
  debug_mods_session_manager = false, -- Session manager (pane/tab management)
  debug_mods_bookmarks = false,      -- Bookmark system
  debug_mods_tmux_workspaces = false, -- Tmux workspace management
  debug_mods_tmux_sessions = false,  -- Tmux session browser/selector
  debug_mods_tab_templates = false,  -- Tab template management
  debug_mods_tab_rename = false,     -- Tab renaming operations

  -- ============================================================================
  -- AI MODULES
  -- ============================================================================
  debug_mods_ai = false,             -- AI integration (CopilotChat, generators, helpers)
  debug_mods_ai_copilot = false,     -- CopilotChat initialization and events
  debug_mods_ai_generators = false,  -- AI generators (ollama, google, lm_studio)
  debug_mods_ai_commander = false,   -- AI command interface

  -- ============================================================================
  -- UTILITY MODULES
  -- ============================================================================
  debug_mods_utils = false,          -- General utilities (debugger, detection, navigation)
  debug_mods_notifications = false,  -- Notification system
  debug_mods_listeners = false,      -- Event listener utilities

  -- ============================================================================
  -- EVENT HANDLERS
  -- ============================================================================
  debug_events_gui_startup = false,  -- GUI startup events
  debug_events_window = false,       -- Window events (config-reloaded, etc)
  debug_events_workspace = false,    -- Workspace change events
  debug_events_user_var = false,     -- User variable updates (tmux session/window info)
  debug_events_tab_cleanup = false,  -- Tab cleanup operations
  debug_events_status = false,       -- Status update events

  -- ============================================================================
  -- GLOBAL FLAGS
  -- ============================================================================
  debug_all = false,                 -- Enable ALL debug logs (overrides everything)
}

-- Helper function to check if a debug flag is enabled
function M.is_enabled(flag)
  if M.debug_all then
    return true
  end

  -- Check tabline_all for tabline-specific flags
  if flag:match("^debug_tabline_") and M.debug_tabline_all then
    return true
  end

  return M[flag] == true
end

return M