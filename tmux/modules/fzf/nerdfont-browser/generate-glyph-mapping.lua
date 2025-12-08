-- Generate icon_name -> glyph mapping file
-- Run with: wezterm --config-file generate-glyph-mapping.lua start -- bash -c 'exit'

local wezterm = require('wezterm')
local nf = wezterm.nerdfonts

-- Read icon names
local data_file = wezterm.home_dir .. "/.core/cfg/wezterm/.data/wezterm_nerdfont_names.txt"
local output_file = wezterm.home_dir .. "/.core/cfg/wezterm/scripts/nerdfont-browser/data/icon-name-to-glyph.txt"

local file = io.open(data_file, "r")
if not file then
  wezterm.log_error("Could not open " .. data_file)
  return {}
end

local names = {}
for line in file:lines() do
  if line and line ~= "" then
    table.insert(names, line)
  end
end
file:close()

wezterm.log_info("Loaded " .. #names .. " icon names")

-- Create mapping file
local out = io.open(output_file, "w")
if not out then
  wezterm.log_error("Could not create " .. output_file)
  return {}
end

local count = 0
for _, name in ipairs(names) do
  local success, icon = pcall(function() return nf[name] end)
  if success and icon then
    -- Write: name<TAB>glyph
    out:write(name .. "\t" .. icon .. "\n")
    count = count + 1
  end
end

out:close()
wezterm.log_info("Wrote " .. count .. " icon mappings to " .. output_file)
print("✓ Generated " .. count .. " icon mappings")

return {}
