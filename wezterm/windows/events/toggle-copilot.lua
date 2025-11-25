local wezterm = require("wezterm")
local copilot = require("modules.ai.CopilotChat")

local M = {}

wezterm.on("toggle-copilot", function(window, pane)
	copilot:toggle(window, pane)
end)

return M
