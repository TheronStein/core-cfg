#!/usr/bin/env -S wezterm start --config-file
-- Quick script to get a nerdfonts icon and print it

local wezterm = require('wezterm')
local args = {...}
local icon_name = args[1]

if not icon_name then
  print("Usage: get-icon.lua <icon_name>")
  os.exit(1)
end

local nf = wezterm.nerdfonts
local success, icon = pcall(function() return nf[icon_name] end)

if success and icon then
  io.write(icon)
else
  io.write("?")
end

-- Return empty config to prevent WezTerm from actually starting
return {}
