# Custom Yazi Plugin Development Workflow

This document defines the standard workflow for creating, developing, and maintaining custom Yazi plugins in the `~/.core/cfg/yazi/dev/` directory.

## Directory Structure

```
~/.core/cfg/yazi/
├── dev/                          # Custom plugins under development
│   └── plugin-name.yazi/
│       ├── main.lua              # Plugin entry point
│       ├── README.md             # Plugin documentation
│       ├── .git/                 # Git repository
│       └── .gitignore
├── plugins/                      # Installed plugins from package.toml
├── package.toml                  # Plugin dependencies
└── init.lua                      # Plugin loading configuration
```

## Workflow Steps

### 1. Create New Plugin

```bash
# Navigate to dev directory
cd ~/.core/cfg/yazi/dev/

# Create plugin directory (must end with .yazi)
mkdir my-plugin.yazi
cd my-plugin.yazi

# Initialize as git repository
git init

# Create basic structure
touch main.lua README.md .gitignore
```

### 2. Implement Plugin

**main.lua** - Entry point with required structure:

```lua
--- @sync entry
return {
    entry = function(_, args)
        -- Plugin implementation
    end,
}
```

**README.md** - Documentation including:
- Features
- Installation instructions
- Usage examples
- Requirements
- How it works

**.gitignore** - Standard exclusions:
```
*.luac
*.log
.DS_Store
*.swp
*~
```

### 3. Test Locally

Load the plugin in `init.lua`:

```lua
-- Custom dev plugin
safe_require_checked("my-plugin")
```

Restart Yazi to test changes. Check for errors in:
- `~/.core/cfg/yazi/plugin_errors.log`
- Yazi notification popups

### 4. Add Keybindings (Optional)

In `keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = ["key1", "key2"]
run = "plugin my-plugin --args='action'"
desc = "Description of action"
```

### 5. Create GitHub Repository

```bash
# From plugin directory
cd ~/.core/cfg/yazi/dev/my-plugin.yazi

# Initial commit
git add .
git commit -m "Initial commit: Plugin description

Features:
- Feature 1
- Feature 2
- Feature 3

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Create GitHub repo (replace 'username' with your GitHub username)
gh repo create my-plugin.yazi --public --source=. \
    --description="Brief plugin description" --push
```

### 6. Add to package.toml

Once pushed to GitHub, add to `~/.core/cfg/yazi/package.toml`:

```toml
# Custom dev plugins
[[plugin.deps]]
use = "username/my-plugin"
```

### 7. Update and Distribution

**For local development:**
- Make changes in `dev/my-plugin.yazi/`
- Commit and push to GitHub
- Yazi automatically uses local dev version

**For distribution:**
Users can install via `package.toml`:

```toml
[[plugin.deps]]
use = "username/my-plugin"
rev = "commit-sha"  # Optional: pin to specific version
hash = "hash"        # Optional: for integrity checking
```

Then run:
```bash
ya pack -i  # Install
ya pack -u  # Update all plugins
```

## Best Practices

### Plugin Naming
- Use descriptive, kebab-case names
- Always append `.yazi` to directory name
- Example: `nvim-image-paste.yazi`, `git-status.yazi`

### Code Organization
- Keep `main.lua` focused on plugin entry point
- Extract complex logic to separate files if needed
- Use `safe_require_checked()` for loading in init.lua

### Error Handling
- Validate inputs and file existence
- Provide user-friendly notifications via `ya.notify()`
- Log errors for debugging

### Documentation
- Document all keybindings in README
- Include usage examples
- List all dependencies and requirements
- Explain how the plugin works internally

### Version Control
- Commit frequently with descriptive messages
- Tag releases with semantic versioning
- Keep README updated with changes

### Testing
- Test in multiple contexts (nvim, standalone, different directories)
- Verify error cases don't crash Yazi
- Check plugin_errors.log after changes

## Example: nvim-image-paste.yazi

See `~/.core/cfg/yazi/dev/nvim-image-paste.yazi/` for a complete example following this workflow:

- ✅ Proper directory structure
- ✅ Git repository with meaningful commits
- ✅ Published to GitHub
- ✅ Referenced in package.toml
- ✅ Loaded in init.lua
- ✅ Keybindings in keymap.toml
- ✅ Complete documentation in README.md

## Troubleshooting

### Plugin not loading
1. Check `~/.core/cfg/yazi/plugin_errors.log`
2. Verify plugin name matches directory name (without .yazi)
3. Ensure `safe_require_checked()` is called in init.lua
4. Restart Yazi after changes

### Plugin loaded but not working
1. Check Yazi notifications for runtime errors
2. Verify keybindings in keymap.toml
3. Add debug `ya.notify()` calls to trace execution
4. Check plugin arguments are passed correctly

### GitHub push fails
1. Ensure SSH key is added to ssh-agent: `ssh-add ~/.ssh/id_github`
2. Verify repository exists: `gh repo view username/plugin-name`
3. Check remote is configured: `git remote -v`
4. Push manually: `git push -u origin master`

## Resources

- [Yazi Plugin Documentation](https://yazi-rs.github.io/docs/plugins/overview)
- [Yazi Plugin API](https://yazi-rs.github.io/docs/plugins/api)
- [Example Plugins](https://github.com/yazi-rs/plugins)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
