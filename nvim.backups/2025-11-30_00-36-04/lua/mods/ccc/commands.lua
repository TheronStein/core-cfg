local M = {}

M.setup = function()
  local create_cmd = vim.api.nvim_create_user_command
  local wk = require("which-key")

  -- Command to pick a color and insert at cursor
  create_cmd("ColorPick", function(opts)
    local format = opts.args ~= "" and opts.args or "hex"
    vim.cmd("CccPick " .. format)
  end, {
    nargs = "?",
    complete = function()
      return { "hex", "rgb", "hsl", "css_rgb", "css_hsl" }
    end,
    desc = "Pick a color in specified format",
  })

  -- Command to convert all colors in buffer
  create_cmd("ColorConvertAll", function(opts)
    local format = opts.args
    if format == "" then
      vim.notify("Please specify a format (hex, rgb, hsl, etc.)", vim.log.levels.ERROR)
      return
    end

    -- Save cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)

    vim.notify("Converting all colors to " .. format .. "...", vim.log.levels.INFO)

    -- Implementation for hex colors
    if format == "hex" then
      -- Convert RGB to hex
      vim.cmd(
        [[%s/rgb(\(\d\+\),\s*\(\d\+\),\s*\(\d\+\))/\=printf("#%02X%02X%02X", submatch(1), submatch(2), submatch(3))/ge]]
      )
    elseif format == "css_rgb" then
      -- Convert hex to RGB
      vim.cmd(
        [[%s/#\(\x\x\)\(\x\x\)\(\x\x\)/\='rgb(' . str2nr(submatch(1), 16) . ', ' . str2nr(submatch(2), 16) . ', ' . str2nr(submatch(3), 16) . ')'/ge]]
      )
    end

    -- Restore cursor position
    vim.api.nvim_win_set_cursor(0, cursor)
    vim.notify("Color conversion complete!", vim.log.levels.INFO)
  end, {
    nargs = 1,
    complete = function()
      return { "hex", "rgb", "hsl", "css_rgb", "css_hsl" }
    end,
    desc = "Convert all colors in buffer to specified format",
  })

  -- Command to highlight specific color patterns
  create_cmd("ColorHighlight", function(opts)
    local pattern = opts.args
    if pattern == "" then
      vim.cmd("CccHighlighterToggle")
    else
      -- Custom highlighting for specific pattern
      vim.cmd("CccHighlighterEnable")
      vim.fn.matchadd("CccHighlight", pattern)
    end
  end, {
    nargs = "?",
    desc = "Highlight colors matching pattern",
  })

  -- Command to show color palette
  create_cmd("ColorPalette", function()
    -- Create a floating window with color palette
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 60
    local height = 25

    local opts = {
      relative = "editor",
      width = width,
      height = height,
      row = (vim.o.lines - height) / 2,
      col = (vim.o.columns - width) / 2,
      style = "minimal",
      border = "rounded",
      title = " 󰏘 Color Palette ",
      title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Add palette colors to buffer with descriptions
    -- TODO: Implement custom palettes as their own modules/files, using fzf-lua as a selector to choose palettes to save to, modify, delete, create, or open
    local lines = {
      "╭─────────────────────────────────────────────────────────╮",
      "│  CUSTOM PALETTE                                         │",
      "├─────────────────────────────────────────────────────────┤",
      "│  #FF0000  █  Red          │  #00FFFF  █  Cyan          │",
      "│  #00FF00  █  Green        │  #FFFFFF  █  White         │",
      "│  #0000FF  █  Blue         │  #000000  █  Black         │",
      "│  #FFFF00  █  Yellow       │  #808080  █  Gray          │",
      "│  #FF00FF  █  Magenta      │  #FFA500  █  Orange        │",
      "│  #800080  █  Purple       │  #FFC0CB  █  Pink          │",
      "├─────────────────────────────────────────────────────────┤",
      "│  TAILWIND CSS                                           │",
      "├─────────────────────────────────────────────────────────┤",
      "│  #F87171  █  red-400      │  #60A5FA  █  blue-400      │",
      "│  #FBBF24  █  yellow-400   │  #A78BFA  █  purple-400    │",
      "│  #34D399  █  green-400    │  #F472B6  █  pink-400      │",
      "├─────────────────────────────────────────────────────────┤",
      "│  MATERIAL DESIGN                                        │",
      "├─────────────────────────────────────────────────────────┤",
      "│  #F44336  █  Red          │  #00BCD4  █  Cyan          │",
      "│  #4CAF50  █  Green        │  #9C27B0  █  Purple        │",
      "│  #2196F3  █  Blue         │  #FF9800  █  Orange        │",
      "╰─────────────────────────────────────────────────────────╯",
      "",
      "  [Enter] Insert  [y] Yank  [q] Close  [Tab] Next",
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", "ccc-palette")

    -- Set up keymaps for the palette window
    local function close_palette()
      vim.api.nvim_win_close(win, true)
    end

    local function get_color_from_line()
      local line = vim.api.nvim_get_current_line()
      return line:match("#%x%x%x%x%x%x")
    end

    vim.keymap.set("n", "q", close_palette, { buffer = buf })
    vim.keymap.set("n", "<Esc>", close_palette, { buffer = buf })

    vim.keymap.set("n", "<CR>", function()
      local color = get_color_from_line()
      if color then
        close_palette()
        vim.api.nvim_put({ color }, "c", true, true)
      end
    end, { buffer = buf })

    vim.keymap.set("n", "y", function()
      local color = get_color_from_line()
      if color then
        vim.fn.setreg('"', color)
        vim.notify("Yanked: " .. color, vim.log.levels.INFO)
      end
    end, { buffer = buf })

    -- Enable color highlighting in palette
    vim.defer_fn(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.cmd("CccHighlighterEnable")
      end
    end, 50)
  end, {
    desc = "Show color palette picker",
  })

  -- Command to generate color scheme from current colors
  create_cmd("ColorSchemeGenerate", function()
    local colors = {}
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    for _, line in ipairs(lines) do
      for color in line:gmatch("#%x%x%x%x%x%x") do
        colors[color] = true
      end
    end

    local color_list = vim.tbl_keys(colors)
    if #color_list > 0 then
      vim.notify(string.format("Found %d unique colors. Generating scheme...", #color_list), vim.log.levels.INFO)
    -- Further implementation would go here
    else
      vim.notify("No colors found in buffer", vim.log.levels.WARN)
    end
  end, {
    desc = "Generate color scheme from buffer colors",
  })

  -- Command for batch color operations
  create_cmd("ColorBatch", function(opts)
    local operation = opts.args

    local operations = {
      darken = "Darkening all colors by 10%",
      lighten = "Lightening all colors by 10%",
      saturate = "Increasing saturation by 10%",
      desaturate = "Decreasing saturation by 10%",
    }

    if operations[operation] then
      vim.notify(operations[operation], vim.log.levels.INFO)
    -- Implementation would go here
    else
      vim.notify("Unknown operation. Use: darken, lighten, saturate, desaturate", vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function()
      return { "darken", "lighten", "saturate", "desaturate" }
    end,
    desc = "Batch color operations",
  })

  -- Register commands in which-key
  wk.register({
    ["<localleader>c:"] = {
      name = "󰘳 Commands",
      p = { "<cmd>ColorPick<cr>", "ColorPick command" },
      a = { "<cmd>ColorConvertAll ", "ColorConvertAll command" },
      h = { "<cmd>ColorHighlight<cr>", "ColorHighlight command" },
      P = { "<cmd>ColorPalette<cr>", "ColorPalette command" },
      s = { "<cmd>ColorSchemeGenerate<cr>", "ColorSchemeGenerate command" },
      b = { "<cmd>ColorBatch ", "ColorBatch command" },
    },
  })
end

return M
