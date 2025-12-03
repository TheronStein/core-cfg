return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    opts = {
      terminal_cmd = "~/.core/.sys/tools/pnpm/bin/claude", -- Point to local installation
      --- Terminal Configuration
      terminal = {
        split_side = "right", -- "left" or "right"
        split_width_percentage = 0.30,
        provider = "auto", -- "auto", "snacks", "native", "external", "none", or custom provider table
        auto_close = true,
        snacks_win_opts = {}, -- Opts to pass to `Snacks.terminal.open()` - see Floating Window section below

        -- Provider-specific options
        provider_opts = {
          -- Command for external terminal provider. Can be:
          -- 1. String with %s placeholder: "alacritty -e %s" (backward compatible)
          -- 2. String with two %s placeholders: "alacritty --working-directory %s -e %s" (cwd, command)
          -- 3. Function returning command: function(cmd, env) return "alacritty -e " .. cmd end
          external_terminal_cmd = nil,
        },
      },
    },
    -- keys = {
    -- },
  },
  {
    "pittcat/claude-fzf.nvim",
    dependencies = {
      "ibhagwan/fzf-lua",
      "coder/claudecode.nvim",
    },
    build = false,
    opts = {
      auto_context = true,
      batch_size = 10,
    },
    cmd = {
      "ClaudeFzf",
      "ClaudeFzfFiles",
      "ClaudeFzfGrep",
      "ClaudeFzfBuffers",
      "ClaudeFzfGitFiles",
      "ClaudeFzfDirectory",
    },
  },
  {
    "pittcat/claude-fzf-history.nvim",
    dependencies = { "ibhagwan/fzf-lua" },
    opts = {
      -- History settings
      history = {
        max_items = 1000, -- Maximum number of history items
        min_item_length = 10, -- Minimum Q&A length
        cache_timeout = 300, -- Cache timeout (seconds)
        auto_refresh = true, -- Auto refresh
      },

      -- Display settings
      display = {
        max_question_length = 80, -- Maximum question display length
        show_timestamp = true, -- Show timestamps
        show_line_numbers = true, -- Show line numbers
        date_format = "%Y-%m-%d %H:%M",
      },

      -- Preview settings
      preview = {
        enabled = true, -- Enable preview
        hidden = false, -- Start with preview hidden
        position = "right:60%", -- Preview window position
        wrap = true, -- Enable line wrapping
        toggle_key = "ctrl-/", -- Toggle preview key
        scroll_up = "shift-up", -- Scroll up key
        scroll_down = "shift-down", -- Scroll down key
        type = "external", -- Preview type: 'builtin' or 'external'
        syntax_highlighting = {
          enabled = true, -- Enable syntax highlighting
          fallback = true, -- Fallback to plain text if bat unavailable
          -- theme = "Monokai Extended Bright", -- Bat theme
          theme = "tokyonight", -- Bat theme
          language = "markdown", -- Default language
          show_line_numbers = true, -- Show line numbers
        },
      },

      -- Logging
      logging = {
        level = "INFO", -- DEBUG, INFO, WARN, ERROR
        file_logging = true,
      },
    },
  },
}
