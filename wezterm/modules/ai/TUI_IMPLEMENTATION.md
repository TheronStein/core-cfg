# CopilotChat TUI Implementation

## Overview

The new TUI (Text User Interface) implementation uses a **bash script running in a WezTerm split pane** with **file-based communication** between the main config and the TUI.

This solves the problem where `pane:send_text()` was sending chat messages as shell commands.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│  WezTerm Main Process                           │
│  (copilot_chat_tui.lua)                         │
│                                                  │
│  - Receives user commands                       │
│  - Calls AI APIs                                │
│  - Writes messages to files                     │
└──────────────────┬──────────────────────────────┘
                   │
                   │ File-based communication
                   │ ($XDG_RUNTIME_DIR/wezterm-copilot-chat/)
                   │
                   ├─> messages.txt (chat history)
                   ├─> command.fifo (user input)
                   └─> messages.txt.updated (signal file)
                   │
┌──────────────────┴──────────────────────────────┐
│  TUI Pane (bash script)                         │
│  (copilot-chat-tui.sh)                          │
│                                                  │
│  - Displays formatted chat messages             │
│  - Accepts user input                           │
│  - Sends commands via FIFO                      │
└─────────────────────────────────────────────────┘
```

---

## Files Created

### 1. `/scripts/copilot-chat-tui.sh`
**Bash TUI script** that:
- Displays chat messages with ANSI colors
- Shows a formatted header
- Accepts user input
- Writes input to command FIFO
- Refreshes display when messages are added

### 2. `/modules/copilot_chat_tui.lua`
**Main Lua module** that:
- Creates the TUI pane
- Manages file-based communication
- Handles API requests (OpenAI, Anthropic, GitHub)
- Processes commands (`/help`, `/clear`, `/model`, etc.)
- Monitors command FIFO for user input
- 1Password integration for API keys

---

## Communication Flow

### User sends a message:

1. User types in TUI pane → writes to `command.fifo`
2. Lua module monitors FIFO → reads command
3. Module processes command:
   - If command (`/help`, `/clear`, etc.) → execute immediately
   - If regular message → send to API
4. Module writes response to `messages.txt`
5. Module creates `messages.txt.updated` signal file
6. TUI detects signal → refreshes display

### Format of `messages.txt`:
```
role|timestamp|content
user|06:03:45|How do I use tmux?
assistant|06:03:47|Tmux is a terminal multiplexer...
system|06:04:00|Model changed to gpt-4
```

---

## Features

### ✅ Working:
- ANSI colored output (user=green, assistant=blue, system=orange, error=red)
- Command processing (`/help`, `/clear`, `/reset`, `/model`, `/exit`)
- OpenAI API integration
- 1Password API key retrieval
- Message history
- Real-time updates

### 🚧 To Implement:
- Selection context from WezTerm panes
- Git diff context
- Streaming responses
- Session save/load
- Prompt templates (Explain, Review, Fix, etc.)
- Async API calls (currently blocking)

---

## Usage

### Keybindings:
- `SUPER+C` - Toggle CopilotChat TUI
- `LEADER+a` - Open with prompt (planned)
- `LEADER+CTRL+a` - Explain selection (planned)

### Commands in chat:
- `/help` - Show available commands
- `/clear` - Clear chat history
- `/reset` - Reset session
- `/model` - Cycle through AI models
- `/exit` - Close chat

### Environment Setup:
You need an API key configured via:
1. **1Password** (recommended):
   - Item: "OpenAI API" in "dev" vault
   - Field: "credential"

2. **Environment variable**:
   ```bash
   export OPENAI_API_KEY="sk-..."
   ```

---

## Configuration

In `events/copilot-chat-init.lua`:

```lua
copilot_chat:setup({
  api = {
    provider = "openai",  -- or "anthropic", "github"
    model = "gpt-4o-2024-08-06",
    temperature = 0.1,
    onepassword = {
      enabled = true,
      vault = "dev",
      items = {
        openai = "OpenAI API",
        anthropic = "ANTHROPIC API KEY",
      },
      fields = {
        openai = "credential",
        anthropic = "credential",
      },
    },
  },
  ui = {
    position = "right",
    width = 0.4,
  },
})
```

---

## Technical Details

### Why FIFOs?
Named pipes (FIFOs) allow the TUI bash script to send data back to the Lua module without polling files constantly.

### Why file-based?
WezTerm doesn't have shared memory or direct IPC between config and spawned processes. Files are the simplest cross-process communication.

### Performance Considerations:
- **Blocking API calls** - Currently blocks main thread. Should be made async.
- **FIFO polling** - Uses `wezterm.time.call_after(1)` to check FIFO every 1 second.
- **File I/O** - Minimal overhead since chat messages are small.

---

## Future Enhancements

### High Priority:
1. **Async API calls** - Don't block UI during requests
2. **Prompt templates** - Pre-built prompts (Explain, Review, Fix, etc.)
3. **Context inclusion** - Selection text, git diffs, file paths

### Medium Priority:
1. **Streaming responses** - Show response as it arrives
2. **Better error handling** - Show API errors nicely
3. **Session persistence** - Save/load conversations

### Low Priority:
1. **Syntax highlighting** - Use bat or highlight in TUI
2. **Markdown rendering** - Better formatting for code blocks
3. **Multiple conversations** - Switch between chats

---

## Testing

1. Reload WezTerm: `LEADER+r`
2. Open chat: `SUPER+C`
3. Try commands:
   ```
   /help
   /model
   What is WezTerm?
   /clear
   ```
4. Check logs: `wezterm.log_info()` messages

---

## Troubleshooting

### Chat doesn't open:
- Check if TUI script is executable: `ls -l scripts/copilot-chat-tui.sh`
- Check logs: Look for `[CopilotChat]` entries

### No API response:
- Verify API key: `op item get "OpenAI API" --vault dev --fields credential`
- Check internet connection
- Look for errors in messages (red text)

### TUI doesn't refresh:
- Check if signal file is created: `ls /tmp/wezterm-copilot-chat/messages.txt.updated`
- Monitor FIFO: `cat /tmp/wezterm-copilot-chat/command.fifo`

### Input not working:
- Make sure FIFO exists: `ls -l /tmp/wezterm-copilot-chat/command.fifo`
- Check FIFO permissions

---

## Comparison with Old Implementation

| Feature | copilot_chat_v2.lua | copilot_chat_tui.lua |
|---------|---------------------|----------------------|
| UI Method | `pane:send_text()` ❌ | Bash TUI script ✅ |
| Display | Executed as commands ❌ | Proper formatted display ✅ |
| Input | Via prompts | Direct input in pane ✅ |
| Communication | Direct | File-based ✅ |
| Colors | Limited | Full ANSI support ✅ |
| Updates | Manual refresh | Auto-refresh ✅ |

---

## Credits

Based on concepts from:
- Neovim CopilotChat plugin (archived in `.archv/`)
- WezTerm split pane architecture
- UNIX FIFO/pipe patterns
