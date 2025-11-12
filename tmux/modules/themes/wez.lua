-- Define workspace themes
local workspace_themes = {
	default = {
		colors = {
			tab_bar = {
				background = "#1a1b26",
				active_tab = {
					bg_color = "#7aa2f7",
					fg_color = "#1a1b26",
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = "#292e42",
					fg_color = "#545c7e",
				},
				inactive_tab_hover = {
					bg_color = "#3b4261",
					fg_color = "#7aa2f7",
				},
				new_tab = {
					bg_color = "#292e42",
					fg_color = "#7aa2f7",
				},
				new_tab_hover = {
					bg_color = "#3b4261",
					fg_color = "#9ece6a",
				},
			},
		},
		tmux_theme = "tokyo-night",
	},
	development = {
		colors = {
			tab_bar = {
				background = "#0f1419",
				active_tab = {
					bg_color = "#9ece6a",
					fg_color = "#0f1419",
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = "#1a2633",
					fg_color = "#565f89",
				},
				inactive_tab_hover = {
					bg_color = "#273644",
					fg_color = "#9ece6a",
				},
				new_tab = {
					bg_color = "#1a2633",
					fg_color = "#9ece6a",
				},
				new_tab_hover = {
					bg_color = "#273644",
					fg_color = "#b4f9f8",
				},
			},
		},
		tmux_theme = "developer-green",
	},
	monitoring = {
		colors = {
			tab_bar = {
				background = "#1e0010",
				active_tab = {
					bg_color = "#f7768e",
					fg_color = "#1e0010",
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = "#3d001f",
					fg_color = "#914c54",
				},
				inactive_tab_hover = {
					bg_color = "#5c002f",
					fg_color = "#f7768e",
				},
				new_tab = {
					bg_color = "#3d001f",
					fg_color = "#f7768e",
				},
				new_tab_hover = {
					bg_color = "#5c002f",
					fg_color = "#ff9e64",
				},
			},
		},
		tmux_theme = "monitoring-red",
	},
	productivity = {
		colors = {
			tab_bar = {
				background = "#001020",
				active_tab = {
					bg_color = "#2ac3de",
					fg_color = "#001020",
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = "#0a1929",
					fg_color = "#467588",
				},
				inactive_tab_hover = {
					bg_color = "#132338",
					fg_color = "#2ac3de",
				},
				new_tab = {
					bg_color = "#0a1929",
					fg_color = "#2ac3de",
				},
				new_tab_hover = {
					bg_color = "#132338",
					fg_color = "#7dcfff",
				},
			},
		},
		tmux_theme = "productivity-blue",
	},
	gaming = {
		colors = {
			tab_bar = {
				background = "#1a0033",
				active_tab = {
					bg_color = "#bb9af7",
					fg_color = "#1a0033",
					intensity = "Bold",
				},
				inactive_tab = {
					bg_color = "#2a0052",
					fg_color = "#6b5a87",
				},
				inactive_tab_hover = {
					bg_color = "#3a0066",
					fg_color = "#bb9af7",
				},
				new_tab = {
					bg_color = "#2a0052",
					fg_color = "#bb9af7",
				},
				new_tab_hover = {
					bg_color = "#3a0066",
					fg_color = "#e0af68",
				},
			},
		},
		tmux_theme = "gaming-purple",
	},
}

-- Function to apply workspace theme
local function apply_workspace_theme(window, workspace_name)
	local theme = workspace_themes[workspace_name] or workspace_themes.default

	-- Apply the color scheme to the window
	window:set_config_overrides({
		colors = theme.colors,
		tab_bar_at_bottom = false,
		use_fancy_tab_bar = false,
		tab_max_width = 25,
	})

	-- Notify tmux to change its theme
	wezterm.run_child_process({
		"tmux",
		"run-shell",
		string.format('~/.config/tmux/workspace-theme.sh "%s" "%s"', workspace_name, theme.tmux_theme),
	})
end

-- Hook for workspace changes
wezterm.on("update-status", function(window, pane)
	local workspace = window:active_workspace()
	apply_workspace_theme(window, workspace)

	-- Also update tmux environment
	wezterm.run_child_process({
		"tmux",
		"set-environment",
		"-g",
		"WEZTERM_WORKSPACE",
		workspace,
	})
end)

-- Custom tab bar formatting
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local edge_background = "#0b0022"
	local background = "#1b1032"
	local foreground = "#808080"

	if tab.is_active then
		background = "#2b2042"
		foreground = "#c0c0c0"
	elseif hover then
		background = "#3b3052"
		foreground = "#909090"
	end

	local edge_foreground = background

	local title = wezterm.truncate_right(tab.active_pane.title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = " " },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = " " },
	}
end)
