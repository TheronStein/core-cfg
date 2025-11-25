-- CopilotChat initialization event

local wezterm = require("wezterm")
local copilot_chat = require("modules.copilot_chat_tui")

local M = {}

function M.setup()
  -- Initialize CopilotChat with configuration on startup
  wezterm.on("gui-startup", function()
    copilot_chat:setup({
      api = {
        provider = "anthropic", -- Default to Anthropic since you have that configured
        model = "claude-3-5-sonnet-20241022", -- Claude 3.5 Sonnet
        temperature = 0.1,
        onepassword = {
          enabled = true,
          vault = "dev", -- Your 1Password vault
          items = {
            anthropic = "ANTHROPIC API KEY", -- Your exact item name
            openai = "OpenAI API", -- Update if you have this
            github = "GitHub", -- Update if you have this
          },
          fields = {
            anthropic = "credential", -- Your field label
            openai = "credential",
            github = "token",
          },
        },
      },
      ui = {
        position = "right",
        width = 0.4,
      },
      chat = {
        system_prompt = [[You are an AI programming assistant integrated into WezTerm.
Follow the user's requirements carefully & to the letter.
Keep responses concise but informative.
Use Markdown formatting for code blocks with language tags.
When discussing code, focus on practical solutions.]],
        auto_save = true,
      },
    })

    wezterm.log_info("[CopilotChat] Module initialized on startup")
  end)

  -- Add event handler for getting input via prompt
  wezterm.on("copilot-chat.prompt-input", function(window, pane)
    window:perform_action(
      wezterm.action.PromptInputLine({
        description = "Copilot Chat:",
        action = wezterm.action_callback(function(inner_window, inner_pane, line)
          if line then
            copilot_chat:handle_input(line)
          end
        end),
      }),
      pane
    )
  end)
end

return M