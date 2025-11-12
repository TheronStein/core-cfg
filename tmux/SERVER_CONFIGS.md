# Tmux Server-Specific Configurations

This directory contains configurations for running multiple independent tmux servers, each with their own sessions, resurrect directories, and environment variables.

## Quick Start

### Start a server manually
```bash
# Using the helper script
~/.core/cfg/tmux/scripts/start-server.sh development

# Or directly
tmux -f ~/.core/cfg/tmux/development.tmux -L development new-session -s main
```

### Attach to a server
```bash
tmux -L development attach-session
```

### List all servers
```bash
# Use the WezTerm browser
~/.core/cfg/wezterm/scripts/tmux-server-browser/browser.sh
```

## Configuration Structure

### Server Config Files (`*.tmux`)

Each server has its own configuration file that:
1. Sources the base `tmux.conf`
2. Overrides server-specific settings
3. Sets custom environment variables
4. Configures separate resurrect directories

Example: `development.tmux`
- **Socket name**: `development` (via `-L development`)
- **Resurrect directory**: `~/.tmux/resurrect/development/`
- **Environment variable**: `TMUX_SESSION_CWD=$HOME/.core/dev`

## Creating a New Server Config

1. Copy the template:
```bash
cp ~/.core/cfg/tmux/development.tmux ~/.core/cfg/tmux/myserver.tmux
```

2. Edit the new file and change:
   - `TMUX_SERVER_NAME`
   - `TMUX_SESSION_CWD`
   - `@resurrect-dir`

3. Start the server:
```bash
~/.core/cfg/tmux/scripts/start-server.sh myserver
```

## Persistence with Systemd

To make servers start automatically on boot:

### 1. Copy the service template
```bash
mkdir -p ~/.config/systemd/user
cp ~/.core/cfg/tmux/systemd/tmux-development.service.example \
   ~/.config/systemd/user/tmux-development.service
```

### 2. Enable and start
```bash
systemctl --user daemon-reload
systemctl --user enable tmux-development.service
systemctl --user start tmux-development.service
```

### 3. Check status
```bash
systemctl --user status tmux-development.service
```

### 4. View logs
```bash
journalctl --user -u tmux-development.service -f
```

## Resurrect Usage

Each server has its own resurrect directory to keep sessions separate.

### Save sessions
```bash
# Inside tmux
<prefix> + Ctrl-s

# Or from command line
tmux -L development run-shell ~/.core/cfg/tmux/plugins/tmux-resurrect/scripts/save.sh
```

### Restore sessions
```bash
# Inside tmux
<prefix> + Ctrl-r

# Or from command line
tmux -L development run-shell ~/.core/cfg/tmux/plugins/tmux-resurrect/scripts/restore.sh
```

### Auto-restore on server start

Add to your server config (e.g., `development.tmux`):
```bash
# At the end of the file
run-shell "~/.core/cfg/tmux/plugins/tmux-resurrect/scripts/restore.sh"
```

## Directory Structure

```
~/.core/cfg/tmux/
├── tmux.conf              # Base configuration (shared by all servers)
├── development.tmux       # Development server config
├── production.tmux        # Production server config (example)
├── scripts/
│   └── start-server.sh    # Helper script to start servers
└── systemd/
    └── *.service.example  # Systemd service templates

~/.tmux/resurrect/
├── development/           # Development server sessions
│   ├── last
│   └── tmux_resurrect_*.txt
├── production/            # Production server sessions
│   ├── last
│   └── tmux_resurrect_*.txt
└── default/               # Default server sessions (if using)
    ├── last
    └── tmux_resurrect_*.txt
```

## Environment Variables Available

In your server-specific configs, you can use:

- `TMUX_SESSION_CWD` - Default working directory for sessions
- `TMUX_SERVER_NAME` - Name of the current server
- Any other custom environment variables you define

Access them in tmux:
```bash
# In shell
echo $TMUX_SESSION_CWD

# In tmux config
new-window -c "$TMUX_SESSION_CWD"
```

## Example Servers

### Development Server
```bash
# Socket: development
# CWD: ~/.core/dev
# Resurrect: ~/.tmux/resurrect/development/
tmux -L development attach
```

### Work Server
```bash
# Socket: work
# CWD: ~/work/projects
# Resurrect: ~/.tmux/resurrect/work/
tmux -L work attach
```

### Personal Server
```bash
# Socket: personal
# CWD: ~
# Resurrect: ~/.tmux/resurrect/personal/
tmux -L personal attach
```

## Tips

1. **Browser Integration**: Use the WezTerm tmux-server-browser to visually browse all servers and their sessions
2. **Aliases**: Add shell aliases for quick access:
   ```bash
   alias tdev='tmux -L development attach'
   alias twork='tmux -L work attach'
   ```
3. **Resurrect Backups**: Resurrect files are just text - commit them to git for extra safety
4. **Status Bar**: Customize each server's status bar to show which server you're on
