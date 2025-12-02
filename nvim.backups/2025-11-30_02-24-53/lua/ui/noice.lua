return {
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "fade",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.90)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.90)
      end,
      top_down = true,
    },
    init = function()
      vim.notify = require("notify")
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      views = {
        notify = {
          backend = "notify",
          fallback = "mini",
          format = "notify",
          replace = false,
          merge = false,
        },
        popup = {
          backend = "popup",
          enter = true,
          border = {
            style = "rounded",
          },
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = "90%",
            height = "90%",
          },
          win_options = {
            wrap = true,
            linebreak = true,
          },
          close = {
            keys = { "q", "<Esc>" },
          },
        },
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 3,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
        split = {
          backend = "split",
          enter = true,
          relative = "editor",
          position = "bottom",
          size = "40%",
          close = {
            keys = { "q" },
          },
          win_options = {
            wrap = true,
            linebreak = true,
          },
        },
      },
      lsp = {
        -- Override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = { enabled = true },
        signature = { enabled = true },
        -- Let Trouble handle diagnostics, Noice handles messages
        progress = {
          enabled = true,
          format = "lsp_progress",
          format_done = "lsp_progress_done",
          view = "mini",
        },
      },
      -- You can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- Use a classic bottom cmdline for search
        command_palette = true, -- Position the cmdline and popupmenu together
        long_message_to_split = false, -- Long messages will be sent to a split
        inc_rename = false, -- Enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- Add a border to hover docs and signature help
      },
      cmdline = {
        view = "cmdline_popup", -- "cmdline" for classic bottom, "cmdline_popup" for centered popup
        opts = {
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = 80,
            height = "auto",
          },
          border = {
            style = "rounded",
          },
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = 8,
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
      -- popupmenu = {
      -- 	enabled = true,
      -- 	backend = "nui", -- "nui" or "cmp"
      -- 	view = "popupmenu", -- Can also be "split"
      -- },
      routes = {
        -- Skip "written" messages
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        -- Route notifications to nvim-notify floating windows
        {
          filter = {
            event = "notify",
          },
          view = "notify",
        },
        -- Route LSP messages to notify
        {
          filter = {
            event = "lsp",
            kind = "message",
          },
          view = "notify",
        },
      },
      commands = {
        -- :Noice last
        last = {
          view = "popup",
          opts = { enter = true, format = "details" },
          filter = {
            all = {
              -- options for the message history that you get with `:Noice`
              view = "popup",
              opts = { enter = true, format = "details" },
              filter = {},
            },
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              { event = "msg_show", kind = { "" } },
              { event = "lsp", kind = "message" },
            },
          },
          filter_opts = { count = 1 },
        },
        -- :Noice errors
        errors = {
          -- options for the message history that you get with `:Noice`
          view = "popup",
          opts = { enter = true, format = "details" },
          filter = { error = true },
          filter_opts = { reverse = true },
        },
        -- all = {
        -- 	-- :Noice all
        -- 	-- options for the message history that you get with `:Noice`
        -- 	view = "popup",
        -- 	opts = { enter = true, format = "details" },
        -- 	filter = {},
        -- 	filter_opts = {},
        -- },
        -- :Noice history
        history = {
          view = "popup",
          opts = { enter = true, format = "details" },
          filter = {
            any = {
              { event = "notify" },
              { error = true },
              { warning = true },
              { event = "msg_show", kind = { "" } },
              { event = "lsp", kind = "message" },
            },
          },
        },
      },
    },
    keys = {
      { "<leader>n", "", desc = "+noice" },
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect Cmdline",
      },
      -- Disabled: using Snacks notifier instead
      -- {
      -- 	"<leader>nl",
      -- 	function()
      -- 		require("noice").cmd("last")
      -- 	end,
      -- 	desc = "Noice Last Message",
      -- },
      -- {
      -- 	"<leader>nh",
      -- 	function()
      -- 		require("noice").cmd("history")
      -- 	end,
      -- 	desc = "Noice History",
      -- },
      -- {
      -- 	"<leader>na",
      -- 	function()
      -- 		require("noice").cmd("all")
      -- 	end,
      -- 	desc = "Noice All",
      -- },
      {
        "<leader>nd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss All",
      },
      {
        "<c-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll forward",
        mode = { "i", "n", "s" },
      },
      {
        "<c-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll backward",
        mode = { "i", "n", "s" },
      },
    },
  },
}
