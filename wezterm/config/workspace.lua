-- ~/.core/.sys/cfg/wezterm/config/workspace.lua
-- Workspace-specific configuration settings

return {
	-- Auto-save workspace state every N seconds (0 = disabled)
	workspace_auto_save_interval = 300, -- 5 minutes

	-- Enable automatic Neovim session integration
	workspace_nvim_integration = true,

	-- Enable workspace locking (multi-client protection)
	workspace_locking_enabled = true,

	-- Clean up stale locks on startup
	workspace_cleanup_stale_locks = true,

	-- Clean up orphaned metadata on startup
	workspace_cleanup_orphaned_metadata = true,

	-- Default workspace color (empty = no default)
	workspace_default_color = "",

	-- Save workspace theme automatically when changed
	workspace_auto_save_theme = true,

	-- Workspace session compression (for future use)
	workspace_session_compression = false,

	-- Maximum number of workspace backups to keep
	workspace_max_backups = 5,

	-- Enable workspace state persistence
	workspace_persistence_enabled = true,

	-- Workspace state save delay after changes (milliseconds)
	-- Prevents excessive saves during rapid changes
	workspace_save_debounce = 2000, -- 2 seconds
}
