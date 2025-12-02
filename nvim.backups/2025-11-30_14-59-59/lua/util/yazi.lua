-- ~/.config/nvim/lua/plugins/yazi.lua
-- Simple yazi configuration that works naturally with tabs
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ee", "<cmd>Yazi<cr>", desc = "Open yazi (current window)" },
    { "<leader>ed", "<cmd>Yazi cwd<cr>", desc = "Open yazi (working directory)" },
    { "<leader>es", "<cmd>Yazi toggle<cr>", desc = "Resume last yazi session" },
    {
      "<leader>ev",
      function()
        vim.cmd("vsplit")
        vim.schedule(function()
          vim.cmd("Yazi")
        end)
      end,
      desc = "Open yazi in vertical split",
    },
  },
  opts = {
    open_for_directories = false,
    -- Disable floating to match your buffer-replacement preference
    floating_window_scaling_factor = nil, -- Disables floating entirely
    yazi_floating_window_winblend = 0,
    yazi_floating_window_use_border = false,
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-g>",
      cycle_open_buffers = "<tab>",
    },
  },
  init = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  -- Force latest: ignore versions, always use main branch head
  version = false,
  branch = "main",
}
-- return {
-- 	"mikavilpas/yazi.nvim",
-- 	event = "VeryLazy", -- keeps startup fast
-- 	dependencies = {
-- 		"nvim-lua/plenary.nvim",
-- 	},
-- 	keys = {
-- 		{ "<leader>ee", "<cmd>Yazi<cr>,          ", desc = "Open yazi (current window)" },
-- 		{ "<leader>ed", "<cmd>Yazi cwd<cr>        ", desc = "Open yazi (working directory)" },
-- 		{ "<leader>es", "<cmd>Yazi toggle<cr>     ", desc = "Resume last yazi session" },
-- 		{
-- 			"<leader>et",
-- 			function()
-- 				vim.cmd("tabnew")
-- 				vim.cmd("Yazi")
-- 				if vim.fn.exists(":Tabby") > 0 then
-- 					vim.cmd("Tabby rename_tab Files")
-- 				end
-- 			end,
-- 			desc = "Open yazi in new tab",
-- 		},
-- 		{
-- 			"<leader>ev",
-- 			function()
-- 				vim.cmd("vsplit")
-- 				vim.schedule(function()
-- 					vim.cmd("Yazi")
-- 				end)
-- 			end,
-- 			desc = "Open yazi in vertical split",
-- 		},
-- 	},
-- 	opts = {
-- 		open_for_directories = false, -- you already use oil.nvim or something else
--
-- 		-- Completely disable floating window (you prefer replacing the buffer)
-- 		floating_window_scaling_factor = nil, -- this disables floating mode entirely
-- 		yazi_floating_window_winblend = 0,
-- 		yazi_floating_window_use_border = false,
--
-- 		keymaps = {
-- 			show_help = "<f1>",
-- 			open_file_in_vertical_split = "<c-v>",
-- 			open_file_in_horizontal_split = "<c-x>",
-- 			open_file_in_tab = "<c-t>",
-- 			grep_in_directory = "<c-g>",
-- 			cycle_open_buffers = "<tab>",
-- 		},
-- 	},
--
-- 	-- This is the important part — always use the latest commit
-- 	version = false, -- disable semantic versioning
-- 	branch = "main", -- or delete this line completely
-- 	pin = false, -- make sure lazy doesn’t pin an old commit
-- }
-- return {
-- 	"mikavilpas/yazi.nvim",
-- 	branch = "main",          -- or pin a recent tag
--   commit = "8b3f6b9",         -- optional – any commit after 2025-10-01 is fine
--   version = "^13",          -- or just delete the version line completely
--   event = "VeryLazy",
-- 	dependencies = {
-- 		{ "nvim-lua/plenary.nvim", lazy = true },
-- 	},
-- 	keys = {
-- 		-- Standard yazi operations
-- 		{
-- 			"<leader>ee",
-- 			"<cmd>Yazi<cr>",
-- 			desc = "Open yazi (current window)",
-- 		},
-- 		{
-- 			"<leader>ed",
-- 			"<cmd>Yazi cwd<cr>",
-- 			desc = "Open yazi (working directory)",
-- 		},
-- 		{
-- 			"<leader>es",
-- 			"<cmd>Yazi toggle<cr>",
-- 			desc = "Resume last yazi session",
-- 		},
--
-- 		-- Tab integration
-- 		{
-- 			"<leader>et",
-- 			function()
-- 				vim.cmd("tabnew")
-- 				vim.cmd("Yazi")
-- 				-- Optionally rename the tab
-- 				if vim.fn.exists(":Tabby") > 0 then
-- 					vim.cmd("Tabby rename_tab Files")
-- 				end
-- 			end,
-- 			desc = "Open yazi in new tab",
-- 		},
-- 		{
-- 			"<leader>ev",
-- 			function()
-- 				vim.cmd("vsplit")
-- 				vim.schedule(function() -- Schedule to run after split is created
-- 					vim.cmd("Yazi")
-- 				end)
-- 			end,
-- 			desc = "Open yazi in vertical split",
-- 		},
-- 	},
-- 	opts = {
-- 		open_for_directories = false,
--
-- 		-- Force non-floating mode
-- 		yazi_floating_window_use_border = "none",
-- 		enable_mouse_support = false,
--
-- 		-- Or try this approach to disable floating entirely
-- 		open_cmd = function(dir)
-- 			vim.cmd("edit " .. dir)
-- 		end,
-- 		-- The key insight: yazi already handles file opening correctly!
-- 		-- When you select files in yazi:
-- 		-- - Single file: Opens in current window (replaces yazi)
-- 		-- - Multiple files: Opens as buffers in current tab
-- 		-- - Use yazi's built-in keymaps for control:
--
-- 		keymaps = {
-- 			show_help = "<f1>",
-- 			open_file_in_vertical_split = "<c-v>",
-- 			open_file_in_horizontal_split = "<c-x>",
-- 			open_file_in_tab = "<c-t>", -- This opens in a new tab!
-- 			grep_in_directory = "<c-g>",
-- 			cycle_open_buffers = "<c-b>",
-- 		},
--
-- 		-- -- Floating window settings
-- 		-- floating_window_scaling_factor = 0.8,
-- 		-- yazi_floating_window_winblend = 10,
-- 	},
--
-- 	init = function()
-- 		-- Disable netrw
-- 		vim.g.loaded_netrw = 1
-- 		vim.g.loaded_netrwPlugin = 1
-- 	end,
-- }

-- return {
--   -- ... other lazy.nvim configuration from above
--
--   ---@type YaziConfig | {}
--   opts = {
--     -- Below is the default configuration. It is optional to set these values.
--     -- You can customize the configuration for each yazi call by passing it to
--     -- yazi() explicitly
--
--     -- enable this if you want to open yazi instead of netrw.
--     -- Note that if you enable this, you need to call yazi.setup() to
--     -- initialize the plugin. lazy.nvim does this for you in certain cases.
--     --
--     -- If you are also using neotree, you may prefer not to bring it up when
--     -- opening a directory:
--     -- {
--     --   "nvim-neo-tree/neo-tree.nvim",
--     --   opts = {
--     --     filesystem = {
--     --       hijack_netrw_behavior = "disabled",
--     --     },
--     --   },
--     -- }
--     open_for_directories = false,
--
--     -- open visible splits and quickfix items as yazi tabs for easy navigation
--     -- https://github.com/mikavilpas/yazi.nvim/pull/359
--     open_multiple_tabs = false,
--
--     -- when yazi is closed with no file chosen, change the Neovim working
--     -- directory to the directory that yazi was in before it was closed. Defaults
--     -- to being off (`false`)
--     change_neovim_cwd_on_close = false,
--
--     highlight_groups = {
--       -- See https://github.com/mikavilpas/yazi.nvim/pull/180
--       hovered_buffer = nil,
--       -- See https://github.com/mikavilpas/yazi.nvim/pull/351
--       hovered_buffer_in_same_directory = nil,
--     },
--
--     -- the floating window scaling factor. 1 means 100%, 0.9 means 90%, etc.
--     floating_window_scaling_factor = 0.9,
--
--     -- the transparency of the yazi floating window (0-100). See :h winblend
--     yazi_floating_window_winblend = 0,
--
--     -- the type of border to use for the floating window. Can be many values,
--     -- including 'none', 'rounded', 'single', 'double', 'shadow', etc. For
--     -- more information, see :h nvim_open_win
--     yazi_floating_window_border = "rounded",
--
--     -- the zindex of the yazi floating window. Can be used to make the yazi
--     -- window fullscreen. See `:h nvim_open_win()` for more information.
--     yazi_floating_window_zindex = nil,
--
--     -- the log level to use. Off by default, but can be used to diagnose
--     -- issues. You can find the location of the log file by running
--     -- `:checkhealth yazi` in Neovim. Also check out the "reproducing issues"
--     -- section below
--     log_level = vim.log.levels.OFF,
--
--     -- what Neovim should do a when a file was opened (selected) in yazi.
--     -- Defaults to simply opening the file.
--     open_file_function = function(chosen_file, config, state) end,
--
--     -- customize the keymaps that are active when yazi is open and focused. The
--     -- defaults are listed below. Note that the keymaps simply hijack input and
--     -- they are never sent to yazi, so only try to map keys that are never
--     -- needed by yazi.
--     --
--     -- Also:
--     -- - use e.g. `open_file_in_tab = false` to disable a keymap
--     -- - you can customize only some of the keymaps (not all of them)
--     -- - you can opt out of all keymaps by setting `keymaps = false`
--     keymaps = {
--       show_help = "<f1>",
--       open_file_in_vertical_split = "<c-v>",
--       open_file_in_horizontal_split = "<c-x>",
--       open_file_in_tab = "<c-t>",
--       grep_in_directory = "<c-s>",
--       replace_in_directory = "<c-g>",
--       cycle_open_buffers = "<tab>",
--       copy_relative_path_to_selected_files = "<c-y>",
--       send_to_quickfix_list = "<c-q>",
--       change_working_directory = "<c-\\>",
--       open_and_pick_window = "<c-o>",
--     },
--
--     -- completely override the keymappings for yazi. This function will be
--     -- called in the context of the yazi terminal buffer.
--     set_keymappings_function = function(yazi_buffer_id, config, context) end,
--
--     -- some yazi.nvim commands copy text to the clipboard. This is the register
--     -- yazi.nvim should use for copying. Defaults to "*", the system clipboard
--     clipboard_register = "*",
--
--     hooks = {
--       -- if you want to execute a custom action when yazi has been opened,
--       -- you can define it here.
--       yazi_opened = function(preselected_path, yazi_buffer_id, config)
--         -- you can optionally modify the config for this specific yazi
--         -- invocation if you want to customize the behaviour
--       end,
--
--       -- when yazi was successfully closed
--       yazi_closed_successfully = function(chosen_file, config, state) end,
--
--       -- when yazi opened multiple files. The default is to send them to the
--       -- quickfix list, but if you want to change that, you can define it here
--       yazi_opened_multiple_files = function(chosen_files, config, state) end,
--
--       -- This function is called when yazi is ready to process events.
--       on_yazi_ready = function(buffer, config, process_api) end,
--     },
--
--     -- highlight buffers in the same directory as the hovered buffer
--     highlight_hovered_buffers_in_same_directory = true,
--
--     integrations = {
--       --- What should be done when the user wants to grep in a directory
--       grep_in_directory = function(directory)
--         -- the default implementation uses telescope if available, otherwise nothing
--       end,
--
--       grep_in_selected_files = function(selected_files)
--         -- similar to grep_in_directory, but for selected files
--       end,
--
--       --- Similarly, search and replace in the files in the directory
--       replace_in_directory = function(directory)
--         -- default: grug-far.nvim
--       end,
--
--       replace_in_selected_files = function(selected_files)
--         -- default: grug-far.nvim
--       end,
--
--       -- `grealpath` on OSX, (GNU) `realpath` otherwise
--       resolve_relative_path_application = "",
--
--       -- the way to resolve relative paths. The default_implementation can be
--       -- customized with a function. See
--       -- documentation/copy-relative-path-to-files.md for more information.
--       resolve_relative_path_implementation = function(args, get_relative_path)
--       end,
--
--       -- how to delete (close) a buffer. Defaults to a bundled version of
--       -- `snacks.bufdelete`, copied from https://github.com/folke/snacks.nvim,
--       -- which maintains the window layout. See the `types.lua` file for more
--       -- information for the available options.
--       bufdelete_implementation = "bundled-snacks",
--
--       -- add an action to a file picker to copy the relative path to the
--       -- selected file(s). The implementation is the same as for the
--       -- `copy_relative_path_to_selected_files` yazi.nvim keymap. Currently
--       -- only snacks.nvim is supported. Documentation can be found in the
--       -- keybindings section of the readme.
--       --
--       -- available options:
--       -- - nil (default, no action added)
--       -- - "snacks.picker" (snacks.nvim)
--       picker_add_copy_relative_path_action = nil,
--     },
--
--     future_features = {
--       -- use a file to store the last directory that yazi was in before it was
--       -- closed. Defaults to `true`.
--       use_cwd_file = true,
--
--       -- use a new shell escaping implementation that is more robust and works
--       -- on more platforms. Defaults to `true`. If set to `false`, the old
--       -- shell escaping implementation will be used, which is less robust and
--       -- may not work on all platforms.
--       new_shell_escaping = true,
--     },
--   },
-- }
