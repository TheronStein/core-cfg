# Tab Template Hooks - Example Configurations

This document provides ready-to-use example hook configurations for common scenarios.

## Quick Start Examples

### Example 1: Single Project

Perfect for developers working on one main project.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "myproject",
      "pattern": "~/projects/myapp",
      "template": "dev",
      "description": "Main development project",
      "enabled": true,
      "notify": true
    }
  ]
}
```

**Setup Steps:**
1. Create a tab template named "dev" (save your desired tab configuration)
2. Add this rule via the hooks menu
3. Navigate to `~/projects/myapp` - template auto-applies

---

### Example 2: Config Files Organization

For users who edit multiple config directories.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "nvim_config",
      "pattern": "~/.core/.sys/cfg/nvim",
      "template": "neovim",
      "description": "Neovim configuration",
      "enabled": true,
      "notify": true
    },
    {
      "name": "wezterm_config",
      "pattern": "~/.core/.sys/cfg/wezterm",
      "template": "wezterm",
      "description": "WezTerm configuration",
      "enabled": true,
      "notify": true
    },
    {
      "name": "zsh_config",
      "pattern": "~/.core/.sys/cfg/zsh",
      "template": "zsh",
      "description": "Zsh configuration",
      "enabled": true,
      "notify": true
    }
  ]
}
```

**Setup Steps:**
1. Create templates: "neovim", "wezterm", "zsh"
2. Each template should have appropriate icon and title
3. Navigate to config dirs - templates auto-apply

---

### Example 3: Multiple Projects with Wildcards

For developers with many projects under one directory.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "all_projects",
      "pattern": "~/projects/*",
      "template": "project-work",
      "description": "Any project directory",
      "enabled": true,
      "notify": false
    },
    {
      "name": "dotfiles",
      "pattern": "~/dotfiles",
      "template": "dotfiles",
      "description": "Dotfiles management",
      "enabled": true,
      "notify": true
    }
  ]
}
```

**Notes:**
- First rule matches ANY directory under `~/projects/`
- Second rule is more specific (exact match)
- First match wins, so order matters!

---

### Example 4: Language-Specific Environments

Different templates for different programming languages.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "python_projects",
      "pattern": ".*/python/.*",
      "template": "python-dev",
      "description": "Python development",
      "enabled": true,
      "notify": true
    },
    {
      "name": "rust_projects",
      "pattern": ".*/rust/.*",
      "template": "rust-dev",
      "description": "Rust development",
      "enabled": true,
      "notify": true
    },
    {
      "name": "lua_projects",
      "pattern": ".*/lua/.*",
      "template": "lua-dev",
      "description": "Lua development",
      "enabled": true,
      "notify": true
    }
  ]
}
```

**Setup Steps:**
1. Organize projects by language: `~/projects/python/app1`, `~/projects/rust/tool1`
2. Create language-specific templates with appropriate icons
3. Patterns match any path containing the language name

---

### Example 5: Work vs Personal Projects

Separate configurations for work and personal projects.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "work_projects",
      "pattern": "~/work/*",
      "template": "work",
      "description": "Work projects",
      "enabled": true,
      "notify": true
    },
    {
      "name": "personal_projects",
      "pattern": "~/personal/*",
      "template": "personal",
      "description": "Personal projects",
      "enabled": true,
      "notify": true
    }
  ]
}
```

**Templates Suggestion:**
- **work** template: Professional icon (💼), muted color
- **personal** template: Fun icon (🏠), vibrant color

---

### Example 6: Documentation Directories

For technical writers and documentation maintainers.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "project_docs",
      "pattern": ".*/docs$",
      "template": "documentation",
      "description": "Documentation directories",
      "enabled": true,
      "notify": true
    },
    {
      "name": "markdown_notes",
      "pattern": "~/notes",
      "template": "notes",
      "description": "Personal notes",
      "enabled": true,
      "notify": true
    }
  ]
}
```

**Pattern Explanation:**
- `.*/docs$` matches any path ending in "/docs"
- `~/notes` exact match for notes directory

---

## Advanced Examples

### Example 7: Complex Pattern Matching

Using Lua patterns for sophisticated matching.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "any_nvim",
      "pattern": ".*nvim.*",
      "template": "neovim",
      "description": "Any neovim-related directory",
      "enabled": true,
      "notify": false
    },
    {
      "name": "test_directories",
      "pattern": ".*/tests?$",
      "template": "testing",
      "description": "Test directories",
      "enabled": true,
      "notify": true
    },
    {
      "name": "src_directories",
      "pattern": ".*/src$",
      "template": "source-code",
      "description": "Source code directories",
      "enabled": true,
      "notify": false
    }
  ]
}
```

**Pattern Breakdown:**
- `.*nvim.*` - Contains "nvim" anywhere
- `.*/tests?$` - Ends with "test" or "tests"
- `.*/src$` - Ends with "src"

---

### Example 8: Git Repository Detection

Apply templates based on repository structure.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "monorepo_packages",
      "pattern": ".*/packages/.*",
      "template": "monorepo-package",
      "description": "Monorepo package",
      "enabled": true,
      "notify": false
    },
    {
      "name": "client_projects",
      "pattern": "~/clients/.*/.*",
      "template": "client-work",
      "description": "Client project work",
      "enabled": true,
      "notify": true
    }
  ]
}
```

---

### Example 9: Temporary Workspaces

For temporary work, experiments, and scratch directories.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "tmp_scratch",
      "pattern": "/tmp/.*",
      "template": "temporary",
      "description": "Temporary files",
      "enabled": true,
      "notify": false
    },
    {
      "name": "experiments",
      "pattern": "~/experiments/*",
      "template": "experimental",
      "description": "Experimental projects",
      "enabled": true,
      "notify": false
    }
  ]
}
```

**Note:** Notifications disabled for frequently-visited temporary directories

---

### Example 10: Full Production Setup

Complete configuration for a professional development workflow.

```json
{
  "enabled": true,
  "rules": [
    {
      "name": "config_nvim",
      "pattern": "~/.core/.sys/cfg/nvim",
      "template": "neovim",
      "description": "Neovim configuration",
      "enabled": true,
      "notify": true
    },
    {
      "name": "config_wezterm",
      "pattern": "~/.core/.sys/cfg/wezterm",
      "template": "wezterm",
      "description": "WezTerm configuration",
      "enabled": true,
      "notify": true
    },
    {
      "name": "config_yazi",
      "pattern": "~/.core/.sys/cfg/yazi",
      "template": "yazi",
      "description": "Yazi file manager config",
      "enabled": true,
      "notify": true
    },
    {
      "name": "main_project",
      "pattern": "~/projects/myapp",
      "template": "myapp-dev",
      "description": "Main application development",
      "enabled": true,
      "notify": true
    },
    {
      "name": "side_projects",
      "pattern": "~/projects/side/*",
      "template": "side-project",
      "description": "Side projects",
      "enabled": true,
      "notify": false
    },
    {
      "name": "client_work",
      "pattern": "~/clients/*",
      "template": "client",
      "description": "Client project work",
      "enabled": true,
      "notify": true
    },
    {
      "name": "documentation",
      "pattern": ".*/docs$",
      "template": "documentation",
      "description": "Documentation directories",
      "enabled": true,
      "notify": false
    }
  ]
}
```

---

## Template Suggestions

Here are recommended templates to create for the examples above:

### Template: "dev"
- **Icon**: 🚀 (`:md_rocket:`)
- **Title**: "Development"
- **Color**: `#a6e3a1` (green)

### Template: "neovim"
- **Icon**:  (`:dev_vim:`)
- **Title**: "Neovim"
- **Color**: `#a8d545` (neovim green)

### Template: "wezterm"
- **Icon**:  (`:md_console:`)
- **Title**: "WezTerm"
- **Color**: `#8b00ff` (purple)

### Template: "documentation"
- **Icon**: 📝 (`:md_file_document:`)
- **Title**: "Docs"
- **Color**: `#fab387` (orange)

### Template: "client"
- **Icon**: 💼 (`:md_briefcase:`)
- **Title**: "Client"
- **Color**: `#89b4fa` (blue)

### Template: "testing"
- **Icon**: 🧪 (`:md_test_tube:`)
- **Title**: "Tests"
- **Color**: `#f38ba8` (red)

---

## Tips for Creating Effective Hooks

1. **Start Broad, Get Specific**: Begin with wildcard rules for categories, then add specific rules for important projects

2. **Notification Strategy**:
   - Enable for important/infrequent directories
   - Disable for frequently-visited directories

3. **Template Reuse**: One template can be used by multiple hooks

4. **Pattern Testing**: Use the 🧪 Test Hook feature to verify patterns work before relying on them

5. **Order Matters**: First matching rule wins, so order specific rules before general ones

6. **Documentation**: Use clear descriptions - you'll thank yourself later

---

## Workflow Integration

### Scenario: Starting a New Project

1. Create the project directory
2. Navigate to it in WezTerm
3. Customize your tab (icon, title, color)
4. Save as template: "newproject-dev"
5. Use "Quick Add Hook for Current Dir"
6. Enter template name: "newproject-dev"
7. Done! Future visits auto-apply the template

### Scenario: Organizing Existing Projects

1. List all your project directories
2. Identify common patterns
3. Create 2-3 generic templates (work, personal, config)
4. Add wildcard hooks for each category
5. Add specific hooks for your most-used projects

### Scenario: Team Setup

Share your hooks configuration:
1. Export `.data/tabs/hooks.json`
2. Export `.data/tabs/templates.json`
3. Share with team members
4. They import into their WezTerm config

---

## Troubleshooting Examples

### Problem: Hook not triggering

**Test with this minimal config:**
```json
{
  "enabled": true,
  "rules": [
    {
      "name": "test",
      "pattern": "~",
      "template": "home",
      "description": "Home directory test",
      "enabled": true,
      "notify": true
    }
  ]
}
```

Navigate to `~` and wait 3-5 seconds. If this doesn't work, check:
- Does template "home" exist?
- Is hooks system enabled globally?
- Check WezTerm logs for errors

### Problem: Wrong template applying

**Check rule order:**
```json
{
  "rules": [
    {
      "pattern": "~/projects/important",
      "template": "important-project"
    },
    {
      "pattern": "~/projects/*",
      "template": "generic-project"
    }
  ]
}
```

Specific rules BEFORE general rules!

---

## Migration Guide

### From Manual Template Loading

**Before:**
```
1. cd ~/projects/myapp
2. LEADER+F1 → Tab Management → Load Template → myapp-dev
```

**After:**
```json
{
  "pattern": "~/projects/myapp",
  "template": "myapp-dev"
}
```

Now just: `cd ~/projects/myapp` (auto-applies)

---

## Performance Notes

- Each rule evaluation is lightweight (< 1ms)
- Polling interval: 3 seconds
- State tracking prevents repeated applications
- Disabled rules have zero overhead

---

## See Also

- **Main Documentation**: `TAB_HOOKS.md`
- **Tab Templates**: `.data/tabs/templates.json`
- **Hooks Configuration**: `.data/tabs/hooks.json`
