-- ╓────────────────────────────────────────────────────────────╖
-- ║ Enhanced Notification Management System                    ║
-- ║ Comprehensive notification menus and filtering             ║
-- ╙────────────────────────────────────────────────────────────╜

local M = {}

-- Cache for notification history categorization
local notification_cache = {
  errors = {},
  warnings = {},
  info = {},
  debug = {},
  all = {},
}

-- Track notification stats
local stats = {
  total = 0,
  errors = 0,
  warnings = 0,
  info = 0,
  debug = 0,
  last_clear = nil,
}

-- Initialize notification tracking
local function init_notification_tracking()
  -- Hook into vim.notify to track notifications
  local original_notify = vim.notify
  vim.notify = function(msg, level, opts)
    -- Call original notify
    original_notify(msg, level, opts)

    -- Track notification
    local entry = {
      message = msg,
      level = level,
      time = os.time(),
      opts = opts or {},
    }

    -- Add to cache
    table.insert(notification_cache.all, 1, entry)

    -- Categorize by level
    if level == vim.log.levels.ERROR then
      table.insert(notification_cache.errors, 1, entry)
      stats.errors = stats.errors + 1
    elseif level == vim.log.levels.WARN then
      table.insert(notification_cache.warnings, 1, entry)
      stats.warnings = stats.warnings + 1
    elseif level == vim.log.levels.INFO then
      table.insert(notification_cache.info, 1, entry)
      stats.info = stats.info + 1
    elseif level == vim.log.levels.DEBUG or level == vim.log.levels.TRACE then
      table.insert(notification_cache.debug, 1, entry)
      stats.debug = stats.debug + 1
    end

    stats.total = stats.total + 1

    -- Limit cache size (keep last 100 per category)
    for key, cache in pairs(notification_cache) do
      if #cache > 100 then
        for i = 101, #cache do
          cache[i] = nil
        end
      end
    end
  end
end

-- Format notification for display
local function format_notification(entry)
  local level_str = "INFO"
  local level_hl = "Normal"
  local level_icon = ""

  if entry.level == vim.log.levels.ERROR then
    level_str = "ERROR"
    level_hl = "ErrorMsg"
    level_icon = ""
  elseif entry.level == vim.log.levels.WARN then
    level_str = "WARN"
    level_hl = "WarningMsg"
    level_icon = ""
  elseif entry.level == vim.log.levels.INFO then
    level_str = "INFO"
    level_hl = "Normal"
    level_icon = "󰋼"
  elseif entry.level == vim.log.levels.DEBUG then
    level_str = "DEBUG"
    level_hl = "Comment"
    level_icon = ""
  elseif entry.level == vim.log.levels.TRACE then
    level_str = "TRACE"
    level_hl = "Comment"
    level_icon = "✎"
  end

  local time_str = os.date("%H:%M:%S", entry.time)

  return string.format("[%s] %s %s: %s", time_str, level_icon, level_str, entry.message), level_hl
end

-- Show filtered notifications
function M.show_filtered(filter_type)
  local notifications = notification_cache[filter_type] or {}

  if #notifications == 0 then
    vim.notify("No " .. filter_type .. " notifications", vim.log.levels.INFO)
    return
  end

  -- Create buffer for display
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}
  local highlights = {}

  -- Add header
  table.insert(
    lines,
    "─────────────────────────────────────────────────"
  )
  table.insert(lines, " " .. string.upper(filter_type) .. " NOTIFICATIONS (" .. #notifications .. " total)")
  table.insert(
    lines,
    "─────────────────────────────────────────────────"
  )
  table.insert(lines, "")

  -- Add notifications
  for i, entry in ipairs(notifications) do
    local formatted, hl = format_notification(entry)
    table.insert(lines, formatted)
    table.insert(highlights, { line = #lines - 1, hl = hl })

    -- Add separator between entries
    if i < #notifications then
      table.insert(lines, "")
    end
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

  -- Apply highlights
  for _, hl_info in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl_info.hl, hl_info.line, 0, -1)
  end

  -- Create floating window
  local width = math.min(80, vim.o.columns - 10)
  local height = math.min(30, vim.o.lines - 10)

  -- Get icon for filter type
  local title_icon = ({
    errors = "",
    warnings = "",
    info = "",
    debug = "",
    all = "",
  })[filter_type] or ""

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " " .. title_icon .. " " .. string.upper(filter_type) .. " ",
    title_pos = "center",
  })

  -- Set window options with better styling
  vim.api.nvim_set_option_value("wrap", true, { win = win })
  vim.api.nvim_set_option_value("linebreak", true, { win = win })
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  vim.api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:FloatBorder,FloatTitle:Title", { win = win })

  -- Add keymaps for window
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, desc = "Close notification window" })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, desc = "Close notification window" })
end

-- Search notifications
function M.search_notifications()
  vim.ui.input({ prompt = "Search notifications: " }, function(query)
    if not query or query == "" then
      return
    end

    local results = {}
    for _, entry in ipairs(notification_cache.all) do
      if entry.message:lower():find(query:lower(), 1, true) then
        table.insert(results, entry)
      end
    end

    if #results == 0 then
      vim.notify("No notifications matching: " .. query, vim.log.levels.INFO)
      return
    end

    -- Display results
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = {}

    table.insert(
      lines,
      "─────────────────────────────────────────────────"
    )
    table.insert(lines, ' SEARCH RESULTS: "' .. query .. '" (' .. #results .. " matches)")
    table.insert(
      lines,
      "─────────────────────────────────────────────────"
    )
    table.insert(lines, "")

    for i, entry in ipairs(results) do
      local formatted = format_notification(entry)
      table.insert(lines, formatted)
      if i < #results then
        table.insert(lines, "")
      end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

    -- Create window
    local width = math.min(80, vim.o.columns - 10)
    local height = math.min(30, vim.o.lines - 10)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      style = "minimal",
      border = "rounded",
      title = "  Search Results ",
      title_pos = "center",
    })

    -- Set window options with better styling
    vim.api.nvim_set_option_value("wrap", true, { win = win })
    vim.api.nvim_set_option_value("linebreak", true, { win = win })
    vim.api.nvim_set_option_value("cursorline", true, { win = win })
    vim.api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:FloatBorder,FloatTitle:Title", { win = win })

    -- Window keymaps
    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf })

    vim.keymap.set("n", "<Esc>", function()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf })
  end)
end

-- Show notification statistics
function M.show_stats()
  local lines = {
    "╔════════════════════════════════════════════╗",
    "║       NOTIFICATION STATISTICS              ║",
    "╚════════════════════════════════════════════╝",
    "",
    "Total Notifications: " .. stats.total,
    "",
    "By Type:",
    "  • Errors:   " .. stats.errors .. " (" .. string.format(
      "%.1f%%",
      (stats.errors / math.max(1, stats.total)) * 100
    ) .. ")",
    "  • Warnings: " .. stats.warnings .. " (" .. string.format(
      "%.1f%%",
      (stats.warnings / math.max(1, stats.total)) * 100
    ) .. ")",
    "  • Info:     "
      .. stats.info
      .. " ("
      .. string.format("%.1f%%", (stats.info / math.max(1, stats.total)) * 100)
      .. ")",
    "  • Debug:    " .. stats.debug .. " (" .. string.format(
      "%.1f%%",
      (stats.debug / math.max(1, stats.total)) * 100
    ) .. ")",
    "",
    "Cache Status:",
    "  • All:      " .. #notification_cache.all .. " messages",
    "  • Errors:   " .. #notification_cache.errors .. " messages",
    "  • Warnings: " .. #notification_cache.warnings .. " messages",
    "  • Info:     " .. #notification_cache.info .. " messages",
    "  • Debug:    " .. #notification_cache.debug .. " messages",
  }

  if stats.last_clear then
    table.insert(lines, "")
    table.insert(lines, "Last Cleared: " .. os.date("%Y-%m-%d %H:%M:%S", stats.last_clear))
  end

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- Create window
  local width = 50
  local height = #lines + 2
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = "  Statistics ",
    title_pos = "center",
  })

  -- Set window options with better styling
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  vim.api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:FloatBorder,FloatTitle:Title", { win = win })

  -- Keymaps
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
end

-- Clear notification cache
function M.clear_cache()
  for key, _ in pairs(notification_cache) do
    notification_cache[key] = {}
  end
  stats.last_clear = os.time()
  vim.notify("Notification cache cleared", vim.log.levels.INFO)
end

-- Show recent notifications (with limit)
function M.show_recent(limit)
  limit = limit or 10
  local recent = {}

  for i = 1, math.min(limit, #notification_cache.all) do
    table.insert(recent, notification_cache.all[i])
  end

  if #recent == 0 then
    vim.notify("No recent notifications", vim.log.levels.INFO)
    return
  end

  -- Create display
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {
    "─────────────────────────────────────────────────",
    " RECENT NOTIFICATIONS (Last " .. limit .. ")",
    "─────────────────────────────────────────────────",
    "",
  }

  for i, entry in ipairs(recent) do
    local formatted = format_notification(entry)
    table.insert(lines, formatted)
    if i < #recent then
      table.insert(lines, "")
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  -- Create window
  local width = math.min(80, vim.o.columns - 10)
  local height = math.min(30, vim.o.lines - 10)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = "  Recent Notifications ",
    title_pos = "center",
  })

  -- Set window options with better styling
  vim.api.nvim_set_option_value("wrap", true, { win = win })
  vim.api.nvim_set_option_value("linebreak", true, { win = win })
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  vim.api.nvim_set_option_value("winhl", "Normal:Normal,FloatBorder:FloatBorder,FloatTitle:Title", { win = win })

  -- Keymaps
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
end

-- Get all notifications (for external use)
function M.get_all_notifications()
  return notification_cache.all
end

-- Setup function
function M.setup()
  -- Initialize tracking
  init_notification_tracking()

  -- Create notification menu commands
  vim.api.nvim_create_user_command("NotifyErrors", function()
    M.show_filtered("errors")
  end, { desc = "Show error notifications" })

  vim.api.nvim_create_user_command("NotifyWarnings", function()
    M.show_filtered("warnings")
  end, { desc = "Show warning notifications" })

  vim.api.nvim_create_user_command("NotifyInfo", function()
    M.show_filtered("info")
  end, { desc = "Show info notifications" })

  vim.api.nvim_create_user_command("NotifyDebug", function()
    M.show_filtered("debug")
  end, { desc = "Show debug notifications" })

  vim.api.nvim_create_user_command("NotifySearch", function()
    M.search_notifications()
  end, { desc = "Search notifications" })

  vim.api.nvim_create_user_command("NotifyStats", function()
    M.show_stats()
  end, { desc = "Show notification statistics" })

  vim.api.nvim_create_user_command("NotifyClear", function()
    M.clear_cache()
  end, { desc = "Clear notification cache" })

  vim.api.nvim_create_user_command("NotifyRecent", function(opts)
    local limit = tonumber(opts.args) or 10
    M.show_recent(limit)
  end, { desc = "Show recent notifications", nargs = "?" })
end

return M
