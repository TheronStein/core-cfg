local map = vim.keymap.set
local wk = require("which-key")

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-treesitter/nvim-treesitter",
    "zbirenbaum/copilot.lua", -- Ensure Copilot.lua is loaded first
  },
  opts = {
    model = "claude-sonnet-4.5",
    temperature = 0.1,
    auto_insert_mode = true,

    window = {
      layout = "vertical", -- 'vertical', 'horizontal', 'float'
      width = 0.5, -- 50% of screen width
      border = "rounded",
      title = " CopilotChat │ <CR>=Send │ <C-y>=Accept │ <C-c>=Cancel │ <C-l>=Clear ",
    },

    -- Define keymaps for CopilotChat
    mappings = {
      complete = {
        insert = "<Tab>", -- Use Tab for completion in chat
      },
      submit_prompt = {
        normal = "<CR>",
        insert = "<C-CR>", -- Ctrl+Enter to submit from insert mode
      },
      accept_diff = {
        normal = "<C-y>", -- Accept diff with C-y (consistent with Copilot)
        insert = "<C-y>",
      },
      close = {
        normal = "q",
        insert = "<C-c>",
      },
      reset = {
        normal = "<C-l>", -- Clear chat with C-l
        insert = "<C-l>",
      },
      yank_diff = {
        normal = "gy", -- Yank diff
        register = "+", -- Use system clipboard
      },
      show_help = {
        normal = "g?",
      },
    },

    -- Show help message as virtual lines when waiting for user input
    show_help = true,

    -- Context/sticky setup
    context = "buffers", -- Use all open buffers as context
    sticky = nil, -- No sticky prompts by default

    -- Selection mode
    selection = function(source)
      -- Try visual selection first, then current buffer
      local select_visual = require("CopilotChat.select").visual
      local select_buffer = require("CopilotChat.select").buffer

      return select_visual(source) or select_buffer(source)
    end,

    -- Custom prompts
    prompts = {
      Explain = {
        prompt = "/COPILOT_EXPLAIN Explain how this code works step by step.",
        description = "Explain selected code",
      },
      Review = {
        prompt = "/COPILOT_REVIEW Review this code for bugs, security issues, and improvements.",
        description = "Review selected code",
      },
      Fix = {
        prompt = "/COPILOT_FIX There is a problem in this code. Rewrite the code to fix it.",
        description = "Fix problems in code",
      },
      Optimize = {
        prompt = "/COPILOT_OPTIMIZE Optimize this code for performance and readability.",
        description = "Optimize selected code",
      },
      Docs = {
        prompt = "/COPILOT_DOCS Generate documentation for this code including docstrings and comments.",
        description = "Generate documentation",
      },
      Tests = {
        prompt = "/COPILOT_TESTS Generate comprehensive unit tests for this code.",
        description = "Generate tests",
      },
      Refactor = {
        prompt = "/COPILOT_REFACTOR Refactor this code to improve its structure and maintainability.",
        description = "Refactor code",
      },
    },
  },

  config = function(_, opts)
    local chat = require("CopilotChat")
    chat.setup(opts)

    -- Create helpful user commands
    vim.api.nvim_create_user_command("CopilotChatToggle", function()
      chat.toggle()
    end, { desc = "Toggle CopilotChat window" })

    vim.api.nvim_create_user_command("CopilotChatExplain", function()
      chat.ask("Explain how this code works step by step.", {
        selection = require("CopilotChat.select").visual,
      })
    end, { range = true, desc = "Explain selected code" })

    vim.api.nvim_create_user_command("CopilotChatFix", function()
      chat.ask("There is a problem in this code. Rewrite the code to fix it.", {
        selection = require("CopilotChat.select").visual,
      })
    end, { range = true, desc = "Fix selected code" })

    vim.api.nvim_create_user_command("CopilotChatOptimize", function()
      chat.ask("Optimize this code for performance and readability.", {
        selection = require("CopilotChat.select").visual,
      })
    end, { range = true, desc = "Optimize selected code" })

    vim.api.nvim_create_user_command("CopilotChatDocs", function()
      chat.ask("Generate documentation for this code including docstrings and comments.", {
        selection = require("CopilotChat.select").visual,
      })
    end, { range = true, desc = "Generate docs for selected code" })

    vim.api.nvim_create_user_command("CopilotChatTests", function()
      chat.ask("Generate comprehensive unit tests for this code.", {
        selection = require("CopilotChat.select").visual,
      })
    end, { range = true, desc = "Generate tests for selected code" })
  end,
}
