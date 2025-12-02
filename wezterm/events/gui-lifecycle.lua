-- Unified GUI lifecycle event handler
-- Handles all GUI lifecycle events:
--   - gui-startup
--   - gui-shutdown
--
-- Consolidates logic from:
--   - backdrop-cycle.lua (gui-startup)
--   - copilot-chat-init.lua (gui-startup)
--   - gui-startup.lua (gui-startup)
--   - tab-cleanup.lua (gui-shutdown)

local wezterm = require("wezterm")
local debug_config = require("config.debug")

local M = {}

-- ============================================================================
-- GUI STARTUP
-- ============================================================================
function M.handle_gui_startup(cmd)
	-- Initialize window counter for unique IDs
	wezterm.GLOBAL.window_counter = wezterm.GLOBAL.window_counter or 0

	-- Log backdrop initialization
	if debug_config.is_enabled("debug_mods_backdrop_events") then
		wezterm.log_info("[EVENT:BACKDROP] GUI started, backdrops initialized")
	end

	-- Initialize CopilotChat with configuration
	local ok, copilot_chat = pcall(require, "modules.copilot_chat_tui")
	if ok and copilot_chat then
		copilot_chat:setup({
			api = {
				provider = "anthropic", -- Default to Anthropic
				model = "claude-3-5-sonnet-20241022", -- Claude 3.5 Sonnet
				temperature = 0.1,
				onepassword = {
					enabled = true,
					vault = "dev",
					items = {
						anthropic = "ANTHROPIC API KEY",
						openai = "OpenAI API",
						github = "GitHub",
					},
					fields = {
						anthropic = "credential",
						openai = "credential",
						github = "token",
					},
				},
			},
			ui = {
				position = "right",
				width = 0.4,
			},
			chat = {
				system_prompt = [[You are an AI programming assistant integrated into WezTerm.
Follow the user's requirements carefully & to the letter.
Keep responses concise but informative.
Use Markdown formatting for code blocks with language tags.
When discussing code, focus on practical solutions.]],
				auto_save = true,
			},
		})

		wezterm.log_info("[CopilotChat] Module initialized on startup")
	end

	wezterm.log_info("[EVENT:GUI] GUI startup complete")
end

-- ============================================================================
-- GUI SHUTDOWN
-- ============================================================================
function M.handle_gui_shutdown()
	wezterm.log_info("WezTerm shutting down, cleaning up all orphaned tmux views")

	-- Clean up all orphaned tmux views on shutdown
	local ok, tmux_sessions = pcall(require, "modules.tmux.sessions")
	if ok and tmux_sessions then
		tmux_sessions.cleanup_orphaned_views()
	end

	wezterm.log_info("[EVENT:GUI] GUI shutdown cleanup complete")
end

-- ============================================================================
-- SETUP
-- ============================================================================
function M.setup()
	if wezterm.GLOBAL.gui_lifecycle_initialized then
		return
	end
	wezterm.GLOBAL.gui_lifecycle_initialized = true

	-- GUI startup event
	wezterm.on("gui-startup", function(cmd)
		M.handle_gui_startup(cmd)
	end)

	-- GUI shutdown event
	wezterm.on("gui-shutdown", function()
		M.handle_gui_shutdown()
	end)

	-- Custom event for CopilotChat prompt input
	wezterm.on("copilot-chat.prompt-input", function(window, pane)
		local ok, copilot_chat = pcall(require, "modules.copilot_chat_tui")
		if ok and copilot_chat then
			window:perform_action(
				wezterm.action.PromptInputLine({
					description = "Copilot Chat:",
					action = wezterm.action_callback(function(inner_window, inner_pane, line)
						if line then
							copilot_chat:handle_input(line)
						end
					end),
				}),
				pane
			)
		end
	end)

	wezterm.log_info("[EVENT] GUI lifecycle handlers initialized")
end

return M
