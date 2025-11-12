local wezterm = require("wezterm")
-- utils/platform.lua
local platform = {}

if wezterm.target_triple:find("windows") then
	platform.os = "windows"
elseif wezterm.target_triple:find("darwin") then
	platform.os = "mac"
else
	platform.os = "linux"
end

return platform
