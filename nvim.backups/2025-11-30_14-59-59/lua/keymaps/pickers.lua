-- Quick edit config picker with split
vim.keymap.set("n", "<localleader>ec", function()
  local snacks = require("snacks")
  local config_path = vim.fn.stdpath("config") .. "/lua"

  -- Custom picker that opens in a right split
  snacks.picker.files({
    cwd = config_path,
    prompt = "Config Files",
    -- Filter to only show active config files (lua files)
    find_command = { "fd", "--type", "f", "--extension", "lua" },
    preview = true,
    -- Custom action to open in right split
    confirm = function(item)
      vim.cmd("vsplit")
      vim.cmd("wincmd l")
      vim.cmd("edit " .. item.file)
    end,
  })
end, { desc = "Quick Edit Config (split)" })

-- System configuration picker
vim.keymap.set("n", "<localleader>ec", function()
  local snacks = require("snacks")

  local cfg = os.getenv("CORE_CFG")
  local env = os.getenv("CORE_ENV")

  -- Define configuration locations
  local configs = {
    { name = "nvim", path = cfg .. "/nvim" },
    { name = "tmux", path = cfg .. "/tmux" },
    { name = "wezterm", path = cfg .. "/wezterm" },
    { name = "zsh", path = cfg .. "/zsh" },
    { name = "yazi", path = cfg .. "/yazi" },
    { name = "rofi", path = env .. "/desktop/rofi" },
    { name = "hyprland", path = env .. "/desktop/hypr" },
    { name = "waybar", path = env .. "/desktop/waybar" },
    { name = "dunst", path = env .. "/desktop/dunst" },
  }

  -- Build items list with proper format
  local items = {}
  local config_map = {} -- Store config data separately

  for _, config in ipairs(configs) do
    local expanded_path = vim.fn.expand(config.path)
    if vim.fn.isdirectory(expanded_path) == 1 then
      local display_text = config.name .. " → " .. expanded_path
      table.insert(items, display_text)
      config_map[display_text] = {
        name = config.name,
        path = expanded_path,
      }
    end
  end

  -- First picker: select configuration
  local Picker = require("snacks.picker")

  vim.ui.select(items, {
    prompt = "Select Configuration to Edit:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if not choice then
      return
    end

    local selected_config = config_map[choice]
    if not selected_config then
      vim.notify("Invalid selection", vim.log.levels.ERROR)
      return
    end

    -- Open file picker with selected config
    vim.schedule(function()
      local picker = Picker.files({
        cwd = selected_config.path,
        prompt = selected_config.name(" Files"),
        -- Exclude .archv, .ref, .bak directories
        find_command = {
          "fd",
          "--type",
          "f",
          "--exclude",
          ".archv",
          "--exclude",
          ".ref",
          "--exclude",
          ".bak",
        },
        preview = true,
      })

      -- Override the default action
      if picker and picker.opts then
        picker.opts.confirm = function(selected)
          -- Debug: print what we receive
          vim.notify("Selected item type: " .. type(selected), vim.log.levels.INFO)

          -- Try different ways to get the file path
          local file_path = nil
          if type(selected) == "table" then
            file_path = selected.file or selected.path or selected.filename or selected.text
            if not file_path and selected.item then
              file_path = selected.item.file or selected.item.path or selected.item
            end
          elseif type(selected) == "string" then
            file_path = selected
          end

          if file_path and type(file_path) == "string" then
            -- Make absolute path if needed
            if not vim.startswith(file_path, "/") then
              file_path = selected_config.path .. "/" .. file_path
            end
            vim.cmd("vsplit")
            vim.cmd("wincmd l")
            vim.cmd("edit " .. vim.fn.fnameescape(file_path))
          else
            vim.notify("Could not determine file path. Got: " .. vim.inspect(selected), vim.log.levels.ERROR)
          end
        end
      end
    end)
  end)
end, { desc = "System Config Browser" })
