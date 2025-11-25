# WezTerm Tab Naming Convention

## Format

Tabs now display context-aware information in a compact, structured format:

```
icon cwd/proc [context]
```

### Components

1. **Icon** - Process-specific nerd font icon (e.g., , , )
2. **cwd/proc** - Current working directory name or process name (max 20 chars)
3. **[context]** - Contextual information based on environment

### Context Formats

#### Inside Tmux
```
[tmux_icon/session]
```
- **tmux_icon**: Workspace icon from `TMUX_SERVER_ICON` env variable
- **session**: Tmux session name (max 10 chars)

Example: ` wezterm [/main]`

#### Outside Tmux
```
[domain]
```
- **domain**: Mux domain name (e.g., "local", remote host) (max 14 chars)

Example: ` wezterm [local]`

## Truncation Rules

All parts are truncated with `..` suffix if they exceed their character limits:

- **cwd/proc**: 20 characters max
- **session** (inside tmux): 10 characters max
- **domain** (outside tmux): 14 characters max

Examples of truncation:
- `very-long-directory-name` → `very-long-director..`
- `long-session-name-here` → `long-sess..`
- `very-long-domain-name` → `very-long-do..`

## Implementation Details

### Tmux Environment Variables

Each tmux workspace configuration must define:

```bash
set-environment -g TMUX_SERVER_ICON "󰇅"    # Workspace icon
set-environment -g TMUX_SERVER_SHORT "SYS"  # Short name (for reference)
```

### Current Workspace Icons

| Workspace      | Icon | Short |
|---------------|------|-------|
| Configuration | 󰒓    | CFG   |
| Development   | 󰌽    | DEV   |
| Documentation |     | DOC   |
| Environment   | 󰙯    | ENV   |
| Network       | 󰖟    | NET   |
| Objective     |     | OBJ   |
| Personal      | 󱅞    | PER   |
| Security      | 󰒃    | SEC   |
| System        | 󰇅    | SYS   |
| Testing       | 󰙨    | TEST  |
| Work          | 󰃫    | WORK  |

### OSC Sequences

Tmux sends environment variables to WezTerm via OSC 1337 escape sequences:

```bash
# Hooks defined in ~/.core/cfg/tmux/conf/hooks.conf
set-hook -g after-new-session 'run-shell "
  printf \"\\033]1337;SetUserVar=TMUX_SESSION=$(echo -n #{session_name} | base64)\\007\" > #{pane_tty};
  printf \"\\033]1337;SetUserVar=TMUX_SERVER_ICON=$(tmux show-environment -g TMUX_SERVER_ICON 2>/dev/null | cut -d= -f2 | base64)\\007\" > #{pane_tty}
"'
```

These hooks trigger on:
- `after-new-session`
- `client-session-changed`
- `after-rename-session`
- `client-attached`

### WezTerm Processing

The tabline module (`modules/gui/tabline/tabs.lua`) reads user variables in the `tabs()` function:

```lua
local user_vars = pane:get_user_vars()
local tmux_session = user_vars.TMUX_SESSION or ""
local tmux_server_icon = user_vars.TMUX_SERVER_ICON or ""

-- Decode base64 values
tmux_session = wezterm.base64_decode(tmux_session)
tmux_server_icon = wezterm.base64_decode(tmux_server_icon)

-- Build context
if tmux_session ~= "" and tmux_server_icon ~= "" then
    context = "[" .. tmux_server_icon .. "/" .. tmux_session .. "]"
end
```

## Examples

### Development Workspace
```
 nvim [󰌽/main]
 .core [󰌽/dev-config]
 yazi [󰌽/file-browse..]
```

### System Workspace
```
 btop [󰇅/apps]
 tmux [󰇅/monitoring]
```

### Non-Tmux Tab
```
 wezterm [local]
 ssh [remote-server]
```

## Files Modified

1. **Tmux Configuration**:
   - `conf/hooks.conf` - Added OSC sequence hooks for TMUX_SERVER_ICON
   - `workspaces/*.tmux` - Added TMUX_SERVER_ICON and TMUX_SERVER_SHORT to all workspaces

2. **WezTerm Configuration**:
   - `modules/gui/tabline/tabs.lua` - Updated tab rendering with new naming logic
     - Added `truncate()` function for consistent truncation
     - Added CWD/process detection logic
     - Integrated user_vars reading for tmux info
     - Implemented context-aware formatting `[icon/session]` or `[domain]`
   - `events/format-tab-title.lua` - (Initially updated but not used - tabline module handles formatting)

## Testing

After updating tmux workspace configs, restart tmux servers to load the new environment variables:

```bash
# For a specific workspace
tmux -L system kill-server
~/.core/cfg/tmux/scripts/start-server.sh system

# Or source the config in running servers
tmux -L system source-file ~/.core/cfg/tmux/workspaces/system.tmux
```

Then reload WezTerm config to see the new tab naming format.

## Customization

### Adjusting Character Limits

Edit the limits in `modules/gui/tabline/tabs.lua` (inside the `tabs()` function):

```lua
local cwd_proc_display = truncate(cwd_proc, 20)    -- Change 20
local session_part = truncate(tmux_session, 10)     -- Change 10
local domain_display = truncate(domain, 14)         -- Change 14
```

### Adding Process Icons

Add entries to the `process_icons` table:

```lua
local process_icons = {
    ["zsh"] = "",
    ["bash"] = "",
    ["your_app"] = "󰀵",  -- Add your icon here
}
```

### Changing Workspace Icons

Edit the workspace configuration file:

```bash
# ~/.core/cfg/tmux/workspaces/yourworkspace.tmux
set-environment -g TMUX_SERVER_ICON "󰕮"  # Your preferred icon
```
