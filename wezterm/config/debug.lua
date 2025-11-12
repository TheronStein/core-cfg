-- WezTerm Debug Configuration
-- This file controls debug logging for various WezTerm modules
-- Set flags to true to enable debug logging for specific categories

return {
  -- Config-level debugging
  debug_config_init = false,         -- Config initialization and module loading
  debug_config_duplicates = false,   -- Duplicate config key warnings
  debug_config_gpu = false,          -- GPU adapter selection

  -- GUI/Visual modules
  debug_mods_backdrops = false,      -- Backdrop system (image loading, switching, metadata)
  debug_mods_tabline = false,        -- Tabline components (tabs, status, rendering)
  debug_mods_themes = false,         -- Theme management (workspace themes, theme watcher)

  -- AI modules
  debug_mods_ai = false,             -- AI integration (CopilotChat, generators, helpers)

  -- Session/State modules
  debug_mods_resurrect = false,     -- Session resurrection (save/restore state)
  debug_mods_workspace = false,      -- Workspace management (workspace sessions, themes)
  debug_mods_bookmarks = false,     -- Bookmark system

  -- Utility modules
  debug_mods_utils = false,         -- General utilities (debugger, detection, navigation)

  -- Individual module overrides (for particularly noisy modules)
  debug_mods_smart_title = false,   -- Smart title component (very verbose when active)
  debug_mods_image_metadata = false, -- Image metadata loading (can be very verbose)

  -- Event debugging
  debug_key_events = false,        -- Debug key events (can be very verbose)

  -- Global debug flag (overrides all other flags when true)
  debug_all = false,
}