-- TODO:
-- * Add more descriptions and refine existing ones for clarity.
-- * Implement fzf-lua integration for palette management.
-- * Implement fzf-lua menu for selecting ccc plugin commands to condense all of the keymaps for the plugin

local M = {}

M.setup = function()
  local wk = require("which-key")

  -- Main color mappings under localleader
  wk.add({
    ["<localleader>c"] = {
      name = "󰏘 Colors",

      -- Primary actions
      p = { "<cmd>CccPick<cr>", "󰴱 Pick color" },
      c = { "<cmd>CccConvert<cr>", "󰁨 Convert color under cursor" },
      P = { "<cmd>ColorPalette<cr>", "󰴱 Show color palette" },

      -- Highlighter controls
      h = {
        name = "󰌁 Highlighter",
        t = { "<cmd>CccHighlighterToggle<cr>", "󰐥 Toggle CCC highlighter" },
        e = { "<cmd>CccHighlighterEnable<cr>", "󰌁 Enable CCC highlighter" },
        d = { "<cmd>CccHighlighterDisable<cr>", "󰌁 Disable CCC highlighter" },
        c = { "<cmd>ColorizerToggle<cr>", "󰐥 Toggle Colorizer" },
        C = { "<cmd>ColorizerAttachToBuffer<cr>", "󰌁 Enable Colorizer" },
        D = { "<cmd>ColorizerDetachFromBuffer<cr>", "󰌁 Disable Colorizer" },
      },

      -- Conversion formats
      t = {
        name = "󰁨 Convert to",
        x = { "<cmd>CccConvert hex<cr>", "# Hex (#RRGGBB)" },
        X = { "<cmd>CccConvert hex_short<cr>", "# Short Hex (#RGB)" },
        r = { "<cmd>CccConvert rgb<cr>", "󰏘 RGB (r, g, b)" },
        R = { "<cmd>CccConvert css_rgb<cr>", "󰏘 CSS RGB rgb()" },
        h = { "<cmd>CccConvert hsl<cr>", "󰏘 HSL (h, s, l)" },
        H = { "<cmd>CccConvert css_hsl<cr>", "󰏘 CSS HSL hsl()" },
        l = { "<cmd>CccConvert css_lab<cr>", "󰏘 CSS LAB lab()" },
        L = { "<cmd>CccConvert css_lch<cr>", "󰏘 CSS LCH lch()" },
        o = { "<cmd>CccConvert css_oklab<cr>", "󰏘 CSS OKLAB oklab()" },
        O = { "<cmd>CccConvert css_oklch<cr>", "󰏘 CSS OKLCH oklch()" },
      },

      -- Advanced operations
      a = {
        name = "󰜬 Advanced",
        a = { "<cmd>ColorConvertAll hex<cr>", "󰁨 Convert all to hex" },
        r = { "<cmd>ColorConvertAll css_rgb<cr>", "󰁨 Convert all to RGB" },
        h = { "<cmd>ColorConvertAll css_hsl<cr>", "󰁨 Convert all to HSL" },
        s = { "<cmd>ColorSchemeGenerate<cr>", "󰏘 Generate color scheme" },
      },

      -- Batch operations
      b = {
        name = "󱃔 Batch operations",
        d = { "<cmd>ColorBatch darken<cr>", "󰫢 Darken all colors" },
        l = { "<cmd>ColorBatch lighten<cr>", "󰫢 Lighten all colors" },
        s = { "<cmd>ColorBatch saturate<cr>", "󰫢 Saturate all colors" },
        D = { "<cmd>ColorBatch desaturate<cr>", "󰫢 Desaturate all colors" },
      },

      -- Quick adjustments
      ["+"] = { desc = "󰐕 Increase brightness" },
      ["-"] = { desc = "󰐖 Decrease brightness" },

      -- Insert mode picker
      i = { "<cmd>CccPick<cr>a", "󰴱 Pick and insert" },

      -- Save operations
      s = {
        name = "󰆓 Save",
        p = { desc = "󰆓 Save color to palette" },
        c = { desc = "󰆓 Copy color to clipboard" },
      },

      -- Visual mode operations
      v = { desc = "󰒉 Visual mode operations" },
    },
  })

  -- Visual mode mappings
  wk.add({
    ["<localleader>c"] = {
      name = "󰏘 Colors (Visual)",
      p = { "<cmd>CccPick<cr>", "󰴱 Pick color" },
      c = { "<cmd>CccConvert<cr>", "󰁨 Convert selection" },
      r = { desc = "󰁨 Replace with converted" },
    },
  }, { mode = "v" })

  -- Picker window key reference (OL;K scheme)
  M.picker_keys = {
    ["Component Navigation"] = {
      ["Tab"] = "Next component",
      ["Shift-Tab"] = "Previous component",
      ["k"] = "Next component",
      ["i"] = "Previous component",
    },
    ["Value Adjustment"] = {
      ["j"] = "Decrease by 1 (left)",
      ["l"] = "Increase by 1 (right)",
      ["J"] = "Decrease by 5",
      ["L"] = "Increase by 5",
      ["Ctrl-j"] = "Decrease by 10",
      ["Ctrl-l"] = "Increase by 10",
    },
    ["Quick Values"] = {
      ["0-9"] = "Set to 0%-90%",
      ["H"] = "Set to minimum (0%)",
      ["M"] = "Set to middle (50%)",
      ["P"] = "Set to maximum (100%)",
    },
    ["Modes"] = {
      ["[/]"] = "Cycle input mode (forward/reverse)",
      ["{/}"] = "Cycle output mode (forward/reverse)",
      ["t"] = "Toggle alpha channel",
    },
    ["Palette"] = {
      ["p"] = "Go to palette",
      ["P"] = "Toggle previous colors",
      ["n"] = "Next color",
      ["N"] = "Previous color",
      ["e"] = "Last color",
      ["u"] = "Previous swatch",
      ["o"] = "Next swatch",
    },
    ["Actions"] = {
      ["<CR>"] = "Confirm selection",
      ["q/Q/<Esc>"] = "Cancel and quit",
    },
  }

  -- Create a command to show picker key reference
  vim.api.nvim_create_user_command("CccKeys", function()
    local lines = { "CCC Color Picker Key Reference", "================================", "" }

    for category, keys in pairs(M.picker_keys) do
      table.insert(lines, category .. ":")
      table.insert(lines, string.rep("-", #category + 1))
      for key, desc in pairs(keys) do
        table.insert(lines, string.format("  %-12s : %s", key, desc))
      end
      table.insert(lines, "")
    end

    -- Create floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 50
    local height = #lines + 2

    local opts = {
      relative = "editor",
      width = width,
      height = height,
      row = (vim.o.lines - height) / 2,
      col = (vim.o.columns - width) / 2,
      style = "minimal",
      border = "rounded",
      title = " CCC Picker Keys ",
      title_pos = "center",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", "help")

    -- Close on q or Esc
    local close_keys = { "q", "Q", "<Esc>", "<CR>" }
    for _, key in ipairs(close_keys) do
      vim.keymap.set("n", key, function()
        vim.api.nvim_win_close(win, true)
      end, { buffer = buf, silent = true })
    end
  end, { desc = "Show CCC picker key reference" })

  -- Add the command to which-key
  wk.add({
    ["<localleader>ch"] = { "<cmd>CccKeys<cr>", "󰋖 Show picker keys" },
  })
end

return M
