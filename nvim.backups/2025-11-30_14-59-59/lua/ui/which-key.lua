return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,

  opts = {
    notify = false, -- Disable all notifications
    triggers = {
      { "<leader>", mode = { "n", "v" } },
      { "<localleader>", mode = { "n", "v" } },
      { "g", mode = { "n", "v" } },
      { "z", mode = { "n", "v" } },
    },
    spec = {
      { "F1", "<Cmd>which-key<cr>", "Which Key Help" },
    },
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = false,
        motions = true,
        text_objects = true,
        windows = false,
        nav = true,
        z = true,
        g = true,
      },
    },
    win = {
      border = "rounded",
      padding = { 2, 2, 2, 2 },
      wo = {
        winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "➜", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
      ellipsis = "…", -- symbol used to indicate there is more content in a list that is not shown
      mappings = true,
      rules = {},
      colors = true,
      keys = {
        Up = " ",
        Down = " ",
        Left = " ",
        Right = " ",
        C = "󰘴 ",
        M = "󰘵 ",
        D = "󰘳 ",
        S = "󰘶 ",
        CR = "󰌑 ",
        Esc = "󱊷 ",
        ScrollWheelDown = "󱕐 ",
        ScrollWheelUp = "󱕑 ",
        NL = "󰌑 ",
        BS = "󰁮",
        Space = "󱁐 ",
        Tab = "󰌒 ",
        F1 = "󱊫",
        F2 = "󱊬",
        F3 = "󱊭",
        F4 = "󱊮",
        F5 = "󱊯",
        F6 = "󱊰",
        F7 = "󱊱",
        F8 = "󱊲",
        F9 = "󱊳",
        F10 = "󱊴",
        F11 = "󱊵",
        F12 = "󱊶",
      },
    },
    show_help = true, -- show a help message in the command line for using which-key
    show_keys = true, -- show the currently pressed key and its label as a message in the command line
    -- disable which-key for certain buf types and file types.
    disable = {
      ft = {},
      bt = {},
    },
    debug = false, -- enable wk.log in the current directory
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- State management for which-key reliability
    local group = vim.api.nvim_create_augroup("which-keyStateManagement", { clear = true })

    -- Ensure which-key works in all buffers
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
      group = group,
      callback = function(ev)
        -- Re-verify leader keys are set
        if not vim.g.mapleader or not vim.g.maplocalleader then
          vim.notify("which-key: Leader keys not set! Restoring...", vim.log.levels.WARN)
          vim.g.mapleader = "\\"
          vim.g.maplocalleader = " "
        end

        -- Ensure timeout is still configured
        if vim.o.timeout ~= true or vim.o.timeoutlen ~= 300 then
          vim.o.timeout = true
          vim.o.timeoutlen = 300
        end
      end,
      desc = "Ensure which-key state on buffer enter",
    })

    -- Reset which-key if it gets stuck
    vim.api.nvim_create_user_command("WhichKeyReset", function()
      -- Close any open which-key windows
      pcall(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          if ft == "which-key" then
            vim.api.nvim_win_close(win, true)
          end
        end
      end)

      -- Re-verify settings
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      vim.g.mapleader = "\\"
      vim.g.maplocalleader = " "

      vim.notify("which-key reset complete", vim.log.levels.INFO)
    end, { desc = "Reset which-key state and close stuck windows" })

    -- Debug command to check which-key state
    vim.api.nvim_create_user_command("WhichKeyDebug", function()
      local info = {
        "which-key Debug Info:",
        "",
        "Leader: " .. (vim.g.mapleader and vim.inspect(vim.g.mapleader) or "NOT SET"),
        "LocalLeader: " .. (vim.g.maplocalleader and vim.inspect(vim.g.maplocalleader) or "NOT SET"),
        "Timeout: " .. tostring(vim.o.timeout),
        "Timeoutlen: " .. tostring(vim.o.timeoutlen),
        "",
        "Open which-key windows:",
      }

      local found_wk_win = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == "which-key" then
          table.insert(info, "  Window " .. win .. " (buf " .. buf .. ")")
          found_wk_win = true
        end
      end

      if not found_wk_win then
        table.insert(info, "  None")
      end

      table.insert(info, "")
      table.insert(info, "Quick fix: :which-keyReset")

      vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
    end, { desc = "Show which-key debug information" })

    -- Add keybinding to reset which-key
    vim.keymap.set("n", "<localleader>Wr", "<cmd>which-keyReset<cr>", { desc = "Reset which-key" })
    vim.keymap.set("n", "<localleader>Wd", "<cmd>which-keyDebug<cr>", { desc = "Debug which-key" })
  end,
}
