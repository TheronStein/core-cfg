local wezterm = require("wezterm")
local act = wezterm.action
local context_manager = require("modules.utils.context_manager")

local M = {}

-- Tmux key mappings reference
-- https://github.com/tmux/tmux/wiki/Getting-Started#key-bindings
--
-- Common tmux bindings (with prefix Ctrl+Space):
--   c - create window
--   , - rename window
--   n - next window
--   p - previous window
--   w - list windows
--   & - kill window
--   x - kill pane
--   % - split vertically
--   " - split horizontally
--   o - next pane
--   ; - last pane
--   q - show pane numbers
--   z - toggle pane zoom
--   [ - enter copy mode
--   ] - paste buffer
--   arrow keys - navigate panes

function M.setup(config)
	config.keys = config.keys or {}

	local keys = {
		-- Context toggle - using LEADER+CTRL+T to avoid conflict with tab templates
		{
			key = "T",
			mods = "LEADER|CTRL",
			action = wezterm.action_callback(function(window, pane)
				context_manager.toggle_context(window, pane)
			end),
		},

		--  ╭─────────────────────────────────────────────────────────╮
		--  │              Window/Tab Management                      │
		--  ╰─────────────────────────────────────────────────────────╯

		-- NOTE: These basic bindings are now context-aware!
		-- When in tmux mode, they send tmux commands instead

		-- Create new window/tab
		-- tmux: c
		{
			key = "c",
			mods = "LEADER",
			action = context_manager.context_action("c", act.SpawnTab("CurrentPaneDomain")),
		},

		-- Close pane
		-- tmux: x
		{
			key = "x",
			mods = "LEADER",
			action = context_manager.context_action("x", act.CloseCurrentPane({ confirm = false })),
		},

		-- Toggle pane zoom
		-- tmux: z
		{
			key = "z",
			mods = "LEADER",
			action = context_manager.context_action("z", act.TogglePaneZoomState),
		},

		-- Next tab/window
		-- tmux: n
		-- Note: You might want to add this if not already present
		-- {
		-- 	key = "n",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action("n", act.ActivateTabRelative(1)),
		-- },

		-- Previous tab/window
		-- tmux: p
		-- {
		-- 	key = "p",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action("p", act.ActivateTabRelative(-1)),
		-- },

		--  ╭─────────────────────────────────────────────────────────╮
		--  │                   Pane Splits                           │
		--  ╰─────────────────────────────────────────────────────────╯

		-- NOTE: d and v are already bound in leader.lua for splits
		-- These would override them to be context-aware
		-- Split vertical (right)
		-- tmux: %
		-- {
		-- 	key = "d",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action("%", act.SplitVertical({ domain = "CurrentPaneDomain" })),
		-- },

		-- Split horizontal (down)
		-- tmux: "
		-- {
		-- 	key = "v",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action('"', act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
		-- },

		-- Alternative split bindings
		-- tmux: % (vertical split)
		{
			key = "|",
			mods = "LEADER|SHIFT",
			action = context_manager.context_action("%", act.SplitVertical({ domain = "CurrentPaneDomain" })),
		},

		-- tmux: " (horizontal split)
		{
			key = "-",
			mods = "LEADER",
			action = context_manager.context_action('"', act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
		},

		--  ╭─────────────────────────────────────────────────────────╮
		--  │                    Navigation                           │
		--  ╰─────────────────────────────────────────────────────────╯

		-- NOTE: Navigation bindings commented out due to conflicts
		-- LEADER+a = tmux attach, LEADER+w = workspace menu, LEADER+d = split, etc.
		-- You can uncomment specific ones you want to make context-aware

		-- Pane navigation - hjkl
		-- tmux: h/j/k/l (with prefix then arrow keys, but we'll use hjkl)
		-- {
		-- 	key = "h",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action(
		-- 		{ key = "LeftArrow" },
		-- 		act.ActivatePaneDirection("Left")
		-- 	),
		-- },
		--
		-- {
		-- 	key = "j",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action(
		-- 		{ key = "DownArrow" },
		-- 		act.ActivatePaneDirection("Down")
		-- 	),
		-- },
		--
		-- {
		-- 	key = "k",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action(
		-- 		{ key = "UpArrow" },
		-- 		act.ActivatePaneDirection("Up")
		-- 	),
		-- },
		--
		-- {
		-- 	key = "l",
		-- 	mods = "LEADER",
		-- 	action = context_manager.context_action(
		-- 		{ key = "RightArrow" },
		-- 		act.ActivatePaneDirection("Right")
		-- 	),
		-- }

		--  ╭─────────────────────────────────────────────────────────╮
		--  │                   Copy Mode                             │
		--  ╰─────────────────────────────────────────────────────────╯

		-- Enter copy mode
		-- tmux: [
		{
			key = "[",
			mods = "LEADER",
			action = context_manager.context_action("[", act.ActivateCopyMode),
		},

		-- Alternative copy mode binding
		{
			key = "`",
			mods = "LEADER",
			action = context_manager.context_action("[", act.ActivateCopyMode),
		},
	}

	-- Add all context-aware keys
	for _, key in ipairs(keys) do
		table.insert(config.keys, key)
	end
end

return M
