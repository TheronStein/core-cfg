return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local colorizer = require("colorizer")
    
    -- Basic colorizer for standard formats
    colorizer.setup({
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        rgb_fn = true,    -- Handles rgba(15,26,42,0.95)
        hsl_fn = true,
        css = true,
        mode = "background",
        always_update = true,
      },
    })
    
    -- Calculate relative luminance (0-1) for a color
    local function get_luminance(r, g, b)
      -- Convert to 0-1 range
      r, g, b = r / 255, g / 255, b / 255

      -- Apply gamma correction
      local function adjust(c)
        if c <= 0.03928 then
          return c / 12.92
        else
          return math.pow((c + 0.055) / 1.055, 2.4)
        end
      end

      r, g, b = adjust(r), adjust(g), adjust(b)

      -- Calculate luminance
      return 0.2126 * r + 0.7152 * g + 0.0722 * b
    end

    -- Get appropriate foreground color (black or white) based on background
    local function get_contrast_fg(bg_r, bg_g, bg_b)
      local luminance = get_luminance(bg_r, bg_g, bg_b)
      -- If luminance > 0.5, background is light, use black text
      -- If luminance <= 0.5, background is dark, use white text
      if luminance > 0.5 then
        return "#000000"
      else
        return "#FFFFFF"
      end
    end

    -- ANSI basic 16 colors (30-37, 40-47, 90-97, 100-107) to RGB
    local function ansi_basic_to_rgb(code)
      local colors = {
        -- Standard colors (30-37 foreground, 40-47 background)
        [30] = {0, 0, 0},       [40] = {0, 0, 0},      -- Black
        [31] = {205, 49, 49},   [41] = {205, 49, 49},  -- Red
        [32] = {13, 188, 121},  [42] = {13, 188, 121}, -- Green
        [33] = {229, 229, 16},  [43] = {229, 229, 16}, -- Yellow
        [34] = {36, 114, 200},  [44] = {36, 114, 200}, -- Blue
        [35] = {188, 63, 188},  [45] = {188, 63, 188}, -- Magenta
        [36] = {17, 168, 205},  [46] = {17, 168, 205}, -- Cyan
        [37] = {229, 229, 229}, [47] = {229, 229, 229},-- White
        -- Bright colors (90-97 foreground, 100-107 background)
        [90] = {102, 102, 102},   [100] = {102, 102, 102},  -- Bright Black (Gray)
        [91] = {241, 76, 76},     [101] = {241, 76, 76},    -- Bright Red
        [92] = {35, 209, 139},    [102] = {35, 209, 139},   -- Bright Green
        [93] = {245, 245, 67},    [103] = {245, 245, 67},   -- Bright Yellow
        [94] = {59, 142, 234},    [104] = {59, 142, 234},   -- Bright Blue
        [95] = {214, 112, 214},   [105] = {214, 112, 214},  -- Bright Magenta
        [96] = {41, 184, 219},    [106] = {41, 184, 219},   -- Bright Cyan
        [97] = {255, 255, 255},   [107] = {255, 255, 255},  -- Bright White
      }
      return colors[code]
    end

    -- ANSI 256-color to RGB converter
    local function ansi_to_rgb(color_num)
      -- Colors 0-15: basic ANSI colors
      local basic = {
        [0] = {0, 0, 0}, [1] = {128, 0, 0}, [2] = {0, 128, 0}, [3] = {128, 128, 0},
        [4] = {0, 0, 128}, [5] = {128, 0, 128}, [6] = {0, 128, 128}, [7] = {192, 192, 192},
        [8] = {128, 128, 128}, [9] = {255, 0, 0}, [10] = {0, 255, 0}, [11] = {255, 255, 0},
        [12] = {0, 0, 255}, [13] = {255, 0, 255}, [14] = {0, 255, 255}, [15] = {255, 255, 255},
      }
      if color_num >= 0 and color_num <= 15 then
        return basic[color_num]
      -- Colors 16-231: 6x6x6 color cube
      elseif color_num >= 16 and color_num <= 231 then
        local idx = color_num - 16
        local r = math.floor(idx / 36) * 51
        local g = (math.floor(idx / 6) % 6) * 51
        local b = (idx % 6) * 51
        return {r, g, b}
      -- Colors 232-255: grayscale
      elseif color_num >= 232 and color_num <= 255 then
        local gray = 8 + (color_num - 232) * 10
        return {gray, gray, gray}
      end
      return nil
    end

    -- Custom handler for non-standard formats
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile", "TextChanged", "InsertLeave"}, {
      pattern = {"*.conf", "*.cfg", "*.zsh", "*.sh", "*.bash", "*.zshrc", "*.bashrc", "hypr*.conf", "*colors*", "*p10k*", "*help*"},
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ns_id = vim.api.nvim_create_namespace('custom_colors')
        vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        
        for line_num, line in ipairs(lines) do
          -- Handle zsh ANSI 256 colors: %NNNF, %NNNB, %F{NNN}, %K{NNN}
          local pos = 1
          while pos <= #line do
            local start, finish, num = line:find("%%(%d%d?%d?)[FB]", pos)
            if not start then
              start, finish, num = line:find("%%[FK]{(%d%d?%d?)}", pos)
            end
            if not start then break end

            local color_num = tonumber(num)
            if color_num and color_num >= 0 and color_num <= 255 then
              local rgb = ansi_to_rgb(color_num)
              if rgb then
                local color = string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
                local fg_color = get_contrast_fg(rgb[1], rgb[2], rgb[3])
                local hl_group = "AnsiColor_" .. num
                vim.api.nvim_set_hl(0, hl_group, { bg = color, fg = fg_color })
                vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line_num - 1, start - 1, finish)
              end
            end
            pos = finish + 1
          end

          -- Handle bare ANSI color numbers in FOREGROUND/BACKGROUND assignments
          pos = 1
          while pos <= #line do
            local start, finish, num = line:find("FOREGROUND=(%d%d?%d?)%s*$", pos)
            if not start then
              start, finish, num = line:find("BACKGROUND=(%d%d?%d?)%s*$", pos)
            end
            if not start then break end

            local color_num = tonumber(num)
            if color_num and color_num >= 0 and color_num <= 255 then
              local rgb = ansi_to_rgb(color_num)
              if rgb then
                local color = string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
                local fg_color = get_contrast_fg(rgb[1], rgb[2], rgb[3])
                local hl_group = "AnsiColor_" .. num
                -- Highlight just the number part
                local num_start = line:find(num, start, true)
                vim.api.nvim_set_hl(0, hl_group, { bg = color, fg = fg_color })
                vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line_num - 1, num_start - 1, num_start - 1 + #num)
              end
            end
            pos = finish + 1
          end

          -- Handle ANSI escape sequences: \e[1;32m, $'\e[1;32m', \033[1;32m
          pos = 1
          while pos <= #line do
            -- Match patterns: \e[...m, \033[...m, $'\e[...m'
            local start, finish, codes = line:find("\\e%[([0-9;]+)m", pos)
            if not start then
              start, finish, codes = line:find("\\033%[([0-9;]+)m", pos)
            end
            if not start then
              start, finish, codes = line:find("%$'\\e%[([0-9;]+)m'", pos)
            end
            if not start then break end

            -- Parse the codes (e.g., "1;32" -> bold green)
            local color_code = nil
            for code_str in codes:gmatch("%d+") do
              local code = tonumber(code_str)
              -- Look for color codes (30-37, 40-47, 90-97, 100-107)
              if (code >= 30 and code <= 37) or (code >= 40 and code <= 47) or
                 (code >= 90 and code <= 97) or (code >= 100 and code <= 107) then
                color_code = code
                break
              end
            end

            if color_code then
              local rgb = ansi_basic_to_rgb(color_code)
              if rgb then
                local color = string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
                local fg_color = get_contrast_fg(rgb[1], rgb[2], rgb[3])
                local hl_group = "AnsiEscape_" .. color_code
                vim.api.nvim_set_hl(0, hl_group, { bg = color, fg = fg_color })
                vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line_num - 1, start - 1, finish)
              end
            end
            pos = finish + 1
          end

          -- Helper to convert hex to RGB and get contrast color
          local function hex_to_contrast(hex_code)
            local r = tonumber(hex_code:sub(1, 2), 16)
            local g = tonumber(hex_code:sub(3, 4), 16)
            local b = tonumber(hex_code:sub(5, 6), 16)
            return get_contrast_fg(r, g, b)
          end

          -- Handle rgba(hexhex) and rgba(hexhexhex) for gradients
          pos = 1
          while pos <= #line do
            local start, finish, hex = line:find("rgba%(([0-9a-fA-F]+)%)", pos)
            if not start then break end

            if hex and type(hex) == "string" and #hex >= 6 then
              local hex_color = hex:sub(1, 6)
              local color = "#" .. hex_color
              local fg_color = hex_to_contrast(hex_color)
              local hl_group = "CustomColor_" .. hex_color
              vim.api.nvim_set_hl(0, hl_group, { bg = color, fg = fg_color })
              vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line_num - 1, start - 1, finish)
            end
            pos = finish + 1
          end

          -- Handle rgb(hex) format
          pos = 1
          while pos <= #line do
            local start, finish, hex = line:find("rgb%(([0-9a-fA-F]+)%)", pos)
            if not start then break end

            if hex and type(hex) == "string" and #hex == 6 and not hex:match("[g-zG-Z]") then
              local color = "#" .. hex
              local fg_color = hex_to_contrast(hex)
              local hl_group = "CustomColor_" .. hex
              vim.api.nvim_set_hl(0, hl_group, { bg = color, fg = fg_color })
              vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line_num - 1, start - 1, finish)
            end
            pos = finish + 1
          end

          -- Handle rgba(hex, decimal) like rgba(1a1a1a, 0.8)
          pos = 1
          while pos <= #line do
            local start, finish = line:find("rgba%([0-9a-fA-F]+,%s*[%d%.]+%)", pos)
            if not start then break end

            local hex = line:sub(start, finish):match("rgba%(([0-9a-fA-F]+),")
            if hex and type(hex) == "string" and #hex == 6 and not hex:match("[g-zG-Z]") then
              local color = "#" .. hex
              local fg_color = hex_to_contrast(hex)
              local hl_group = "CustomColor_" .. hex
              vim.api.nvim_set_hl(0, hl_group, { bg = color, fg = fg_color })
              vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line_num - 1, start - 1, finish)
            end
            pos = finish + 1
          end

          -- Handle bare hex (without #) like 81AEF0
          for hex in line:gmatch("([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])") do
            if type(hex) == "string" and not hex:match("[g-zG-Z]") then
              -- Make sure it's not inside rgba() or rgb()
              if not line:match("rgba?%(" .. hex) then
                local start, finish = line:find(hex, 1, true)
                if start then
                  -- Check word boundaries
                  local before_ok = start == 1 or line:sub(start-1, start-1):match("[^%w]")
                  local after_ok = finish == #line or line:sub(finish+1, finish+1):match("[^%w]")

                  if before_ok and after_ok then
                    local color = "#" .. hex
                    local fg_color = hex_to_contrast(hex)
                    local hl_group = "CustomColor_" .. hex
                    vim.api.nvim_set_hl(0, hl_group, { bg = color, fg = fg_color })
                    vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line_num - 1, start - 1, finish)
                  end
                end
              end
            end
          end
        end
      end,
    })
  end,
}
