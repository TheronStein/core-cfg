-- smart-splits.nvim - Seamless navigation between nvim/tmux/terminal
--
-- Uses CLI tools (wezterm cli, kitty @, ghostty +action) at edge
-- Sets @pane-is-vim for tmux detection
--
-- Keybinds: Ctrl+Shift+W/A/S/D for navigation

return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- Must load early for @pane-is-vim

  config = function()
    local ss = require("smart-splits")

    -- Navigate terminal panes using CLI tools
    local function navigate_terminal(direction)
      local dir_map = {
        left = { ghostty = "left", wezterm = "Left", kitty = "left" },
        right = { ghostty = "right", wezterm = "Right", kitty = "right" },
        up = { ghostty = "up", wezterm = "Up", kitty = "top" },
        down = { ghostty = "down", wezterm = "Down", kitty = "bottom" },
      }
      local dirs = dir_map[direction]
      if not dirs then
        return
      end

      -- Use terminal-nav script if available (preferred)
      local terminal_nav = vim.fn.expand("~/.local/bin/terminal-nav")
      if vim.fn.executable(terminal_nav) == 1 then
        vim.fn.jobstart({ terminal_nav, direction }, { detach = true })
        return
      end

      -- Fallback to direct CLI calls
      if vim.env.GHOSTTY_RESOURCES_DIR then
        -- Ghostty: Send CSI sequences for Ctrl+Shift+Arrow to trigger goto_split keybinds
        local csi_arrows = {
          left = "\x1b[1;6D",   -- Ctrl+Shift+Left
          right = "\x1b[1;6C",  -- Ctrl+Shift+Right
          up = "\x1b[1;6A",     -- Ctrl+Shift+Up
          down = "\x1b[1;6B",   -- Ctrl+Shift+Down
        }
        local seq = csi_arrows[direction]
        if seq then
          -- Write directly to terminal
          vim.fn.chansend(vim.v.stderr, seq)
        end
      elseif vim.env.WEZTERM_PANE then
        vim.fn.jobstart({ "wezterm", "cli", "activate-pane-direction", dirs.wezterm }, { detach = true })
      elseif vim.env.KITTY_PID then
        local socket = vim.env.KITTY_LISTEN_ON or "unix:/tmp/mykitty"
        vim.fn.jobstart({ "kitty", "@", "--to", socket, "focus-window", "--match", "neighbor:" .. dirs.kitty }, { detach = true })
      end
    end

    -- Check if at tmux edge (no more tmux panes in direction)
    local function at_tmux_edge(direction)
      local edge_checks = {
        left = "#{pane_at_left}",
        right = "#{pane_at_right}",
        up = "#{pane_at_top}",
        down = "#{pane_at_bottom}",
      }
      local check = edge_checks[direction]
      if not check then
        return false
      end
      local result = vim.fn.system("tmux display-message -p '" .. check .. "'")
      return vim.trim(result) == "1"
    end

    ss.setup({
      -- At edge behavior:
      -- - Not in tmux: navigate terminal directly via CLI
      -- - In tmux at tmux edge: navigate terminal directly via CLI
      -- - In tmux not at edge: wrap to tmux pane
      at_edge = function(ctx)
        -- Not in tmux - navigate terminal panes directly
        if not vim.env.TMUX then
          navigate_terminal(ctx.direction)
          return false
        end

        -- In tmux - check if we're also at tmux edge
        if at_tmux_edge(ctx.direction) then
          -- Both nvim and tmux are at edge - navigate terminal directly
          navigate_terminal(ctx.direction)
          return false
        end

        -- In tmux but not at tmux edge - let smart-splits wrap to tmux
        return nil
      end,

      -- Multiplexer integration - explicitly enable tmux
      multiplexer_integration = "tmux",

      -- Don't navigate when pane is zoomed
      disable_multiplexer_nav_when_zoomed = true,

      -- Resize amount
      default_amount = 3,

      -- Ignore during resize
      ignored_filetypes = { "NvimTree", "neo-tree", "Trouble", "qf" },
      ignored_buftypes = { "nofile", "quickfix", "prompt" },
    })

    -- Navigation keymaps: Ctrl+Shift+W/A/S/D
    local opts = { noremap = true, silent = true, desc = "Smart split navigation" }

    -- Normal, Insert, Visual modes
    vim.keymap.set({ "n", "i", "v" }, "<C-S-w>", ss.move_cursor_up, opts)
    vim.keymap.set({ "n", "i", "v" }, "<C-S-s>", ss.move_cursor_down, opts)
    vim.keymap.set({ "n", "i", "v" }, "<C-S-a>", ss.move_cursor_left, opts)
    vim.keymap.set({ "n", "i", "v" }, "<C-S-d>", ss.move_cursor_right, opts)

    -- Terminal mode navigation
    vim.keymap.set("t", "<C-S-w>", [[<C-\><C-n><Cmd>lua require("smart-splits").move_cursor_up()<CR>]], opts)
    vim.keymap.set("t", "<C-S-s>", [[<C-\><C-n><Cmd>lua require("smart-splits").move_cursor_down()<CR>]], opts)
    vim.keymap.set("t", "<C-S-a>", [[<C-\><C-n><Cmd>lua require("smart-splits").move_cursor_left()<CR>]], opts)
    vim.keymap.set("t", "<C-S-d>", [[<C-\><C-n><Cmd>lua require("smart-splits").move_cursor_right()<CR>]], opts)

    -- Also set up resize keymaps (Alt+Shift+W/A/S/D)
    vim.keymap.set("n", "<A-S-w>", ss.resize_up, opts)
    vim.keymap.set("n", "<A-S-s>", ss.resize_down, opts)
    vim.keymap.set("n", "<A-S-a>", ss.resize_left, opts)
    vim.keymap.set("n", "<A-S-d>", ss.resize_right, opts)
  end,
}
