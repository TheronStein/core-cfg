-- Smart workspace switcher events
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	local workspace_state = resurrect.workspace_state
	local state = resurrect.state_manager.load_state(label, "workspace")
	if state then
		workspace_state.restore_workspace(state, {
			window = window,
			relative = true,
			restore_text = true,
			on_pane_restore = resurrect.tab_state.default_on_pane_restore,
		})
	end
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	local workspace_state = resurrect.workspace_state
	local state = workspace_state.get_workspace_state()
	if state then
		state.name = label
		resurrect.state_manager.save_state(state)
	end
end)
