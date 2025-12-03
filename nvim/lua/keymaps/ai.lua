-- ~/.core/.sys/cfg/nvim/lua/keymaps/ai.lua
-- AI assistant keybindings for CopilotChat and Claude Code

local wk = require("which-key")

wk.add({
  -- CopilotChat
  { "<localleader>a", group = "Copilot Chat", desc = "Copilot Chat", mode = { "n", "v", "x" } },
  { "<localleader>aa", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Chat" },
  {
    "<localleader>aq",
    function()
      local input = vim.fn.input("Quick Chat: ")
      if input ~= "" then
        require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
      end
    end,
    desc = "Quick Chat",
  },
  {
    "<localleader>ar",
    function()
      require("CopilotChat").reset()
    end,
    desc = "Reset Chat",
  },

  {
    "<localleader>ap",
    function()
      local actions = require("CopilotChat.actions")
      actions.pick(actions.prompt_actions(), {
        selection = require("CopilotChat.select").visual,
      })
    end,
    desc = "Prompts Picker",
  },

  -- CopilotChat visual mode actions
  { "<localleader>ae", ":<C-u>CopilotChatExplain<cr>", mode = "v", desc = "Explain Code" },
  { "<localleader>af", ":<C-u>CopilotChatFix<cr>", mode = "v", desc = "Fix Code" },
  { "<localleader>ao", ":<C-u>CopilotChatOptimize<cr>", mode = "v", desc = "Optimize Code" },
  { "<localleader>ad", ":<C-u>CopilotChatDocs<cr>", mode = "v", desc = "Generate Docs" },
  { "<localleader>at", ":<C-u>CopilotChatTests<cr>", mode = "v", desc = "Generate Tests" },
  {
    "<localleader>av",
    function()
      local chat = require("CopilotChat")
      chat.open()
      local selection = require("CopilotChat.select").visual()
      if selection then
        chat.ask("", { selection = selection })
      end
    end,
    mode = "v",
    desc = "Chat with Selection",
  },

  -- Claude Code
  { "<leader>a", group = "AI/Claude" },
  { "<leader>aa", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
  { "<leader>aF", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
  { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
  { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  { "<leader>aM", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model" },
  { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add Current Buffer" },

  -- Claude Code visual/file tree
  { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
  {
    "<leader>ae",
    "<cmd>ClaudeCodeTreeAdd<cr>",
    desc = "Add File from Tree",
    ft = { "yazi" },
  },
  -- Claude Code diffs
  { "<leader>aA", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Diff" },
  { "<leader>aD", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Diff" },
  { "<leader>af", "<cmd>ClaudeFzfFiles<cr>", desc = "Claude: Add files" },
  { "<leader>aG", "<cmd>ClaudeFzfGrep<cr>", desc = "Claude: Grep and Add" },
  { "<leader>aB", "<cmd>ClaudeFzfBuffers<cr>", desc = "Claude: Add buffers" },
  { "<leader>ag", "<cmd>ClaudeFzfGitFiles<cr>", desc = "Claude: Add Git files" },
  { "<leader>ad", "<cmd>ClaudeFzfDirectory<cr>", desc = "Claude: Add directory files" },
  { "<leader>ah", "<cmd>ClaudeHistory<cr>", desc = "Claude: History" },
  { "<leader>aH", "<cmd>ClaudeHistoryDebug<cr>", desc = "Claude: History Debug" },
})
