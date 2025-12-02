local function keymap()
  if vim.opt.iminsert:get() > 0 and vim.b.keymap_name then
    return "⌨ " .. vim.b.keymap_name
  end
  return ""
end
--
-- local function window()
-- 	return vim.api.nvim_win_get_number(0)
-- end
--
-- function lualine_trouble()
-- 	local trouble = require("trouble")
-- 	local symbols = trouble.statusline({
-- 		mode = "lsp_document_symbols",
-- 		groups = {},
-- 		title = false,
-- 		filter = { range = true },
-- 		format = "{kind_icon}{symbol.name:Normal}",
-- 		-- The following line is needed to fix the background color
-- 		-- Set it to the lualine section you want to use
-- 		hl_group = "lualine_c_normal",
-- 	})
-- 	table.insert(opts.sections.lualine_c, {
-- 		symbols.get,
-- 		cond = symbols.has,
-- 	})
-- end
return {
  -- First plugin: tabline.nvim
  {
    "kdheepak/tabline.nvim",
    dependencies = {
      "nvim-lualine/lualine.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("tabline").setup({
        enable = true,
        options = {
          show_tabs_always = true,
          show_devicons = true,
          show_bufnr = false,
          show_filename_only = true,
        },
      })
    end,
  },

  -- {
  -- 	"kdheepak/winbar.nvim",
  -- 	dependencies = {
  -- 		"nvim-lualine/lualine.nvim",
  -- 		"nvim-tree/nvim-web-devicons",
  -- 	},
  -- 	config = function()
  -- 		require("winbar").setup({
  -- 			enabled = true,
  --
  -- 			show_file_path = true,
  -- 			show_symbols = true,
  --
  -- 			colors = {
  -- 				path = "", -- You can customize colors like #c946fd
  -- 				file_name = "",
  -- 				symbols = "",
  -- 			},
  --
  -- 			icons = {
  -- 				file_icon_default = "",
  -- 				seperator = ">",
  -- 				editor_state = "●",
  -- 				lock_icon = "",
  -- 			},
  --
  -- 			exclude_filetype = {
  -- 				"help",
  -- 				"startify",
  -- 				"dashboard",
  -- 				"packer",
  -- 				"neogitstatus",
  -- 				"NvimTree",
  -- 				"Trouble",
  -- 				"alpha",
  -- 				"lir",
  -- 				"Outline",
  -- 				"spectre_panel",
  -- 				"toggleterm",
  -- 				"qf",
  -- 				-- "c"
  -- 			},
  -- 		})
  -- 	end,
  -- },

  -- Second plugin: lualine.nvim
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "kdheepak/tabline.nvim",
      -- "fgheng/winbar.nvim",
      "letieu/harpoon-lualine",
    },
    config = function()
      -- ====================================================================
      -- THEME OPTION 1: Custom theme based on codedark
      -- ====================================================================
      local codedark = require("lualine.themes.codedark")

      -- Deep copy the theme to avoid mutation issues
      local custom_codedark = vim.deepcopy(codedark)

      -- Change normal mode background color to #8BE9FD with black text
      custom_codedark.normal.a = { fg = "#000000", bg = "#8BE9FD", gui = "bold" }

      -- ====================================================================
      -- THEME OPTION 2: Custom theme based on tokyonight-storm
      -- ====================================================================
      local tokyonight = require("lualine.themes.tokyonight")

      -- Deep copy the theme to avoid mutation issues
      local custom_tokyonight = vim.deepcopy(tokyonight)

      -- Change normal mode background color to #8BE9FD with black text
      -- (same customization as codedark for consistency)
      custom_tokyonight.normal.a = { fg = "#000000", bg = "#8BE9FD", gui = "bold" }

      -- ====================================================================
      -- SELECT ACTIVE THEME: Change this to switch themes
      -- ====================================================================
      local active_theme = custom_tokyonight -- Options: custom_codedark, custom_tokyonight

      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = active_theme,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          always_show_tabline = true,
          globalstatus = true, -- Global statusline at top
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            refresh_time = 16, -- ~60fps
            events = {
              "WinEnter",
              "BufEnter",
              "BufWritePost",
              "SessionLoadPost",
              "FileChangedShellPost",
              "VimResized",
              "Filetype",
              "CursorMoved",
              "CursorMovedI",
              "ModeChanged",
            },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { keymap },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = {
            "progress",
            function()
              -- Display session info
              if _G.AutoSession then
                local current_session = vim.v.this_session
                if current_session and current_session ~= "" then
                  local session_name = vim.fn.fnamemodify(current_session, ":t:r")
                  local root_type = _G.AutoSession.get_root_type()

                  -- Add icon based on root type
                  local icon = ""
                  if root_type == "git" then
                    icon = " "
                  elseif root_type == "editorconfig" then
                    icon = " "
                  elseif root_type == "marker" then
                    icon = " "
                  else
                    icon = " "
                  end

                  -- Shorten session name if too long
                  if #session_name > 20 then
                    session_name = session_name:sub(1, 17) .. "..."
                  end

                  return icon .. session_name
                end
              end
              return " No session"
            end,
          },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        -- Buffers on left (lualine_c), tabs on right (lualine_x)
        tabline = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { require("tabline").tabline_buffers },
          lualine_x = { require("tabline").tabline_tabs },
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "filename" }, -- Buffer title in top right
        },
        inactive_winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "filename" }, -- Buffer title in top right (inactive)
        },
        extensions = {},
      })
    end,
  },

  {
    "b0o/incline.nvim",

    config = function()
      require("incline").setup({
        debounce_threshold = {
          falling = 0,
          rising = 0,
        },
        hide = {
          cursorline = false,
          focused_win = false,
          only_win = false,
        },
        highlight = {
          groups = {
            InclineNormal = {
              default = true,
              -- Use a highlight group from lualine's theme for consistency
              -- LualineC or LualineMid usually works well for the main bar area
              group = "LualineC",
            },
            InclineNormalNC = {
              default = true,
              -- Use the inactive lualine color (e.g., LualineInactive)
              group = "LualineInactive",
            },
          },
        },
        ignore = {
          buftypes = "special",
          filetypes = {},
          floating_wins = true,
          unlisted_buffers = true,
          wintypes = "special",
        },
        render = "basic",
        window = {
          margin = {
            horizontal = 0,
            vertical = 0,
          },
          options = {
            signcolumn = "no",
            wrap = false,
          },
          overlap = {
            borders = true,
            statusline = true,
            tabline = true,
            winbar = true,
          },
          padding = 1,
          padding_char = " ",
          placement = {
            horizontal = "left",
            vertical = "bottom",
          },
          width = "fit",
          winhighlight = {
            active = {
              EndOfBuffer = "None",
              Normal = "InclineNormal",
              Search = "None",
            },
            inactive = {
              EndOfBuffer = "None",
              Normal = "InclineNormalNC",
              Search = "None",
            },
          },
          zindex = 1000,
        },
      }) -- <<< FIX: Removed extra closing ')' from here
    end,
  },
}

-- local custom_fname = require("lualine.components.filename"):extend()
-- local highlight = require("lualine.highlight")
-- local default_status_colors = { saved = "#228B22", modified = "#C70039" }
--
-- function custom_fname:init(options)
-- 	custom_fname.super.init(self, options)
-- 	self.status_colors = {
-- 		saved = highlight.create_component_highlight_group(
-- 			{ bg = default_status_colors.saved },
-- 			"filename_status_saved",
-- 			self.options
-- 		),
-- 		modified = highlight.create_component_highlight_group(
-- 			{ bg = default_status_colors.modified },
-- 			"filename_status_modified",
-- 			self.options
-- 		),
-- 	}
-- 	if self.options.color == nil then
-- 		self.options.color = ""
-- 	end
-- end
--
-- function custom_fname:update_status()
-- 	local data = custom_fname.super.update_status(self)
-- 	data = highlight.component_format_highlight(
-- 		vim.bo.modified and self.status_colors.modified or self.status_colors.saved
-- 	) .. data
-- 	return data
-- end

-- sections = {
--   lualine_a = {'mode'},
--   lualine_b = {'branch', 'diff', 'diagnostics'},
--   lualine_c = {'filename'},
--   lualine_x = {'encoding', 'fileformat', 'filetype'},
--   lualine_y = {'progress'},
--   lualine_z = {'location'}
-- },
-- inactive_sections = {
--   lualine_a = {},
--   lualine_b = {},
--   lualine_c = {'filename'},
--   lualine_x = {'location'},
--   lualine_y = {},
--   lualine_z = {}
-- },
-- tabline = {},
-- winbar = {},
-- inactive_winbar = {},
-- extensions = {}
-- },
--
-- }
--

--
--
-- require('lualine').setup {options = {theme = gruvbox}}
--
-- M.colors = {
--   black        = '#282828',
--   white        = '#ebdbb2',
--   red          = '#fb4934',
--   green        = '#b8bb26',
--   blue         = '#83a598',
--   yellow       = '#fe8019',
--   gray         = '#a89984',
--   darkgray     = '#3c3836',
--   lightgray    = '#504945',
--   inactivegray = '#7c6f64',
-- }
--
-- local custom_gruvbox = require'lualine.themes.gruvbox'
--
-- -- Change the background of lualine_c section for normal mode
-- custom_gruvbox.normal.c.bg = '#112233'
--
-- require('lualine').setup {
--   options = { theme  = custom_gruvbox },
--   ...
-- }
--
-- M.
--    local lualine = require("lualine").setup({
--   normal = {
--     a = {bg = , fg = , gui = 'Gbold'},
--     b = {bg = , fg = },
--     c = {bg = , fg = }
--   },
--   insert = {
--     a = {bg = colors.blue, fg = colors.black, gui = 'bold'},
--     b = {bg = colors.lightgray, fg = colors.white},
--     c = {bg = colors.lightgray, fg = colors.white}
--   },
--   visual = {
--     a = {bg = colors.yellow, fg = colors.black, gui = 'bold'},
--     b = {bg = colors.lightgray, fg = colors.white},
--     c = {bg = colors.inactivegray, fg = colors.black}
--   },
--   replace = {
--     a = {bg = colors.red, fg = colors.black, gui = 'bold'},
--     b = {bg = colors.lightgray, fg = colors.white},
--     c = {bg = colors.black, fg = colors.white}
--   },
--   command = {
--     a = {bg = colors.green, fg = colors.black, gui = 'bold'},
--     b = {bg = colors.lightgray, fg = colors.white},
--     c = {bg = colors.inactivegray, fg = colors.black}
--   },
--   inactive = {
--     a = {bg = colors.darkgray, fg = colors.gray, gui = 'bold'},
--     b = {bg = colors.darkgray, fg = colors.gray},
--     c = {bg = colors.darkgray, fg = colors.gray}
--   }
-- }
--
--
-- -- different lines -
-- -- ojroques/nvim-hardline
-- -- NTBBloodbath/galaxyline.nvim
-- -- OXY2DEV/bars.nvim -- bare template for custom statusline
--
-- -- custom status column
-- -- uukvbaal/statuscol.nvim
--
-- -- return {
-- --   "nvim-lualine/lualine.nvim",
-- --   dependencies = { "nvim-tree/nvim-web-devicons" },
-- --   config = function()
-- --     require("lualine").setup({
-- --       options = {
-- --         icons_enabled = true,
-- --         theme = "moonlight",
-- --         component_separators = { left = "", right = "" },
-- --     				section_separators = { left = "", right = "" },
-- --  },
-- -- 				disabled_filetypes = {
-- --    {
-- -- 					statusline = {},
-- --   },
-- -- 					winbar = {},
-- -- {},     },
-- -- 	},
-- -- 				ignore_focus = {},
-- -- {},
-- -- 				always_divide_middle = true,
-- -- ue,
-- -- 				always_show_tabline = true,
-- -- ue,
-- -- 				globalstatus = false,
-- -- se,
-- -- 				refresh = {
-- --    {
-- -- 					statusline = 1000,
-- --   0,
-- -- 					tabline = 1000,
-- --   0,
-- -- 					winbar = 1000,
-- --   0,
-- -- 					refresh_time = 16, -- ~60fps
-- --   ps
-- -- 					events = {
-- --     {
-- -- 						"WinEnter",
-- --     ,
-- -- 						"BufEnter",
-- --     ,
-- -- 						"BufWritePost",
-- --     ,
-- -- 						"SessionLoadPost",
-- --     ,
-- -- 						"FileChangedShellPost",
-- --     ,
-- -- 						"VimResized",
-- --     ,
-- -- 						"Filetype",
-- --     ,
-- -- 						"CursorMoved",
-- --     ,
-- -- 						"CursorMovedI",
-- --     ,
-- -- 						"ModeChanged",
-- --   ",
-- --      },
-- -- 	},     }		}     }		},
-- -- 			sections = {
-- -- = {
-- -- 				lualine_a = { "mode" },
-- --  },
-- -- 				lualine_b = { "branch", "diff", "diagnostics" },
-- --  },
-- -- 				lualine_c = { "filename" },
-- --  },
-- -- 				-- lualine_x = {{"claudius", icon = ""}, 'encoding', 'fileformat', 'filetype'},
-- --
-- -- },
-- --
-- -- 				lualine_x = { "encoding", "fileformat", "filetype" },
-- --  },
-- -- 				lualine_y = { "progress" },
-- --  },
-- -- 				lualine_z = { "location" }" }     }		},
-- -- 			inactive_sections = {
-- -- = {
-- -- 				lualine_a = {},
-- -- {},
-- -- 				lualine_b = {},
-- -- {},
-- -- 				lualine_c = { "filename" },
-- --  },
-- -- 				lualine_x = { "location" },
-- --  },
-- -- 				lualine_y = {},
-- -- {},
-- -- 				lualine_z = {} {}     }		},
-- -- 			tabline = {} {},
-- -- 			winbar = {} {},
-- -- 			inactive_winbar = {} {},
-- -- 			extensions = = {
-- --  ,
-- -- 		})
-- -- 	end,
-- --   opts = function(_, opts)
-- --     local x = opts.sections.lualine_x
-- --     for _, comp in ipairs(x) do
-- --       if comp[1] == "diff" then
-- --         comp.source = function()
-- --           local summary = vim.b.minidiff_summary
-- --           return summary
-- --             and {
-- --               added = summary.add,
-- --               modified = summary.change,
-- --               removed = summary.delete,
-- --             }
-- --         end
-- --         break
-- --       end
-- --     end
-- --   end,
-- -- }
-- --
