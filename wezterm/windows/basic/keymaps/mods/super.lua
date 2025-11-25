local wezterm = require("wezterm")
local act = wezterm.action
local backdrops = require("modules.gui.backdrops")
local ok, resurrect = pcall(require, "modules.resurrect")
if not ok then
	ok, resurrect = pcall(require, "resurrect")
end
if not ok then
	resurrect = nil
	wezterm.log_warn("Failed to load resurrect module")
end

local M = {}

function M.setup(config)
	config.keys = config.keys or {}

	local keys = {

		--  ╭─────────────────────────────────────────────────────────╮
		--  │                       SUPER                             │
		--  ╰─────────────────────────────────────────────────────────╯
		--    ┌ Keys:
		--    │
		--      W,S,A,D
		--    │ F12,F2,S,D,=,-
		--    │
		--    └
		-- Disable Shift+Space
		{
			key = "w",
			mods = "SUPER",
			action = wezterm.action.DisableDefaultAssignment,
		},

		{ key = "UpArrow", mods = "SUPER", action = act.ScrollByPage(-1) },
		{ key = "DownArrow", mods = "SUPER", action = act.ScrollByPage(1) },
		{ key = "i", mods = "SUPER", action = act.ActivatePaneDirection("Up") },
		{ key = "k", mods = "SUPER", action = act.ActivatePaneDirection("Down") },
		{ key = "j", mods = "SUPER", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "SUPER", action = act.ActivatePaneDirection("Right") },
		{ key = "u", mods = "SUPER", action = act.ActivateTabRelative(-1) },
		{ key = "o", mods = "SUPER", action = act.ActivateTabRelative(1) },

		--  ╭─────────────────────────────────────────────────────────╮
		--  │                     SUPER|SHIFT                         │
		--  ╰─────────────────────────────────────────────────────────╯
		--    ┌ Keys:
		--    │
		--    │  F1,D,O,U
		--    │
		--    └
		{ key = "u", mods = "SUPER|SHIFT", action = act.MoveTabRelative(-1) },
		{ key = "o", mods = "SUPER|SHIFT", action = act.MoveTabRelative(1) },

		--  ╭─────────────────────────────────────────────────────────╮
		--  │                     SUPER|ALT                           │
		--  ╰─────────────────────────────────────────────────────────╯
		--    ┌ Keys:
		--    │
		--    │ E,Q,R,S,T,O (backdrop controls)
		--    │
		--    └

		-- Backdrop controls
		{
			key = "e",
			mods = "SUPER|ALT",
			desc = "Cycle to next backdrop",
			action = wezterm.action_callback(function(window, pane)
				backdrops:cycle_forward(window)
			end),
		},
		{
			key = "q",
			mods = "SUPER|ALT",
			desc = "Cycle to previous backdrop",
			action = wezterm.action_callback(function(window, pane)
				backdrops:cycle_back(window)
			end),
		},
		{
			key = "r",
			mods = "SUPER|ALT",
			desc = "Select random backdrop",
			action = wezterm.action_callback(function(window, pane)
				backdrops:random(window)
			end),
		},
		{
			key = "s",
			mods = "SUPER|ALT",
			desc = "Show backdrop selector",
			action = wezterm.action_callback(function(window, pane)
				-- Backdrop selector with fzf (if implemented)
				window:perform_action(
					act.InputSelector({
						title = "Select Backdrop",
						choices = backdrops:choices(),
						fuzzy = true,
						action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
							if id then
								backdrops:set_img(inner_window, tonumber(id))
							end
						end),
					}),
					pane
				)
			end),
		},
		{
			key = "t",
			mods = "SUPER|ALT",
			desc = "Toggle backdrops on/off",
			action = wezterm.action_callback(function(window, pane)
				local enabled = backdrops:toggle_backgrounds(window)
				local status = enabled and "ENABLED" or "DISABLED"
				window:toast_notification("WezTerm", "Backgrounds " .. status, nil, 2000)
			end),
		},
		{
			key = "o",
			mods = "SUPER|ALT",
			action = wezterm.action.EmitEvent("trigger-overlay-mode-picker"),
		},

		--    └
		--  ╭─────────────────────────────────────────────────────────╮
		--  │                     SUPER|CTRL                           │
		--  ╰─────────────────────────────────────────────────────────╯
		--    ┌ Keys:
		--    │
		--    │ F1,A,C,E,F,L,M,O,R,S,T,V,
		--    │
		--    └
	}
	--
	-- -- Add resurrect keybindings only if module is available
	-- if resurrect and resurrect.state_manager and resurrect.workspace_state then
	-- 	table.insert(keys, {
	-- 		key = "w",
	-- 		mods = "SUPER|CTRL",
	-- 		action = wezterm.action_callback(function(win, pane)
	-- 			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
	-- 		end),
	-- 	})
	--
	-- 	if resurrect.window_state then
	-- 		table.insert(keys, {
	-- 			key = "W",
	-- 			mods = "SUPER|CTRL",
	-- 			action = resurrect.window_state.save_window_action(),
	-- 		})
	-- 	end
	--
	-- 	if resurrect.tab_state then
	-- 		table.insert(keys, {
	-- 			key = "T",
	-- 			mods = "SUPER|CTRL",
	-- 			action = resurrect.tab_state.save_tab_action(),
	-- 		})
	-- 	end
	--
	-- 	table.insert(keys, {
	-- 		key = "s",
	-- 		mods = "SUPER|CTRL",
	-- 		action = wezterm.action_callback(function(win, pane)
	-- 			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
	-- 			if resurrect.window_state then
	-- 				resurrect.window_state.save_window_action()
	-- 			end
	-- 		end),
	-- 	})
	--
	-- 	if resurrect.fuzzy_loader then
	-- 		table.insert(keys, {
	-- 			key = "r",
	-- 			mods = "SUPER|CTRL",
	-- 			action = wezterm.action_callback(function(win, pane)
	-- 				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
	-- 					local type = string.match(id, "^([^/]+)") -- match before '/'
	-- 					id = string.match(id, "([^/]+)$") -- match after '/'
	-- 					id = string.match(id, "(.+)%..+$") -- remove file extention
	-- 					local opts = {
	-- 						relative = true,
	-- 						restore_text = true,
	-- 						on_pane_restore = resurrect.tab_state and resurrect.tab_state.default_on_pane_restore
	-- 							or nil,
	-- 					}
	-- 					if type == "workspace" and resurrect.workspace_state then
	-- 						local state = resurrect.state_manager.load_state(id, "workspace")
	-- 						resurrect.workspace_state.restore_workspace(state, opts)
	-- 					elseif type == "window" and resurrect.window_state then
	-- 						local state = resurrect.state_manager.load_state(id, "window")
	-- 						resurrect.window_state.restore_window(pane:window(), state, opts)
	-- 					elseif type == "tab" and resurrect.tab_state then
	-- 						local state = resurrect.state_manager.load_state(id, "tab")
	-- 						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
	-- 					end
	-- 				end)
	-- 			end),
	-- 		})
	-- 	end
	-- end
	--
	for _, key in ipairs(keys) do
		table.insert(config.keys, key)
	end
end

return M
