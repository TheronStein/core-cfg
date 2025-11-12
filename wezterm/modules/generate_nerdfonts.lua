local wezterm = require 'wezterm'
local M = {}

function M.generate()
  local json = wezterm.json
  local icons = {}
  local base_path = wezterm.config_dir .. '/modules/'
  local input_files = {'wezterm_nerdfonts.json', 'wezterm_nerdfont_names.txt'}

  for _, input_file in ipairs(input_files) do
    local file = io.open(base_path .. input_file, 'r')
    if file then
      local content = file:read('*all')
      file:close()

      if input_file:match('%.json$') then
        local success, scraped = pcall(json.parse, content)
        if success then
          for _, item in ipairs(scraped) do
            local name = item.name
            local camel_name = name:gsub('^([a-z])', function(c) return c:upper() end):gsub('_([a-z])', function(c) return c:upper() end)
            local glyph = wezterm.nerdfonts[camel_name]
            if glyph and glyph ~= '' then
              table.insert(icons, {
                name = name,
                glyph = glyph,
                codepoint = string.format('%04x', glyph:byte(1, #glyph))
              })
            end
          end
          break -- Exit loop if JSON is processed
        end
      else
        for line in content:gmatch('[^\r\n]+') do
          local name = line:gsub('^%s*(.-)%s*$', '%1')
          if name ~= '' then
            local camel_name = name:gsub('^([a-z])', function(c) return c:upper() end):gsub('_([a-z])', function(c) return c:upper() end)
            local glyph = wezterm.nerdfonts[camel_name]
            if glyph and glyph ~= '' then
              table.insert(icons, {
                name = name,
                glyph = glyph,
                codepoint = string.format('%04x', glyph:byte(1, #glyph))
              })
            end
          end
        end
        break -- Exit loop if text file is processed
      end
    end
  end

  if #icons == 0 then
    wezterm.log_error('No valid input files found at ' .. base_path .. '{wezterm_nerdfonts.json, wezterm_nerdfont_names.txt}')
    return nil
  end

  return json.encode(icons)
end

return M
