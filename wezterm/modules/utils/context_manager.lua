local wezterm = require("wezterm")

local M = {}

-- Initialize GLOBAL context state
wezterm.GLOBAL.leader_context = wezterm.GLOBAL.leader_context or "wezterm"

-- Get current context
function M.get_context()
	return wezterm.GLOBAL.leader_context or "wezterm"
end

-- Set context
function M.set_context(context)
	if context == "wezterm" or context == "tmux" then
		wezterm.GLOBAL.leader_context = context
		return true
	end
	return false
end

-- Toggle between wezterm and tmux contexts
function M.toggle_context(window, pane)
	local current = M.get_context()
	local new_context = current == "wezterm" and "tmux" or "wezterm"
	M.set_context(new_context)

	-- Update status display
	wezterm.emit("update-status", window, pane)

	-- Update tmux status bar by setting global environment variable
	-- Tmux will read this and update its status bar colors
	local user_vars = pane:get_user_vars()
	if user_vars.TMUX and user_vars.TMUX ~= "" then
		-- Set tmux global environment variable that can be read by status scripts
		-- The value is base64 encoded to match what the tmux scripts expect
		local context_encoded = wezterm.base64_encode(new_context)
		-- Use run_child_process to set tmux environment variable and refresh status bar
		wezterm.background_child_process({
			"sh",
			"-c",
			string.format(
				"tmux set-environment -g WEZTERM_CONTEXT %s && tmux refresh-client -S",
				wezterm.shell_quote_arg(context_encoded)
			),
		})
	end

	-- Show notification
	window:toast_notification(
		"WezTerm Context",
		"Switched to " .. new_context:upper() .. " mode",
		nil,
		1000
	)
end

-- Create a context-aware action
-- If in tmux context, sends tmux keystrokes
-- If in wezterm context, executes wezterm action
function M.context_action(tmux_key, wezterm_action, tmux_prefix)
	tmux_prefix = tmux_prefix or { key = "Space", mods = "CTRL" }

	return wezterm.action_callback(function(window, pane)
		local context = M.get_context()

		if context == "tmux" then
			-- Check if we're actually in a tmux session
			local user_vars = pane:get_user_vars()
			local tmux_env = user_vars.TMUX or user_vars.tmux_server

			-- If not in user_vars, try to get from foreground process info
			if not tmux_env or tmux_env == "" then
				local proc_info = pane:get_foreground_process_info()
				if proc_info and proc_info.environ then
					tmux_env = proc_info.environ.TMUX
				end
			end

			if tmux_env and tmux_env ~= "" then
				-- Send tmux prefix + key
				if type(tmux_key) == "table" then
					-- Multiple keys
					local actions = { wezterm.action.SendKey(tmux_prefix) }
					for _, key in ipairs(tmux_key) do
						table.insert(actions, wezterm.action.SendKey(key))
					end
					window:perform_action(wezterm.action.Multiple(actions), pane)
				else
					-- Single key
					window:perform_action(
						wezterm.action.Multiple({
							wezterm.action.SendKey(tmux_prefix),
							wezterm.action.SendKey({ key = tmux_key }),
						}),
						pane
					)
				end
			else
				-- Not in tmux, show warning
				window:toast_notification(
					"Context Warning",
					"In tmux mode but not in a tmux session!",
					nil,
					2000
				)
			end
		else
			-- WezTerm context - execute wezterm action
			window:perform_action(wezterm_action, pane)
		end
	end)
end

-- Helper for creating tmux-style key sequences
function M.tmux_key(key, mods)
	if mods then
		return { key = key, mods = mods }
	else
		return key
	end
end

return M
