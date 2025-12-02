local wezterm = require 'wezterm'
local act = wezterm.action

local transform = require 'plugins/tunicodes/src/transform'

local PromptInputLineAction = act.PromptInputLine {
	description = "Tunicodes input:",
	action = wezterm.action_callback(function (window, pane, line)
		if line then
			local text = transform.Fancify(line)
			pane:send_text(text)
		end
	end),
}

return {
	Interactive = PromptInputLineAction,
}
