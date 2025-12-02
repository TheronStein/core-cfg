-- Seamless tmux/neovim navigation
local M = {}

-- Check if we're in tmux
local function is_tmux()
  return vim.env.TMUX ~= nil
end

-- Get tmux pane info
local function get_tmux_pane()
  if not is_tmux() then
    return nil
  end
  local handle =
    io.popen("tmux display-message -p '#{pane_id}:#{pane_at_left}:#{pane_at_right}:#{pane_at_top}:#{pane_at_bottom}'")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result
  end
  return nil
end

-- Check if tmux is at edge
local function is_tmux_at_edge(direction)
  if not is_tmux() then
    return false
  end
  local handle = io.popen("tmux display-message -p '#{pane_at_left}:#{pane_at_right}:#{pane_at_top}:#{pane_at_bottom}'")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local left, right, top, bottom = result:match("(%d+):(%d+):(%d+):(%d+)")

    local edge_map = {
      left = left == "1",
      right = right == "1",
      up = top == "1",
      down = bottom == "1",
    }
    return edge_map[direction] or false
  end
  return false
end

-- Navigate or pass to tmux/wezterm
local function navigate(direction)
  -- Try vim navigation first
  local win_before = vim.api.nvim_get_current_win()

  -- Map direction to vim commands
  local vim_direction = {
    left = "h",
    down = "j",
    up = "k",
    right = "l",
  }

  -- Try to move in vim
  vim.cmd("wincmd " .. vim_direction[direction])
  local win_after = vim.api.nvim_get_current_win()

  -- If we didn't move in vim
  if win_before == win_after then
    if is_tmux() then
      -- Check if tmux is at edge - if so, pass to WezTerm via special signal
      if is_tmux_at_edge(direction) then
        -- Send Ctrl+Shift+Arrow to signal WezTerm to navigate
        local arrow_map = {
          left = "Left",
          down = "Down",
          up = "Up",
          right = "Right",
        }
        vim.fn.system("tmux send-keys C-S-" .. arrow_map[direction])
      else
        -- Navigate within tmux
        local tmux_direction = {
          left = "L",
          down = "D",
          up = "U",
          right = "R",
        }
        vim.fn.system("tmux select-pane -" .. tmux_direction[direction])
      end
    end
  end
end

-- Set up keymaps
function M.setup()
  local opts = { noremap = true, silent = true }

  -- WASD navigation
  vim.keymap.set("n", "<M-w>", function()
    navigate("up")
  end, opts)
  vim.keymap.set("n", "<M-a>", function()
    navigate("left")
  end, opts)
  vim.keymap.set("n", "<M-s>", function()
    navigate("down")
  end, opts)
  vim.keymap.set("n", "<M-d>", function()
    navigate("right")
  end, opts)

  -- Also in insert and visual modes
  vim.keymap.set("i", "<M-w>", function()
    vim.cmd("stopinsert")
    navigate("up")
  end, opts)
  vim.keymap.set("i", "<M-a>", function()
    vim.cmd("stopinsert")
    navigate("left")
  end, opts)
  vim.keymap.set("i", "<M-s>", function()
    vim.cmd("stopinsert")
    navigate("down")
  end, opts)
  vim.keymap.set("i", "<M-d>", function()
    vim.cmd("stopinsert")
    navigate("right")
  end, opts)

  vim.keymap.set("v", "<M-w>", function()
    navigate("up")
  end, opts)
  vim.keymap.set("v", "<M-a>", function()
    navigate("left")
  end, opts)
  vim.keymap.set("v", "<M-s>", function()
    navigate("down")
  end, opts)
  vim.keymap.set("v", "<M-d>", function()
    navigate("right")
  end, opts)

  -- Also support vim-style h/j/k/l
  vim.keymap.set("n", "<M-h>", function()
    navigate("left")
  end, opts)
  vim.keymap.set("n", "<M-j>", function()
    navigate("down")
  end, opts)
  vim.keymap.set("n", "<M-k>", function()
    navigate("up")
  end, opts)
  vim.keymap.set("n", "<M-l>", function()
    navigate("right")
  end, opts)

  -- Terminal mode mappings
  vim.keymap.set("t", "<M-w>", [[<C-\><C-n>:lua require('mods.tmux-vim-navigation').navigate('up')<CR>]], opts)
  vim.keymap.set("t", "<M-a>", [[<C-\><C-n>:lua require('mods.tmux-vim-navigation').navigate('left')<CR>]], opts)
  vim.keymap.set("t", "<M-s>", [[<C-\><C-n>:lua require('mods.tmux-vim-navigation').navigate('down')<CR>]], opts)
  vim.keymap.set("t", "<M-d>", [[<C-\><C-n>:lua require('mods.tmux-vim-navigation').navigate('right')<CR>]], opts)
end

-- Export functions
M.navigate = navigate
M.is_tmux = is_tmux

return M
