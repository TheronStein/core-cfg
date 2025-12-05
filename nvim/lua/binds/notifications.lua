-- ╓────────────────────────────────────────────────────────────╖
-- ║ Notification System Keymaps                               ║
-- ║ Comprehensive notification management bindings             ║
-- ╙────────────────────────────────────────────────────────────╜

-- Initialize notification module
-- local notifications = require("mods.notifications")

local M = {}

function M.setup()
	-- Placeholder for any future setup logic

	local wk = require("which-key")

	wk.add({
		{ "<leader>n", "", desc = "+Notifications" },

		-- Noice history (full popup)
		{
			"<leader>nh",
			"<cmd>Noice history<cr>",
			desc = "Notification History (Noice)",
		},

		-- Noice last message
		{
			"<leader>nl",
			"<cmd>Noice last<cr>",
			desc = "Last Message (Noice)",
		},

		-- Noice all messages
		{
			"<leader>na",
			"<cmd>Noice<cr>",
			desc = "All Messages (Noice)",
		},

		-- Noice errors only
		{
			"<leader>ne",
			"<cmd>Noice errors<cr>",
			desc = "Error Messages (Noice)",
		},

		-- Show all Vim messages
		{
			"<leader>nm",
			function()
				vim.cmd("messages")
			end,
			desc = "Show :messages",
		},

		-- FZF-based notification picker
		{
			"<leader>nf",
			function()
				local messages_output = vim.fn.execute("messages")
				local messages = vim.split(messages_output, "\n")
				local items = {}
				for i, msg in ipairs(messages) do
					if msg ~= "" then
						table.insert(items, string.format("[%d] %s", i, msg))
					end
				end

				if #items == 0 then
					vim.notify("No messages to display", vim.log.levels.INFO)
					return
				end

				require("fzf-lua").fzf_exec(items, {
					prompt = "Messages> ",
					winopts = {
						height = 0.8,
						width = 0.9,
						preview = {
							hidden = "hidden",
						},
					},
					actions = {
						["default"] = function(selected)
							if selected and #selected > 0 then
								-- Copy selected message to clipboard
								local msg = selected[1]:match("%[%d+%] (.+)")
								if msg then
									vim.fn.setreg("+", msg)
									vim.notify("Copied to clipboard", vim.log.levels.INFO)
								end
							end
						end,
					},
				})
			end,
			desc = "Search Messages (FZF)",
		},

		-- Dismiss all notifications
		{
			"<leader>nd",
			"<cmd>Noice dismiss<cr>",
			desc = "Dismiss All Notifications",
		},

		-- Clear messages
		{
			"<leader>nc",
			function()
				vim.cmd("messages clear")
				vim.notify("Messages cleared", vim.log.levels.INFO)
			end,
			desc = "Clear :messages",
		},
		-- {
		-- 	"<c-f>",
		-- 	function()
		-- 		if not require("noice.lsp").scroll(4) then
		-- 			return "<c-f>"
		-- 		end
		-- 	end,
		-- 	silent = true,
		-- 	expr = true,
		-- 	desc = "Scroll forward",
		-- 	mode = { "i", "n", "s" },
		-- },
		-- {
		-- 	"<c-b>",
		-- 	function()
		-- 		if not require("noice.lsp").scroll(-4) then
		-- 			return "<c-b>"
		-- 		end
		-- 	end,
		-- 	silent = true,
		-- 	expr = true,
		-- 	desc = "Scroll backward",
		-- 	mode = { "i", "n", "s" },
		-- },
	})
end

return M

-- Notification menu keymaps under <leader>n*
-- local keymaps = {
--   -- History and Overview
--   {
--     "<localleader>nn",
--     function()
--       require("snacks").notifier.show_history()
--     end,
--     desc = "Notification History (Snacks)",
--   },
--   {
--     "<leader>nh",
--     function()
--       require("snacks").notifier.show_history()
--     end,
--     desc = "Notification History (Alt)",
--   },
--   {
--     "<leader>nr",
--     function()
--       notifications.show_recent(10)
--     end,
--     desc = "Recent Notifications (10)",
--   },
--   {
--     "<leader>nR",
--     function()
--       notifications.show_recent(25)
--     end,
--     desc = "Recent Notifications (25)",
--   },
--
--   -- Filtered Views
--   {
--     "<leader>ne",
--     function()
--       notifications.show_filtered("errors")
--     end,
--     desc = "Error Notifications",
--   },
--   {
--     "<leader>nw",
--     function()
--       notifications.show_filtered("warnings")
--     end,
--     desc = "Warning Notifications",
--   },
--   {
--     "<leader>ni",
--     function()
--       notifications.show_filtered("info")
--     end,
--     desc = "Info Notifications",
--   },
--   {
--     "<leader>nD",
--     function()
--       notifications.show_filtered("debug")
--     end,
--     desc = "Debug Notifications",
--   },
--   {
--     "<leader>na",
--     function()
--       notifications.show_filtered("all")
--     end,
--     desc = "All Notifications",
--   },
--
--   -- Actions
--   {
--     "<leader>nd",
--     function()
--       require("snacks").notifier.hide()
--     end,
--     desc = "Dismiss All Notifications",
--   },
--   {
--     "<leader>nc",
--     function()
--       notifications.clear_cache()
--     end,
--     desc = "Clear Notification Cache",
--   },
--   {
--     "<leader>ns",
--     function()
--       notifications.search_notifications()
--     end,
--     desc = "Search Notifications",
--   },
--   {
--     "<leader>nS",
--     function()
--       notifications.show_stats()
--     end,
--     desc = "Notification Statistics",
--   },
--
--   -- Noice specific (if available)
--   {
--     "<leader>nl",
--     function()
--       if pcall(require, "noice") then
--         require("noice").cmd("last")
--       else
--         vim.notify("Noice not available", vim.log.levels.WARN)
--       end
--     end,
--     desc = "Last Message (Noice)",
--   },
--
--   {
--     "<leader>nH",
--     function()
--       if pcall(require, "noice") then
--         require("noice").cmd("history")
--       else
--         notifications.show_filtered("all")
--       end
--     end,
--     desc = "Full History (Noice)",
--   },
--
--   {
--     "<leader>nE",
--     function()
--       if pcall(require, "noice") then
--         require("noice").cmd("errors")
--       else
--         notifications.show_filtered("errors")
--       end
--     end,
--     desc = "Errors (Noice)",
--   },

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

-- -- Set up keymaps
-- for _, keymap in ipairs(keymaps) do
-- 	vim.keymap.set("n", keymap[0], keymap[2], { desc = keymap.desc, silent = true })
-- end
--
-- -- Add which-key group registration
-- if pcall(require, "which-key") then
-- 	require("which-key").add({
-- 		{ "<leader>n", group = "notifications", desc = "Notifications" },
-- 	})
-- end
--
-- -- Export for use in other modules
-- return {
-- 	keymaps = keymaps,
-- }
