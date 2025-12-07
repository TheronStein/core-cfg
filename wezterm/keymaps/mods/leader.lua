local wezterm = require("wezterm")
-- local gui = require("wezterm.gui")
local act = wezterm.action
local paths = require("utils.paths")
-- local logger_leader = require("utils.logger").new({ prefix = "[LEADER]", debug_enabled = true })
-- local logger_ws_man = require("utils.logger").new({ prefix = "[WORKSPACE MANAGER]", debug_enabled = true })

-- Safely load optional modules
-- REMOVED: Old sessions.manager module (replaced by unified_workspace)
-- local ok1, session_manager = pcall(require, "sessions.manager")
-- if not ok1 then
-- 	session_manager = nil
-- end

local ok2, bookmarks = pcall(require, "bookmarks")
if not ok2 then
	bookmarks = nil
end

local ok3, toggle_terminal = pcall(require, "toggle_terminal")
if not ok3 then
	toggle_terminal = nil
end

local ok4, tab_templates = pcall(require, "tab_templates")
if not ok4 then
	tab_templates = nil
end

local ok5, claude_pane = pcall(require, "claude-pane")
if not ok5 then
	claude_pane = nil
end

local context_manager = require("modules.utils.context_manager")

local resize_highlight_color = "#FF0000"
local nav_highlight_color = "#00FF00"

local M = {}

--  ╭─────────────────────────────────────────────────────────╮
--  │                         LEADER                          │
--  ╰─────────────────────────────────────────────────────────╯
--    ┌ Keys:
--    │
--    │   F1,F2,
--    │   1,2,3,4,5,
--    │   A,C,D,G,R,S,T,P,V,W,X,Y,Z
--    │   /,;,
--    │
--    │   t - Load tab template
--    │   T (Shift+T) - Save current tab as template
--    │   T (Ctrl+T) - Quick load recent template
--    │   / - Toggle Claude AI pane (right sidebar with tmux)
--    └

function M.setup(config)
	config.keys = config.keys or {}

	local keys = {}

	-- Unified Workspace-Session Manager (replaces old session_manager and workspace_manager)
	local ok_unified, unified_workspace = pcall(require, "modules.sessions.unified_workspace")
	if ok_unified then
		wezterm.log_info("✅ Unified workspace manager loaded successfully")

		-- Main workspace menu
		table.insert(keys, {
			key = "F1",
			mods = "LEADER",
			desc = "Show workspace manager menu",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.show_menu(window, pane)
			end),
		})

		-- Quick workspace menu (same as F1, for muscle memory)
		table.insert(keys, {
			key = "w",
			mods = "LEADER",
			desc = "Show workspace manager menu",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.show_menu(window, pane)
			end),
		})

		-- Pane management
		table.insert(keys, {
			key = "m",
			mods = "LEADER",
			desc = "Move pane to another tab",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.move_pane_to_tab(window, pane)
			end),
		})

		table.insert(keys, {
			key = "g",
			mods = "LEADER",
			desc = "Grab pane from another tab",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.grab_pane_from_tab(window, pane)
			end),
		})
	else
		wezterm.log_error("❌ Failed to load unified_workspace: " .. tostring(unified_workspace))
	end

	-- -- Tab Management Menu (replaces bookmarks menu)
	-- local ok_tab_manager, tab_manager = pcall(require, "tab_manager")
	-- if ok_tab_manager then
	-- 	table.insert(keys, {
	-- 		key = "F2",
	-- 		mods = "LEADER",
	-- 		action = wezterm.action_callback(function(window, pane)
	-- 			tab_manager.show_main_menu(window, pane)
	-- 		end),
	-- 	})
	-- end

	-- Unified Tab Templates & Tmux Browser
	-- local ok_tab_tmux_browser, tab_tmux_browser = pcall(require, "modules.tab_tmux_browser")
	local ok_tmux_sessions, tmux_sessions = pcall(require, "modules.tmux.sessions")
	local ok_tmux_workspaces, tmux_workspaces = pcall(require, "modules.tmux.workspaces")
	--
	-- if ok_tab_tmux_browser then
	-- 	-- Unified browser for tab templates and tmux sessions
	-- 	table.insert(keys, {
	-- 		key = "t",
	-- 		mods = "LEADER", -- LEADER+t for unified browser
	-- 		action = wezterm.action_callback(function(window, pane)
	-- 			tab_tmux_browser.show_browser(window, pane)
	-- 		end),
	-- 	})
	-- end
	--
	-- -- Only add tab template bindings if module is loaded
	-- if tab_templates then
	-- 	-- Save current tab as template
	-- 	table.insert(keys, {
	-- 		key = "T",
	-- 		mods = "LEADER|SHIFT", -- LEADER+Shift+T to save template
	-- 		action = wezterm.action_callback(function(window, pane)
	-- 			tab_templates.save_current_tab_as_template(window, pane)
	-- 		end),
	-- 	})
	--
	-- 	-- Quick load most recent template
	-- 	table.insert(keys, {
	-- 		key = "T",
	-- 		mods = "LEADER|CTRL", -- LEADER+Ctrl+T for quick load
	-- 		action = wezterm.action_callback(function(window, pane)
	-- 			tab_templates.quick_load_recent(window, pane)
	-- 		end),
	-- 	})
	-- end

	-- Tmux workspace management
	if ok_tmux_workspaces then
		-- Moved to LEADER+SHIFT+A to avoid conflict with unified workspace switcher
		table.insert(keys, {
			key = "A",
			mods = "LEADER|SHIFT",
			desc = "Browse and manage tmux workspaces",
			action = wezterm.action_callback(function(window, pane)
				tmux_workspaces.show_workspace_browser(window, pane)
			end),
		})
	end

	-- TMUX Management menu (unified: attach, kill, toggle servers)
	if ok_tmux_workspaces then
		table.insert(keys, {
			key = "a",
			mods = "LEADER",
			desc = "TMUX Management (attach/kill/toggle servers)",
			action = wezterm.action_callback(function(window, pane)
				tmux_workspaces.show_workspace_handler_menu(window, pane, false)
			end),
		})
	end

	-- Add remaining keys
	local remaining_keys = {

		{
			key = "F2",
			mods = "LEADER",
			desc = "Set tab color",
			action = wezterm.action_callback(function(window, pane)
				local ok_color_picker, color_picker = pcall(require, "modules.tabs.tab_color_picker")
				if ok_color_picker then
					color_picker.show_color_picker(window, pane)
				else
					window:toast_notification("Tab Color Picker", "Module not loaded", nil, 2000)
				end
			end),
		},

		{
			key = "F3",
			mods = "LEADER",
			desc = "Browse Nerd Fonts icons",
			action = act.SpawnCommandInNewTab({
				args = { paths.WEZTERM_SCRIPTS .. "/nerdfont-browser/wezterm-browser.sh" },
			}),
		},

		-- Keymap browser (interactive keybinding browser with FZF)
		{
			key = "F4",
			mods = "LEADER",
			desc = "Browse keybindings (interactive)",
			action = act.SpawnCommandInNewTab({
				args = { paths.WEZTERM_SCRIPTS .. "/keymap-browser/keymap-browser.sh" },
			}),
		},

		-- New theme browser with live preview
		{
			key = "F5",
			mods = "LEADER",
			desc = "Browse and preview themes",
			action = wezterm.action_callback(function(window, pane)
				local workspace = window:active_workspace() or "default"

				-- Start theme watcher for live preview
				-- Use emit event instead of set_user_var
				window:perform_action(wezterm.action.EmitEvent("start-theme-watcher"), pane)

				-- Small delay to ensure watcher starts
				wezterm.time.call_after(0.1, function()
					-- Launch theme browser in new tab
					window:perform_action(
						act.SpawnCommandInNewTab({
							args = { paths.WEZTERM_SCRIPTS .. "/theme-browser/theme-browser.sh" },
							set_environment_variables = {
								WEZTERM_WORKSPACE = workspace,
								THEME_BROWSER_PREVIEW_MODE = "template",
							},
						}),
						pane
					)
				end)
			end),
		},

		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
		-- Tab management
		{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "`", mods = "LEADER", action = "ActivateCopyMode" },
		{ key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },

		{ key = "p", mods = "LEADER", action = wezterm.action.PaneSelect },
		-- Pane picker with arrows to swap positions
		{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },

		-- Cleanup orphaned tmux view sessions
		{
			key = "C",
			mods = "LEADER|SHIFT",
			desc = "Cleanup orphaned tmux view sessions",
			action = wezterm.action_callback(function(window, pane)
				local ok, tmux_sessions = pcall(require, "modules.tmux.sessions")
				if ok and tmux_sessions and tmux_sessions.is_tmux_available() then
					local count = tmux_sessions.cleanup_orphaned_views()
					if count > 0 then
						window:toast_notification(
							"Tmux Cleanup",
							"Cleaned up " .. count .. " orphaned view session(s)",
							nil,
							3000
						)
					else
						window:toast_notification("Tmux Cleanup", "No orphaned view sessions found", nil, 2000)
					end
				else
					window:toast_notification("Tmux Cleanup", "tmux not available", nil, 2000)
				end
			end),
		},

		{
			key = "v",
			mods = "LEADER",
			desc = "Split pane vertically (right)",
			action = wezterm.action_callback(function(window, pane)
				local cwd = pane:get_current_working_dir()
				if cwd then
					cwd = tostring(cwd):gsub("^file://[^/]*/", "/")
					window:perform_action(
						act.SplitPane({
							direction = "Right",
							command = {
								cwd = cwd,
							},
						}),
						pane
					)
				else
					window:perform_action(
						act.SplitPane({
							direction = "Right",
							domain = "CurrentPaneDomain",
						}),
						pane
					)
				end
			end),
		},

		{
			key = "V",
			mods = "LEADER",
			desc = "Split pane vertically (right)",
			action = wezterm.action_callback(function(window, pane)
				local cwd = pane:get_current_working_dir()
				if cwd then
					cwd = tostring(cwd):gsub("^file://[^/]*/", "/")
					window:perform_action(
						act.SplitPane({
							direction = "Left",
							command = {
								cwd = cwd,
							},
						}),
						pane
					)
				else
					window:perform_action(
						act.SplitPane({
							direction = "Left",
							domain = "CurrentPaneDomain",
						}),
						pane
					)
				end
			end),
		},

		-- Split Horizontal (Down) - splits from current working directory
		{
			key = "d",
			mods = "LEADER",
			desc = "Split pane horizontally (down)",
			action = wezterm.action_callback(function(window, pane)
				local cwd = pane:get_current_working_dir()
				if cwd then
					cwd = tostring(cwd):gsub("^file://[^/]*/", "/")
					window:perform_action(
						act.SplitPane({
							direction = "Down",
							command = {
								cwd = cwd,
							},
						}),
						pane
					)
				else
					window:perform_action(
						act.SplitPane({
							direction = "Down",
							domain = "CurrentPaneDomain",
						}),
						pane
					)
				end
			end),
			pane,
		},

		{
			key = "D",
			mods = "LEADER",
			desc = "Split pane horizontally (Up)",
			action = wezterm.action_callback(function(window, pane)
				local cwd = pane:get_current_working_dir()
				if cwd then
					cwd = tostring(cwd):gsub("^file://[^/]*/", "/")
					window:perform_action(
						act.SplitPane({
							direction = "Up",
							command = {
								cwd = cwd,
							},
						}),
						pane
					)
				else
					window:perform_action(
						act.SplitPane({
							direction = "Up",
							domain = "CurrentPaneDomain",
						}),
						pane
					)
				end
			end),
			pane,
		},

		-- Context toggle - using LEADER+CTRL+T to avoid conflict with tab templates
		{
			key = "t",
			mods = "LEADER",
			desc = "Toggle WezTerm/tmux context mode",
			action = wezterm.action_callback(function(window, pane)
				context_manager.toggle_context(window, pane)
			end),
		},

		-- Spotify Player pane (right sidebar) - toggleable
		{
			key = "s",
			mods = "LEADER",
			desc = "Toggle Spotify Player pane",
			action = wezterm.action_callback(require("modules.panes.toggle-spotify").toggle_spotify),
		},
	}
	--   {
	-- 	key = "y",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action_callback(require("modules.toggle_terminal").create("yazi-sidebar", {
	-- 		direction = "Left",
	-- 		size = { Percent = 35 },
	-- 		launch_command = "yazi",
	-- 		zoom = {
	-- 			auto_zoom_toggle_terminal = false,
	-- 			auto_zoom_invoker_pane = false,
	-- 			remember_zoomed = true,
	-- 		},
	-- 	})),
	-- },
	-- -- Yazi preview pane (right) - toggleable
	-- {
	-- 	key = "Y",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = wezterm.action_callback(require("modules.toggle_terminal").create("yazi-preview", {
	-- 		direction = "Right",
	-- 		size = { Percent = 35 },
	-- 		launch_command = "yazi",
	-- 		zoom = {
	-- 			auto_zoom_toggle_terminal = false,
	-- 			auto_zoom_invoker_pane = false,
	-- 			remember_zoomed = true,
	-- 		},
	-- 	})),
	-- },
	--
	-- Claude AI pane (right sidebar) - toggleable with tmux session management
	-- {
	-- 	key = "/",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		if claude_pane then
	-- 			claude_pane.toggle_claude_pane(window, pane)
	-- 		else
	-- 			wezterm.log_error("Claude pane module not loaded")
	-- 		end
	-- 	end),
	-- },
	--
	-- {
	-- 	key = "n",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local tab = window:mux_window():active_tab()
	-- 		local new_pane = tab:split_pane({
	-- 			direction = "Left",
	-- 			command = {
	-- 				args = { wezterm.home_dir .. "/.core/.sys/configs/wezterm/scripts/nerdfont-browser/wezterm-browser.sh" },
	-- 			},
	-- 			size = 0.75,
	-- 		})
	--
	-- 		-- Zoom the new pane
	-- 		new_pane:activate()
	-- 		window:perform_action(act.TogglePaneZoomState, new_pane)
	--
	-- 		-- Monitor the pane and close it when the script exits
	-- 		wezterm.time.call_after(0.5, function()
	-- 			local function check_and_close()
	-- 				if new_pane:pane_id() then
	-- 					local info = new_pane:get_foreground_process_info()
	-- 					if not info or info.status == "Exited" then
	-- 						window:perform_action(act.CloseCurrentPane({ confirm = false }), new_pane)
	-- 					else
	-- 						wezterm.time.call_after(0.5, check_and_close)
	-- 					end
	-- 				end
	-- 			end
	-- 			check_and_close()
	-- 		end)
	-- 	end),
	-- },
	--
	-- {
	-- 	key = "r",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local overrides = window:get_config_overrides() or {}
	-- 		overrides.colors = overrides.colors or {}
	-- 		overrides.colors.split = resize_highlight_color
	-- 		window:set_config_overrides(overrides)
	-- 		window:perform_action(
	-- 			act.ActivateKeyTable({
	-- 				name = "resize_pane",
	-- 				one_shot = false,
	-- 				timeout_milliseconds = 2000,
	-- 			}),
	-- 			pane
	-- 		)
	-- 	end),
	-- },
	-- {
	-- 	key = "Tab",
	-- 	mods = "LEADER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local overrides = window:get_config_overrides() or {}
	-- 		overrides.colors = overrides.colors or {}
	-- 		overrides.colors.split = nav_highlight_color
	-- 		window:set_config_overrides(overrides)
	-- 		window:perform_action(
	-- 			act.ActivateKeyTable({
	-- 				name = "resize_pane",
	-- 				one_shot = false,
	-- 				timeout_milliseconds = 2000,
	-- 			}),
	-- 			pane
	-- 		)
	-- 	end),
	-- },
	--
	--  ╭─────────────────────────────────────────────────────────╮
	--  │                    LEADER|CTRL                          │
	--  ╰─────────────────────────────────────────────────────────╯
	--    ┌ Keys:
	--    │
	--    │
	--    │
	--    └

	--  ╭─────────────────────────────────────────────────────────╮
	--  │                    LEADER|SHIFT                         │
	--  ╰─────────────────────────────────────────────────────────╯
	--    ┌ Keys:
	--    │
	--    │
	--    │
	--
	-- Unified workspace shortcuts (LEADER+SHIFT)
	if ok_unified then
		-- Quick workspace switcher
		table.insert(keys, {
			key = "W",
			mods = "LEADER|SHIFT",
			desc = "Quick switch workspace (isolated clients)",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.switch_workspace(window, pane)
			end),
		})

		-- Rename current workspace (works in default workspace too!)
		table.insert(keys, {
			key = "R",
			mods = "LEADER|SHIFT",
			desc = "Rename current workspace",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.rename_workspace(window, pane)
			end),
		})

		-- Save current session
		table.insert(keys, {
			key = "S",
			mods = "LEADER|SHIFT",
			desc = "Save current workspace session",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.save_session(window, pane)
			end),
		})

		-- Load session
		table.insert(keys, {
			key = "L",
			mods = "LEADER|SHIFT",
			desc = "Load workspace session",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.load_session(window, pane)
			end),
		})

		-- Move pane to its own tab
		table.insert(keys, {
			key = "T",
			mods = "LEADER|SHIFT",
			desc = "Move pane to its own tab",
			action = wezterm.action_callback(function(window, pane)
				unified_workspace.move_pane_to_own_tab(window, pane)
			end),
		})
	end

	-- Note: LEADER+SHIFT+A is now used for tmux workspace browser (see above)

	-- Merge remaining_keys into keys
	for _, key in ipairs(remaining_keys) do
		table.insert(keys, key)
	end

	for _, key in ipairs(keys) do
		table.insert(config.keys, key)
	end
end

return M

-- { key = "t", mods = "LEADER|CTRL", action = act.EmitEvent("tabs.manual-update-tab-title") },
-- { key = "y", mods = "LEADER|CTRL", action = act.EmitEvent("tabs.reset-tab-title") },
-- Move current pane to new tab
-- { key = "T", mods = "LEADER|CTRL", action = act.MovePane("NewTab") },

-- Move current pane to new window
-- { key = "@", mods = "LEADER|CTRL", action = act.MovePane("NewWindow") },
