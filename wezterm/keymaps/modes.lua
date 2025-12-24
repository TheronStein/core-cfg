local wezterm = require("wezterm")
local update_mode_display = require("keymaps.keymode").update_mode_display
local mode_colors = require("keymaps.mode-colors")
local M = {}

function M.setup(config)
  config.keys = config.keys or {}

  local keys = {

    -- -- Enter HYPER mode
    -- {
    -- 	key = "CapsLock",
    -- 	mods = "LEADER",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		window:perform_action(
    -- 			wezterm.action.ActivateKeyTable({
    -- 				name = "hyper_mode",
    -- 				one_shot = true,
    -- 				replace_current = true,
    -- 			}),
    -- 			pane
    -- 		)
    -- 		-- Trigger status update AFTER activating key table
    -- 		update_mode_display(window, "HYPER")
    -- 	end),
    -- },

    -- Enter ALT mode
    {
      key = "\\",
      mods = "ALT",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(
          wezterm.action.ActivateKeyTable({
            name = "alt_mode",
            one_shot = true,
            replace_current = true,
          }),
          pane
        )
        -- Trigger status update AFTER activating key table
        update_mode_display(window, "ALT")
      end),
    },

    -- Enter CTRL mode
    {
      key = "!",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(function(window, pane)
        window:perform_action(
          wezterm.action.ActivateKeyTable({
            name = "ctrl_mode",
            one_shot = true,
            replace_current = true,
          }),
          pane
        )
        -- Trigger status update AFTER activating key table
        update_mode_display(window, "CTRL")
      end),
    },

    {
      key = "p",
      mods = "LEADER",
      action = wezterm.action_callback(function(window, pane)
        -- Set border color for pane mode
        mode_colors.set_mode_border(window, "PANE")
        window:perform_action(
          wezterm.action.ActivateKeyTable({
            name = "pane_mode",
            one_shot = false,
            timeout_milliseconds = 2000,
          }),
          pane
        )
      end),
    },

    -- -- Enter CTRL mode
    -- {
    -- 	key = "Space",
    -- 	mods = "CTRL",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		window:perform_action(
    -- 			wezterm.action.ActivateKeyTable({
    -- 				name = "ctrl_mode",
    -- 				one_shot = true,
    -- 				replace_current = true,
    -- 			}),
    -- 			pane
    -- 		)
    -- 		-- Trigger status update AFTER activating key table
    -- 		update_mode_display(window, "CTRL")
    -- 	end),
    -- },

    -- -- Enter SUPER mode
    -- {
    -- 	key = "\\",
    -- 	mods = "SUPER",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		window:perform_action(
    -- 			wezterm.action.ActivateKeyTable({
    -- 				name = "super_mode",
    -- 				one_shot = false,
    -- 				replace_current = true,
    -- 			}),
    -- 			pane
    -- 		)
    -- 		-- Trigger status update AFTER activating key table
    -- 		update_mode_display(window, "SUPER")
    -- 	end),
    -- },

    -- {
    -- 	key = "Escape",
    -- 	mods = "CTRL",
    -- 	action = wezterm.action_callback(function(window, pane)
    -- 		update_mode_display(window, "NORMAL")
    -- 		window:perform_action("PopKeyTable", pane)
    -- 	end),
    -- },
    --
  }

  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return M

--
-- -- Enter GIT mode
-- {
-- 	key = "g",
-- 	mods = "LEADER|CTRL",
-- 	action = wezterm.action_callback(function(window, pane)
-- 		update_mode_display(window, "GIT")
-- 		window:perform_action(
-- 			wezterm.action.ActivateKeyTable({
-- 				name = "git_mode",
-- 				one_shot = false,
-- 				replace_current = true,
-- 			}),
-- 			pane
-- 		)
-- 	end),
-- },
