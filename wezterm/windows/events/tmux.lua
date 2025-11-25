wezterm.on("tmux-session-renamed", function(old_name, new_name)
	session_manager.rename_session(old_name, new_name)
end)

wezterm.on("tmux-session-deleted", function(session_name)
	session_manager.mark_as_unused(session_name)
end)
