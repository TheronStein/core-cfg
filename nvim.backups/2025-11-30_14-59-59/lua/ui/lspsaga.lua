return {
  "glepnir/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- Beautiful rounded borders everywhere
    ui = {
      border = "rounded",
      title = true, -- this enables custom titles
      devicon = true,
    },

    -- Hover doc (K)
    hover = {
      -- This runs every time hover opens
      title = function()
        return " Hover Doc     K=close  gd=def  gr=ref  gl=open link  <C-f>/<C-b>=scroll "
      end,
      max_width = 0.6,
      max_height = 0.8,
      open_link = "gl",
      open_browser = "!chrome",
    },

    -- Signature help (shows while typing)
    signature = {
      title = function()
        return " Signature Help     <C-k>=toggle  <CR>=accept  <Tab>/<S-Tab>=next/prev "
      end,
      hint_enable = true,
      hint_prefix = "",
    },

    -- LSP Finder (gd/gr/gi)
    finder = {
      title = function()
        local count = vim.fn.getqflist({ idx = 0, size = 0 }).size
        return (" LSP Finder (%d results)     <Enter>=goto  p=preview  v/s/t=split  q=close "):format(count)
      end,
      keys = {
        shuttle = "[]",
        toggle_or_open = "<CR>",
        vsplit = "v",
        split = "s",
        tabe = "t",
        tabnew = "r",
        quit = "q",
        close = "<C-c>",
      },
    },

    -- Outline
    outline = {
      title = function()
        return " Symbols Outline     <CR>=jump  u=expand/collapse  q=close "
      end,
      win_position = "right",
      win_width = 40,
      auto_preview = true,
      detail = true,
      close_after_jump = false,
      keys = {
        jump = "<CR>",
        expand_collapse = "u",
        quit = "q",
      },
    },

    -- Lightbulb (code actions)
    lightbulb = {
      enable = true,
      sign = false,
      virtual_text = false,
    },

    -- THIS IS THE MAGIC PART — custom title with keybinds
    -- You can define per-window titles
    preview = {
      lines_above = 0,
      lines_below = 10,
    },
    scroll_preview = {
      scroll_down = "<C-f>",
      scroll_up = "<C-b>",
    },

    -- Custom title function (works for hover, signature, diagnostic, finder)
    definition = {
      edit = "<CR>",
      vsplit = "v",
      split = "s",
      tabe = "t",
      quit = "q",
    },

    diagnostic = {
      title = function()
        local sev = vim.diagnostic.severity
        local counts = vim.diagnostic.count(0)
        local errors = counts[sev.ERROR] or 0
        local warns = counts[sev.WARN] or 0
        return (" Diagnostics (E:" .. errors .. " W:" .. warns .. ")     <Enter>=goto  q=close ")
      end,
    },

    code_action = {
      title = function()
        return " Code Actions     <Enter>=apply  q=close "
      end,
    },

    rename = {
      title = function()
        return " Rename Symbol     <Enter>=confirm  <Esc>/q=cancel "
      end,
    },
    keys = {
      { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover Doc (with key hints)" },
      { "gd", "<cmd>Lspsaga finder tyd+def<CR>", desc = "LSP Finder" },
      { "gr", "<cmd>Lspsaga finder ref<CR>", desc = "References" },
      { "gi", "<cmd>Lspsaga finder imp<CR>", desc = "Implementations" },
      { "<leader>ca", "<cmd>Lspsaga code_action<CR>", mode = { "n", "v" }, desc = "Code Action" },
      { "<leader>rn", "<cmd>Lspsaga rename<CR>", desc = "Rename" },
    },
    { "<leader>o", "<cmd>Lspsaga outline<CR>", desc = "Outline + Docs Panel" },
    { "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Prev Diagnostic" },
    { "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Next Diagnostic" },
    { "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Show Line Diag" },
  },
}
