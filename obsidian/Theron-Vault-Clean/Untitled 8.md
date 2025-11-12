# Untitled 8
### Top‐Level Structure

- **Header Comment**: Start your `tmux.conf` with a brief description (purpose, author, date).
    
- **Sections**: Divide the file into clearly marked sections (e.g. “Options”, “Keybindings”, “Status Bar”, “Panes & Windows”, “Plugins”).
    

### 2. Naming & Organization

- **Group Related Settings**: Keep all `set-option` calls together, all `bind-key` calls together, etc.
    
- **Sub-Sections**: Within each section, subgroup by feature (e.g. under “Keybindings”: pane navigation, resizing, session management).
    
- **Use Descriptive Comments**: Before each group, add a one-line comment explaining what follows.
    

### 3. Prefix & Leader Key

- **Custom Prefix**: Define your prefix early (`set -g prefix C-a` or similar).
    
- **Unbind Default**: Explicitly unbind the default before reassigning (`unbind C-b`).
    
- **Consistency**: All subsequent keybindings should reference the new prefix.
    

### 4. Core Options

- **Global vs. Window vs. Pane**: Use `-g` (global), `-w` (window), or `-p` (pane) flags consistently.
    
- **Visual Clarity**: Set pane-border styles, status‐bar colors, mouse support, history limits in this section.
    

### 5. Keybindings

- **Logical Order**: Group in the order you use them (sessions → windows → panes → layouts → copy‐mode).
    
- **Prefix Shortcuts**: Always bind with the prefix (e.g. `bind-key C-h select-pane -L`).
    
- **Non-Prefix Shortcuts**: If you need direct keys (e.g. for plugins), clearly comment their purpose.
    
- **Avoid Conflicts**: Scan for duplicate binds; comment out or remove unused ones.
    

### 6. Status Bar & Prompts

- **Left vs. Right**: Separate `status-left` and `status-right` configurations.
    
- **Components**: Define each status element (session name, time, battery, etc.) in its own line or variable.
    
- **Refresh Interval**: Set `status-interval` with an explanatory comment.
    

### 7. Window & Pane Defaults

- **Default-Shell**: Specify your preferred shell (`set -g default-shell /bin/zsh`).
    
- **Renaming**: Enable/disable auto-rename or define manual renaming binds.
    
- **Synchronization**: If you use synchronized panes, group that bind clearly.
    

### 8. Plugins & Extensions

- **Plugin Manager**: If using TPM, dedicate a block for plugin initialization.
    
- **Plugin List**: List `set -g @plugin` lines alphabetically or by category.
    
- **Post-Install Hooks**: Include `run '~/.tmux/plugins/tpm/tpm'` at bottom.
    

### 9. Copy & Paste / Vi Mode

- **Mouse Mode**: Toggle `set -g mouse on/off` and explain use.
    
- **Copy Mode**: Configure `setw -g mode-keys vi` and bind keys for scrolling/copy.
    
- **Clipboard Integration**: Document any `run-shell` calls for system‐clipboard support.
    

### 10. Performance & History

- **Scrollback**: Set a high `history-limit` with rationale.
    
- **Logging (Optional)**: If logging panes, comment on log location and rotation.
    

### 11. Custom Scripts & Hooks

- **Hooks Section**: Group any `set-hook` calls (e.g., `client-session-changed`).
    
- **External Scripts**: If you call shell scripts, note their paths and expected parameters.
    

### 12. Versioning & Maintenance

- **Version Banner**: Embed a comment with your config’s version or git tag.
    
- **Changelog Section**: At the very end, keep a short changelog of key edits.
    
- **Source Control**: Note in a comment where the repo lives (e.g. GitHub URL).
    

### 13. Readability & Style

- **Indentation**: Use consistent spacing or tabs for continuation lines.
    
- **Line Length**: Wrap long status‐bar definitions or binds at ~80–100 chars.
    
- **Documentation Links**: Where non-obvious, link to tmux manpage sections (`# see “tmux(1) OPTIONS”`).