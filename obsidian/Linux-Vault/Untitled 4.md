
### File 4: Customizing tmux.md
```markdown
# Customizing tmux

## Configuration File
The `tmux` configuration file is typically located at `~/.tmux.conf`. You can customize key bindings, appearance, and behaviors through this file.

## Sample Customization
Change prefix from `Ctrl+b` to `Ctrl+a`:
```bash
set -g prefix C-a
unbind C-b
bind C-a send-prefix
