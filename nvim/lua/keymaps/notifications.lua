-- ╓────────────────────────────────────────────────────────────╖
-- ║ Notification System Keymaps                               ║
-- ║ Comprehensive notification management bindings             ║
-- ╙────────────────────────────────────────────────────────────╜

-- Initialize notification module
local notifications = require("mods.notifications")
notifications.setup()

local wk = require("which-key")

wk.add({
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
  {
    "<leader>nl",
    function()
      require("noice").cmd("last")
    end,
    desc = "Noice Last Message",
  },
  {
    "<leader>nh",
    function()
      require("noice").cmd("history")
    end,
    desc = "Noice History",
  },
  {
    "<leader>na",
    function()
      require("noice").cmd("all")
    end,
    desc = "Noice All",
  },
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
})

-- Notification menu keymaps under <leader>n*
local keymaps = {
  -- History and Overview
  {
    "<localleader>nn",
    function()
      require("snacks").notifier.show_history()
    end,
    desc = "Notification History (Snacks)",
  },
  {
    "<leader>nh",
    function()
      require("snacks").notifier.show_history()
    end,
    desc = "Notification History (Alt)",
  },
  {
    "<leader>nr",
    function()
      notifications.show_recent(10)
    end,
    desc = "Recent Notifications (10)",
  },
  {
    "<leader>nR",
    function()
      notifications.show_recent(25)
    end,
    desc = "Recent Notifications (25)",
  },

  -- Filtered Views
  {
    "<leader>ne",
    function()
      notifications.show_filtered("errors")
    end,
    desc = "Error Notifications",
  },
  {
    "<leader>nw",
    function()
      notifications.show_filtered("warnings")
    end,
    desc = "Warning Notifications",
  },
  {
    "<leader>ni",
    function()
      notifications.show_filtered("info")
    end,
    desc = "Info Notifications",
  },
  {
    "<leader>nD",
    function()
      notifications.show_filtered("debug")
    end,
    desc = "Debug Notifications",
  },
  {
    "<leader>na",
    function()
      notifications.show_filtered("all")
    end,
    desc = "All Notifications",
  },

  -- Actions
  {
    "<leader>nd",
    function()
      require("snacks").notifier.hide()
    end,
    desc = "Dismiss All Notifications",
  },
  {
    "<leader>nc",
    function()
      notifications.clear_cache()
    end,
    desc = "Clear Notification Cache",
  },
  {
    "<leader>ns",
    function()
      notifications.search_notifications()
    end,
    desc = "Search Notifications",
  },
  {
    "<leader>nS",
    function()
      notifications.show_stats()
    end,
    desc = "Notification Statistics",
  },

  -- Noice specific (if available)
  {
    "<leader>nl",
    function()
      if pcall(require, "noice") then
        require("noice").cmd("last")
      else
        vim.notify("Noice not available", vim.log.levels.WARN)
      end
    end,
    desc = "Last Message (Noice)",
  },

  {
    "<leader>nH",
    function()
      if pcall(require, "noice") then
        require("noice").cmd("history")
      else
        notifications.show_filtered("all")
      end
    end,
    desc = "Full History (Noice)",
  },

  {
    "<leader>nE",
    function()
      if pcall(require, "noice") then
        require("noice").cmd("errors")
      else
        notifications.show_filtered("errors")
      end
    end,
    desc = "Errors (Noice)",
  },

  -- -- Quick filters using fzf-lua
  -- { "<leader>nf", function()
  --     local fzf = require("fzf-lua")
  --     local all_notifs = {}
  --
  --     -- Collect all notifications
  --     for _, entry in ipairs(require("mods.notifications").get_all_notifications and require("mods.notifications").get_all_notifications() or {}) do
  --       local time_str = os.date("%H:%M:%S", entry.time or os.time())
  --       local level_str = ({
  --         [vim.log.levels.ERROR] = "ERROR",
  --         [vim.log.levels.WARN] = "WARN",
  --         [vim.log.levels.INFO] = "INFO",
  --         [vim.log.levels.DEBUG] = "DEBUG"
  --       })[entry.level] or "INFO"
  --
  --       table.insert(all_notifs, string.format("[%s] %s: %s", time_str, level_str, entry.message))
  --     end
  --
  --     if #all_notifs == 0 then
  --       vim.notify("No notifications to filter", vim.log.levels.INFO)
  --       return
  --     end
  --
  --     fzf.fzf_exec(all_notifs, {
  --       prompt = "Filter Notifications> ",
  --       preview = false,
  --       actions = {
  --         ["default"] = function(selected)
  --           if selected and #selected > 0 then
  --             vim.notify("Selected: " .. selected[1], vim.log.levels.INFO)
  --           end
  --         end
  --       }
  --     })
  --   end, desc = "Filter Notifications (FZF)" },
}

-- Set up keymaps
for _, keymap in ipairs(keymaps) do
  vim.keymap.set("n", keymap[1], keymap[2], { desc = keymap.desc, silent = true })
end

-- Add which-key group registration
if pcall(require, "which-key") then
  require("which-key").add({
    { "<localleader>n", group = "notifications", desc = "Notifications" },
  })
end

-- Export for use in other modules
return {
  keymaps = keymaps,
}
