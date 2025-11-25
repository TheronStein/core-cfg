wezterm.on("workspace-changed", function(window, pane, new_name)
	wezterm.log_info("Workspace changed to: " .. new_name)

	local ws_config = workspace_manager.get_workspace_config(new_name)
	if ws_config and ws_config.tmux_session then
		auto_tmux_session.attach_to_session(ws_config.tmux_session, pane)
	end

	session_manager.reload_for_workspace(window, new_name)
end)
